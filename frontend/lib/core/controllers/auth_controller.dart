// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;
import 'package:dio/dio.dart' as dio;
import '../../data/models/user.dart';
// import '../api/api_constants.dart' show ApiEndpoints;
import 'validtor.dart' show MyPValidator;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/api/auth_service.dart' show AuthService;
import '../../../core/utils/utils.dart' show MyPUtils;
import '../../features/auth/data/repository/auth_repository.dart' show AuthRepository;
import '../api/api_service.dart';
import '../services/fcm_service.dart';
import '../components/app_image.dart';

class AuthController extends GetxController 
{
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final formAuthKey = GlobalKey<FormState>();

  final email = ''.obs;
  final password = ''.obs;
  final name = ''.obs;
  final phone = ''.obs;
  final isPasswordVisible = false.obs;
  final selectedDialCode = '+967'.obs;

  Rx<User> get user => AuthService.user;
  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');
  final nameController = TextEditingController(text: '');
  final phoneController = TextEditingController(text: '');

  final selectedRole = 'coordinator'.obs;
  final profileImage = Rx<File?>(null);
  // Using profileImgVersion from AuthService globally
  final selectedServiceIds = <int>[].obs;

  final agreedToTerms = false.obs;
  final isLoading = false.obs;
  final rememberMe = true.obs;

