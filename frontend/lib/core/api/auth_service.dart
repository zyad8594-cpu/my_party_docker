import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'dart:convert' show jsonDecode, jsonEncode;
import '../../data/models/user.dart' show User, UserStDT;
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart' show AppRoutes;
import 'api_constants.dart' show ApiKeys;

class AuthService extends GetxService {
  // private variables
  final _token = ''.obs;
  final _user = Rx<User>(User.fromJson({}));
  final _profileImgVersion = 0.obs;

  // public variables
  static Rx<User> get user => Get.find<AuthService>()._user;
  static RxString get token => Get.find<AuthService>()._token;
  static RxInt get profileImgVersion => Get.find<AuthService>()._profileImgVersion;
  
  static bool get userIsSupplier => _compareStr('SUPPLIER', Get.find<AuthService>()._user.value.role, isCaseSensitive: false);
  static bool get userIsAdmin => _compareStr('ADMIN', Get.find<AuthService>()._user.value.role, isCaseSensitive: false);
  static bool get userIsNotSupplier => !userIsSupplier;

  bool get isLoggedIn => _token.isNotEmpty;
  final isLoding = false.obs;

  // Constants for SharedPreferences
  static const String _savedAccountsKey = 'saved_accounts';

  // public methods
  Future<AuthService> init({SharedPreferences? prefs}) async {
    isLoding.value = true; 
    prefs ??= await SharedPreferences.getInstance();
    
    // التحقق من تذكرني (أو مجرد رمز نشط مباشرة في الإنتاج)
    // final rememberMe = prefs.getBool('rememberMe') ?? false;
    _token.value = prefs.getString(ApiKeys.tokenKey) ?? '' ;
    
    final userJs = prefs.getString(ApiKeys.userKey);
    if (_token.isNotEmpty) {
      if(userJs != null){
        try {
          _user.value = User.fromJsonDecode(userJs);
        } 
        catch(e) {
          debugPrint('خطأ في تحليل بيانات المستخدم النشط: $e');
        }
      }
    }
    isLoding.value = false; 
    return this;
  }
  
  static Future<void> saveAuthData(
    Map<String, dynamic> data, {
    bool rememberMe = true,
    SharedPreferences? prefs
  }) async {
    await Get.find<AuthService>()._saveAuthData(data['token'], data['user'], rememberMe: rememberMe, prefs: prefs);
  }

  static Future<void> logoutAsync({bool singleAccount = true}) async => await Get.find<AuthService>()._logout(singleAccount: singleAccount);
  static void logout({bool singleAccount = true}) => logoutAsync(singleAccount: singleAccount);

  /// Switches to another saved account
  static Future<bool> switchAccount(String targetToken, {SharedPreferences? prefs}) async {
    return await Get.find<AuthService>()._switchAccount(targetToken, prefs: prefs);
  }

  /// Removes an account from locally saved accounts (doesn't force logout if it's not active)
  static Future<void> removeSavedAccount(int accountId, {SharedPreferences? prefs}) async {
    await Get.find<AuthService>()._removeSavedAccount(accountId, prefs: prefs);
  }

  /// Gets a list of all remembered accounts
  static Future<List<Map<String, dynamic>>> getSavedAccounts({SharedPreferences? prefs}) async 
  {
    prefs ??= await SharedPreferences.getInstance();
    final savedAccountsString = prefs.getString(_savedAccountsKey);

    if (savedAccountsString != null) 
    {
      try {
        return (jsonDecode(savedAccountsString) as List)
          .map((e) => Map<String, dynamic>.from(e)).toList();
      } 
      catch (e) 
      {
        debugPrint('Error decoding saved accounts: $e');
      }
    }
    return [];
  }

  static Future<void> clearUserAndToken({SharedPreferences? prefs}) async {
    await Get.find<AuthService>()._clearUserAndToken(prefs: prefs);
  }

  // private methods
  Future<void> _saveAuthData(
    String? newToken,
    dynamic userData, {
    bool rememberMe = false,
    SharedPreferences? prefs 
  }) async {
    prefs ??= await SharedPreferences.getInstance();
    
    await switch((rememberMe, newToken)){
      (true, null) => Future<bool?>.value(null),
      (true, '') => Future<bool?>.value(null),
      (false, _) => ()async{
        _token.value = (newToken ?? '').isNotEmpty ? newToken! : _token.value;
        return await Future<bool?>.value(null);
      }(),
      (true, _) => ()async{
        _token.value = newToken!;
        return await prefs?.setString(ApiKeys.tokenKey, newToken);
      }(),
    };

    user.value = switch(userData){
      String() => User.fromJson(jsonDecode(userData)),
      RxString() => User.fromJson(jsonDecode(userData.value)),
      
      Map<String, dynamic>() => User.fromJson(userData),
      Rx<Map<String, dynamic>>() => User.fromJson(userData.value),
      
      User() => userData,
      Rx<User>() => userData.value,
      _ => user.value,
    };

    try {
      final userJson = await switch((rememberMe, user.value.toJson(userStDT: UserStDT.BOTH))){
        (true, final userJson) => ()async{
          await prefs!.setString(ApiKeys.userKey, jsonEncode(userJson));
          return userJson;
        }(),
        (_, final userJson) => Future.value(userJson)
      };
      
      // التعامل مع الحسابات المتعددة (الحسابات المحفوظة)
      // if (rememberMe) {
        await _addOrUpdateSavedAccount(
          userId: user.value.id,
          userData: {...userJson, 'token': _token.value},
          rememberMe: rememberMe,
          prefs: prefs
        );
      // }
    } 
    catch (e) 
    {
      debugPrint('خطأ في ترميز بيانات المستخدم للاستمرار: $e');
    }
    
    await prefs.setBool('rememberMe', rememberMe);
    _profileImgVersion.value++;
    user.refresh();
  }

