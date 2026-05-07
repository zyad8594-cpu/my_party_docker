
// ignore_for_file: unused_element

import 'dart:convert' show jsonEncode, jsonDecode;

import 'package:get/get.dart' show Rx;
import '../../core/utils/bool_toolse.dart';

import 'package:equatable/equatable.dart';
import '../../core/utils/number_toolse.dart';
import '../../core/utils/string_toolse.dart';

extension UserExtension on Rx<User>
{
  int get id => value.id;
  String get name => value.name;
  String get role => value.role;
  String? get email => value.email;
  String? get phoneNumber => value.phoneNumber;
  String? get imgUrl => value.imgUrl;
  bool get isActive => value.isActive;
  bool get isDeleted => value.isDeleted;
  String get createdAt => value.createdAt;
  String get updatedAt => value.updatedAt;
  Map<String, dynamic> get details => value.details;
  User copy(User? user) => value.copy(user);

  Map<String, dynamic> toMap() => value.toMap();
  Map<String, dynamic> toJson({UserStDT userStDT = UserStDT.BLOCK}) => value.toJson(userStDT: userStDT);
  
  User copyWith({
    int? id,
    String? name,
    String? role,
    String? email,
    String? phoneNumber,
    String? imgUrl,
    bool? isActive,
    bool? isDeleted,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? details,
  }) => value.copyWith(
    id: id,
    name: name,
    role: role,
    email: email,
    phoneNumber: phoneNumber,
    imgUrl: imgUrl,
    isActive: isActive,
    isDeleted: isDeleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
    details: details,
  );

  static User fromJson(dynamic json) => User.fromJson(json);

}

enum UserStDT{ NONE, BLOCK, EXTRACT, BOTH }

class User extends Equatable {
  final int id;
  final String role;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? imgUrl;
  final bool isActive;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> details;
  

  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.phoneNumber,
    this.imgUrl,
    this.isActive = false,
    this.isDeleted = false,
    this.createdAt = '',
    this.updatedAt = '',
    this.details = const {},
  });
  
  factory User.empty()=> const User(id: 0, name: '', role: '', email: '',);
  
  factory User.fromJsonDecode(dynamic json) => User.fromJson(Map<String, dynamic>.from(jsonDecode(json)));
  
  factory User.fromJson(dynamic json) {
    final allKeys = [
      'id', 'user_id', 'userId',
      'name', 'full_name', 'fullName', 
      'user_name', 'userName', 'userFullName',
      'user_full_name',
      'role', 'role_name', 'roleName',
      'user_role', 'userRole',
      'user_role_name', 'userRoleName',

      'email', 'user_email', 'userEmail',
      'phone', 'phone_number', 'phoneNumber',
      'user_phone', 'userPhone',
      'user_phone_number', 'userPhoneNumber',
      'img', 'img_url', 'imgUrl',
      'user_img', 'userImg',
      'user_img_url', 'userImgUrl',
      'urlImg', 'url_img', 'user_img_url', 'userImgUrl',
      'is_active', 'isActive',
      'is_deleted', 'isDeleted',
      'created_at', 'createdAt',
      'updated_at', 'updatedAt',
      'details', 'token', 'password'
    ];
    final detailsObj = Map.fromEntries(
      json.entries.where((e) => 
        !allKeys.contains(e.key) && e.value != null
      )
    );
    return User(
      id: NumberTools.tryParseInt(json, keys: ['id', 'user_id', 'userId']),
      name: StrTools.tryParse(json, keys: [
        'name', 'full_name', 'fullName', 
        'user_name', 'userName', 'userFullName',
        'user_full_name',
      ]),
      role: StrTools.tryParse(json, keys: [
        'role', 'role_name', 'roleName',
        'user_role', 'userRole',
        'user_role_name', 'userRoleName',
      ]),
      email: StrTools.tryParse(json, keys: ['email', 'user_email', 'userEmail']),
      phoneNumber: StrTools.tryParse(json, keys: [
        'phone', 'phone_number', 'phoneNumber',
        'user_phone', 'userPhone',
        'user_phone_number', 'userPhoneNumber',
      ]),
      imgUrl: StrTools.tryParse(json, keys: [
        'img', 'img_url', 'imgUrl',
        'user_img', 'userImg',
        'user_img_url', 'userImgUrl',
        'urlImg', 'url_img', 'user_img_url', 'userImgUrl'
      ]),
      isActive: BoolTools.tryParse(json, keys: ['is_active', 'isActive']),
      isDeleted: BoolTools.tryParse(json, keys: ['is_deleted', 'isDeleted']),
      createdAt: StrTools.tryParse(json, keys: ['created_at', 'createdAt']),
      updatedAt: StrTools.tryParse(json, keys: ['updated_at', 'updatedAt']),
      details: {...Map<String, dynamic>.from(json['details'] ?? {}), ...detailsObj},
    );
  }

  Map<String, dynamic> toMap()=> toJson();
  
  Map<String, dynamic> toJson({UserStDT userStDT = UserStDT.BLOCK}) {
    return {
      'id': id,
      'user_id':id,
      'full_name': name,
      'role_name': role,
      'email': email,
      'phone_number': phoneNumber,
      'img_url': imgUrl,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
      
      if([UserStDT.BLOCK, UserStDT.BOTH].contains(userStDT)) 'details': details,
      if([UserStDT.EXTRACT, UserStDT.BOTH].contains(userStDT)) ...details,
    };
  }
  
  User copy([User? user])
  {
    // if(user != null)
    // {
      return User(
        id: (user?.id ?? 0) > 0 ? user!.id : id,
        name: (user?.name ?? '').isNotEmpty? user!.name : name,
        role: (user?.role ?? '').isNotEmpty? user!.role : role,
        email: (user?.email ?? '').isNotEmpty? user!.email : email,
        phoneNumber: (user?.phoneNumber ?? '').isNotEmpty? user!.phoneNumber : phoneNumber,
        imgUrl: (user?.imgUrl ?? '').isNotEmpty? user!.imgUrl : imgUrl,
        isActive: user?.isActive ?? isActive,
        isDeleted: user?.isDeleted ?? isDeleted,
        createdAt: (user?.createdAt ?? '').isNotEmpty? user!.createdAt : createdAt,
        updatedAt: (user?.updatedAt ?? '').isNotEmpty? user!.updatedAt : updatedAt,
        details: (user?.details ?? {}).isNotEmpty? user!.details
          .map((k, v)=> MapEntry(
            k, 
            (v != null && (
                ((v is String || v is Iterable || v is Map) && v.isNotEmpty) || 
                (v is num && v > 0) || 
                (v is! String && v is! num && v is! Iterable && v is! Map))
            )?
              v : details[k]))
          : details,
      );
    // }
  }
  
  User copyWith({
    int? id,
    String? name,
    String? role,
    String? email,
    String? phoneNumber,
    String? imgUrl,
    bool? isActive,
    bool? isDeleted,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? details,
  })
  {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imgUrl: imgUrl ?? this.imgUrl,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      details: {...this.details, ...(details ?? {})},
    );
  }

  T cast<T extends User>()=> this as T;
  
  @override
  List<Object?> get props => [
        id,
        role,
        name,
        email,
        phoneNumber,
        imgUrl,
        isActive,
        isDeleted,
        createdAt,
        updatedAt,
        details,
      ];

  String toJsonAndEncode({UserStDT userStDT = UserStDT.BLOCK}) => jsonEncode(toJson(userStDT: userStDT));
  @override
  String toString() => toJson().toString();
}