  final ImagePicker _picker = ImagePicker();


  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }
  
  Future<void> loadUserData() async {
    final userId = user.id;
    if (userId <= 0) return;
    
    try {
      final response = await Get.find<ApiService>().get('/users/$userId');
      if (response != null && response['success'] == true) {
        // Correctly handle different response formats: data: { user: {...} } vs data: {...}
        final rawData = response['data'];
        final userData = (rawData is Map && rawData.containsKey('user')) 
            ? rawData['user'] 
            : (response['user'] ?? rawData);
        
        if (userData != null) {
          await AuthService.saveAuthData({'token': AuthService.token.value, 'user': userData});
          // AuthService.saveAuthData already increments profileImgVersion
          user.refresh();
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> login() async 
  {
    if(isLoading.value) return;
    email.value = emailController.text;
    password.value = passwordController.text;
    var contactMsg = MyPValidator.cocatMsg([
      MyPValidator.email(email),
      MyPValidator.password(password, 6),
      
    ]); 
    if(contactMsg != null)
    {
      return MyPUtils.showSnackbar('خطأ', contactMsg, isError: true);
    }

    if(!_validateFormLogin()){
      isLoading.value = false;
      return;
    }
    // else 
    // {
      isLoading.value = true;
      final result = await _authRepository.login(email.value, password.value);
      await result.fold(
        (error)async{
          isLoading.value = false;
          MyPUtils.showSnackbar('خطأ', error.message, isError: true);
          return false;
        },
        (response) async {
          final token = response['token'] ?? response['data']?['token'];
          final userData = response['user'] ?? response['data']?['user'];
          
          await AuthService.saveAuthData({'token': token, 'user': userData}, rememberMe: rememberMe.value);
          // Get.find<ApiService>().setToken(token);
          
          // Register FCM Token
          await Get.find<FCMService>().updateTokenOnBackend();

          await Get.offAllNamed(switch((userData['role_name'] ?? '').toLowerCase()){
            'supplier' => AppRoutes.supplierHome,
            _ => AppRoutes.home,
          });

          MyPUtils.showSnackbar('نجاح', 'تم تسجيل الدخول بنجاح', position: SnackPosition.TOP);
          isLoading.value = false;
          return true;
        },
      );
      isLoading.value = false;
    // }
  }

  void register() async 
  {
    name.value = nameController.text;
    email.value = emailController.text;
    password.value = passwordController.text;
    phone.value = phoneController.text;

    if(isLoading.value) return;
    var contactMsg = MyPValidator.cocatMsg([
      MyPValidator.name(name),
      MyPValidator.email(email),
      MyPValidator.phone(phone),
      MyPValidator.password(password, 6),
      
    ]); 
    if(contactMsg != null)
    {
      return MyPUtils.showSnackbar('خطأ', contactMsg, isError: true);
    }

    if (!agreedToTerms.value) {
      return MyPUtils.showSnackbar('تنبيه', 'يجب الموافقة على الشروط والأحكام للمتابعة', isError: true);
    }
    
    isLoading.value = true;
  
    dio.FormData finalData = dio.FormData.fromMap({
      'full_name': name.value,
      'email': email.value,
      'password': password.value,
      'phone_number': '${selectedDialCode.value}${phone.value}',
      'role_name': selectedRole.value,
      if (selectedRole.value == 'supplier' && selectedServiceIds.isNotEmpty) 'service_ids[]': selectedServiceIds,
      if (profileImage.value != null) 
        'img_url': await dio.MultipartFile.fromFile(
          profileImage.value!.path,
          filename: profileImage.value!.path.split('/').last,
        )
    });

    final result = await _authRepository.register(finalData);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', '${error.message}\n${error.statusCode}\n$error', isError: true),
      (response) {
        Get.offAllNamed(AppRoutes.login);
        MyPUtils.showSnackbar('نجاح', 'تم التسجيل بنجاح، يمكنك تسجيل الدخول حينما يتم تفعيل الحساب');
        // Clear data
        _clearForm();
      },
    );
    isLoading.value = false;
  }

  Future<bool> updateProfile({
    required String newName,
    required String newEmail,
    required String newPhone,
    File? newImage,
    Map<String, dynamic>? extraDetails,
  }) async {
    if(isLoading.value) return false;
    // final user = this.user.value;
    final userId = user.id;
    if (userId <= 0) return false;

    // --- Dirty Check ---
    bool isChanged = newName != user.name ||
                     newEmail != user.email ||
                     newPhone != user.phoneNumber ||
                     newImage != null;
    
    // Compare extraDetails if provided
    if (extraDetails != null) {
      final currentDetails = user.details;
      for (var key in extraDetails.keys) {
        if (extraDetails[key]?.toString() != currentDetails[key]?.toString()) {
          isChanged = true;
          break;
        }
      }
    }

    if (!isChanged) {
      debugPrint('لا يوجد تغييرات في الملف الشخصي، سيتم إغلاق الشاشة.');
      Get.back(); // Just close the screen
      return true;
    }
    // -------------------

    isLoading.value = true;
    try {
      Map<String, dynamic> details = extraDetails ?? {};
      
      var response = await _authRepository.updateProfile(
        userId,
        dio.FormData.fromMap({
          'full_name': newName,
          'email': newEmail,
          'phone_number': newPhone,
          'details': details,
          if (newImage != null) 'img_url': await dio.MultipartFile.fromFile(
            newImage.path,
            filename: newImage.path.split('/').last,
          ),
        }),
      );
      
      if (response.isSuccess) {
        // Backend might return user directly in 'data' or inside 'data.user'
        // final rawData = response['data'] ?? {};
        // final backendUser = (rawData is Map && rawData.containsKey('user')) 
        //     ? rawData['user'] 
        //     : (response['user'] ?? response);
       
        final backendUser = response.data?['user'] ?? response.data;
        
        // Merge current local user data with backend response to avoid data loss
        final updatedUser = {
          ...user.toMap(), 
          ...(backendUser is Map ? backendUser : {}),
          'full_name': newName,
          'email': newEmail,
          'phone_number': newPhone,
          ...(extraDetails?? {}),
          
        };

        // Handle case where backend might return a new token (or reuse current)
        final newToken = response.data?['token'] ?? response.data?['data']?['token'] 
        // ?? AuthService.token.value 
        ;
        
        debugPrint('Final User Map for Save: $updatedUser');
        
        // Final Solution: Evict any old image cache before re-fetching
        if (user.imgUrl != null) {
          await AppImage.clearCache(user.imgUrl!);
        }
        
        await AuthService.saveAuthData({'token': newToken, 'user': Map<String, dynamic>.from(updatedUser)});
        await loadUserData(); // Fetch fresh data from server to get new image URL
        
        // Extra push for reactive UI - profileImgVersion is handled by AuthService
        user.refresh();
        
        profileImage.value = null; // Clear pending image
        return true;
      }
    } 
    catch (e) 
    {
      MyPUtils.showSnackbar('خطأ', 'فشل تحديث الملف الشخصي', isError: true);
    }
    finally
    {
      isLoading.value = false;
    }
    return false;
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final userId = user.id;
    if (userId == 0) return;

    isLoading.value = true;
    try {
      final response = await _authRepository.changePassword(
        userId,
        oldPassword,
        newPassword,
      );
      
      MyPUtils.showSnackbar('نجاح', 'تم تغيير كلمة المرور بنجاح');
      
    } 
    catch (e) {
      MyPUtils.showSnackbar('خطأ', 'فشل تغيير كلمة المرور. تأكد من كلمة المرور الحالية.\n$e', isError: true);
    }
    isLoading.value = false;
  }

  void _clearForm() {
    name.value = '';
    email.value = '';
    password.value = '';
    phone.value = '';
    
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    
    profileImage.value = null;
    selectedServiceIds.clear();
    agreedToTerms.value = false;
  }

  void logout({bool singleAccount = true}) async {
    await Get.find<FCMService>().clearTokenOnBackend();
    AuthService.logout(singleAccount: singleAccount);
  }

  void addNewAccount() async {
    if(isLoading.value) return;
    isLoading.value = true;
    await AuthService.clearUserAndToken();
    Get.offAllNamed(AppRoutes.login);
    isLoading.value = false;
  }

  /// دالة لحفظ البيانات عند الضغط على الزر
  bool _validateFormLogin() {
    if (formAuthKey.currentState!.validate()) {
      // إذا كان التحقق ناجحاً، احفظ القيم
      formAuthKey.currentState!.save();
      // هنا يمكنك إرسال البيانات للخادم أو التعامل معها
      return true;
    }
    return false;
  }

}