  Future<void> _addOrUpdateSavedAccount({
    required int userId,
    required Map<String, dynamic> userData,
    required bool rememberMe,
    SharedPreferences? prefs 
  }) async {
    
    prefs ??= await SharedPreferences.getInstance();
    final accounts = await getSavedAccounts(prefs: prefs);
    int existingIndex = accounts.indexWhere((acc) => (acc['id'] ?? acc['user_id']) == userId);
    

    await switch((rememberMe, existingIndex != -1)){
      (true, true) =>(()async=> accounts[existingIndex] = userData)(), // Update existing
      (true, false) => (()async=> accounts.add(userData))(), // Add new
      (false, bool e) =>()async{
        if(e) accounts.removeAt(existingIndex);
        await prefs?.remove(ApiKeys.tokenKey);
        await prefs?.remove(ApiKeys.userKey);
      }(), 
    };
    
    await prefs.setString(_savedAccountsKey, jsonEncode(accounts));
  }

  Future<bool> _switchAccount(String targetToken, {SharedPreferences? prefs }) async {
    isLoding.value = true;
    try {
      final targetAccount = (await getSavedAccounts(prefs: prefs))
        .firstWhere((acc) => acc['token'] == targetToken, orElse: () => {});
      
      if (targetAccount.isNotEmpty) 
      {
        // Rebuild user object from basic saved data
        final User userObj = User.fromJson(targetAccount);
        
        // This sets the active token/user without adding it to the saved list again explicitly since it's already there
        await _saveAuthData(targetAccount['token'], userObj, rememberMe: true, prefs: prefs);
        
        // Navigate based on role
        Get.offAllNamed(switch(userObj.role.toUpperCase()){
          'SUPPLIER' => AppRoutes.supplierHome,
          _ => AppRoutes.home,
        });
        isLoding.value = false;
        return true;
      }
    } 
    catch (e) 
    {
      debugPrint('خطأ في تبديل الحساب: $e');
    }
    isLoding.value = false;
    return false;
  }

  Future<void> _removeSavedAccount(int accountId, {SharedPreferences? prefs}) async 
  {
    prefs ??= await SharedPreferences.getInstance();
    final accounts = await getSavedAccounts(prefs: prefs);
    accounts.removeWhere((acc) => (acc['id'] ?? acc['user_id']) == accountId);

    
    await prefs.setString(_savedAccountsKey, jsonEncode(accounts));
    
    // If the account being removed is the currently active one, logout
    if (user.value.id == accountId) {
      await _logout(singleAccount: true);
    }
  }

  Future<void> _clearUserAndToken({SharedPreferences? prefs}) async {
    prefs ??= await SharedPreferences.getInstance();
    await prefs.remove(ApiKeys.userKey);
    await prefs.remove(ApiKeys.tokenKey);
    _user.value = User.fromJson({});
    _token.value = '';
    _profileImgVersion.value++;
    user.refresh();
  }

  Future<void> _logout({bool singleAccount = true, SharedPreferences? prefs}) async {
    if(isLoding.value) return;
    isLoding.value = true;
    
    prefs ??= await SharedPreferences.getInstance();
    final accounts = await getSavedAccounts(prefs: prefs);
    // First, remove from saved accounts list if we're completely logging it out
    if (user.value.id > 0 && singleAccount) 
    {
      accounts.removeWhere((acc) => (acc['id'] ?? acc['user_id']) == user.value.id);
      await prefs.setString(_savedAccountsKey, jsonEncode(accounts));
    }

    // Attempt to switch to another account if available
    // if (singleAccount) {
      
    //   if (accounts.isNotEmpty) {
    //     await _switchAccount(accounts.first['token'], prefs: prefs);
    //     isLoding.value = false;
    //     return; // Don't clear active session completely, we switched to another one
    //   }
    // } 
    else 
    {
      await prefs.remove(_savedAccountsKey);
    }

    // Complete session clearing
    // await prefs.setBool('rememberMe', false);
    await prefs.remove(ApiKeys.tokenKey);
    await prefs.remove(ApiKeys.userKey);
    _token.value = '';
    _user.value = User.fromJson({});
    
    isLoding.value = false; 
    Get.offAllNamed(AppRoutes.login);
  }

  static bool _compareStr(String value, dValue, {bool isCaseSensitive = true}){
    if(dValue != null && dValue is String){
      if(isCaseSensitive){
        return value == dValue;
      }
      else{
        return value.toLowerCase() == dValue.toLowerCase();
      }
    }
    return false;
  }
  
}


/*
  static T? userGet<T>(String detailName, {T? defualtVal}){
    final user = Get.find<AuthService>()._user;
    return (user.containsKey(detailName) && user[detailName] && user[detailName] is T)? user[detailName]  : defualtVal;
  }

  static int? get userGetId => userGet<int>('user_id');
  static String? get userGetRole => userGet<String>('role_name');
  static String? get userGetFullName => userGet<String>('full_name');
  static String? get userGetName => userGetFullName;
  static String? get userGetPhone => userGet<String>('phone_number');
  static String? get userGetEmail => userGet<String>('email');
  static String? get userGetImgUrl => userGet<String>('img_url');

  static bool userHas(String detailName) => Get.find<AuthService>()._user.containsKey(detailName);
  static bool userDetailIs(String detailName, value){
    final user = Get.find<AuthService>()._user;
    return user.containsKey(detailName) && _compareStr(value, user[detailName]);
  }
  
  static bool userIdIs(int id) => userDetailIs('user_id', id);
  static bool get userIdIsNull => Get.find<AuthService>()._user['user_id'] == null;
  static bool get userIdIsNotNull => !userIdIsNull;

  static bool get userIsActiv => userDetailIs('is_active', 1);
  static bool get userIsNotActiv => !userIsActiv;
  
  static bool userRoleIs(String role) => userDetailIs('role_name', role);
  static bool get userRoleIsNull => Get.find<AuthService>()._user['role_name'] == null;
  static bool get userRoleIsEmpty => Get.find<AuthService>()._user['role_name'] == '';
  static bool get userRoleIsNotNull => !userRoleIsNull && !userRoleIsEmpty;
  static bool get userRoleIsNotEmpty => !userRoleIsNull && !userRoleIsEmpty;
  static bool get userRoleIsNotNullOrEmpty => !userRoleIsNull && !userRoleIsEmpty;

  static bool userNameIs(String name) => userDetailIs('full_name', name);
  static bool get userNameIsNull => Get.find<AuthService>()._user['full_name'] == null;
  static bool get userNameIsEmpty => Get.find<AuthService>()._user['full_name'] == '';
  static bool get userNameIsNotNull => !userNameIsNull && !userNameIsEmpty;
  static bool get userNameIsNotEmpty => !userNameIsNull && !userNameIsEmpty;
  static bool get userNameIsNotNullOrEmpty => !userNameIsNull && !userNameIsEmpty;

  static bool userPhoneIs(String phone) => userDetailIs('phone_number', phone);
  static bool get userPhoneIsNull => Get.find<AuthService>()._user['phone_number'] == null;
  static bool get userPhoneIsEmpty => Get.find<AuthService>()._user['phone_number'] == '';
  static bool get userPhoneIsNotNull => !userPhoneIsNull && !userPhoneIsEmpty;
  static bool get userPhoneIsNotEmpty => !userPhoneIsNull && !userPhoneIsEmpty;
  static bool get userPhoneIsNotNullOrEmpty => !userPhoneIsNull && !userPhoneIsEmpty;

  static bool userEmailIs(String email) => userDetailIs('email', email);
  static bool get userEmailIsNull => Get.find<AuthService>()._user['email'] == null;
  static bool get userEmailIsEmpty => Get.find<AuthService>()._user['email'] == '';
  static bool get userEmailIsNotNull => !userEmailIsNull && !userEmailIsEmpty;
  static bool get userEmailIsNotEmpty => !userEmailIsNull && !userEmailIsEmpty;
  static bool get userEmailIsNotNullOrEmpty => !userEmailIsNull && !userEmailIsEmpty;

  static bool userImgUrlIs(String imgUrl) => userDetailIs('img_url', imgUrl);
  static bool get userImgUrlIsNull => Get.find<AuthService>()._user['img_url'] == null;
  static bool get userImgUrlIsEmpty => Get.find<AuthService>()._user['img_url'] == '';
  static bool get userImgUrlIsNotNull => !userImgUrlIsNull && !userImgUrlIsEmpty;
  static bool get userImgUrlIsNotEmpty => !userImgUrlIsNull && !userImgUrlIsEmpty;
  static bool get userImgUrlIsNotNullOrEmpty => !userImgUrlIsNull && !userImgUrlIsEmpty;

 */