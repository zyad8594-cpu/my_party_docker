import '../../../../core/utils/string_toolse.dart';

import '../../../../core/utils/bool_toolse.dart';
import '../../../../core/utils/number_toolse.dart';
import '../../../../data/models/user.dart';

class Coordinator extends User
{
  String get password => details['password'] ?? ''; 
  
  @override
  String get email => super.email ?? '';

  Coordinator({
    required super.id,
    required super.name,
    required String email,
    super.phoneNumber,
    super.imgUrl,
    required String password,
    super.isActive,
    super.isDeleted,
    super.createdAt,
    super.updatedAt,
    Map<String, dynamic> details = const {},
  }): super(role: 'COORDINATOR', email: email, details: {
    ...details,
    'password': password,
  });
  

  factory Coordinator.fromJson(dynamic json) {
    return Coordinator(
      id: NumberTools.tryParseInt(json, keys: [
        'id', 'user_id', 'coordinator_id',
        'userId', 'coordinatorId',
      ]),
      name: StrTools.tryParse(json, keys: [
        'name', 'full_name', 'user_name', 'coordinator_name',
        'fullName', 'coordinatorName', 'userName',
        'userFullName', 'coordinatorFullName', 
        'user_full_name', 'coordinator_full_name',
      ]),
      phoneNumber: StrTools.tryParse(json, keys: [
        'phone', 'phone_number', 'user_phone', 'coordinator_phone',
        'userPhone', 'coordinatorPhone', 'phoneNumber',
        'user_phone_number', 'coordinator_phone_number',
        'userPhoneNumber', 'coordinatorPhoneNumber'
      ]),
      email: StrTools.tryParse(json, keys: [
        'email', 'user_email', 'coordinator_email',
        'userEmail', 'coordinatorEmail', 'email',
      ]),
      password: StrTools.tryParse(json, keys: [
        'password', 'user_password', 'coordinator_password',
        'userPassword', 'coordinatorPassword'
      ]),
      imgUrl: StrTools.tryParse(json, keys: [
        'imgUrl', 'img_url', 'user_img', 'coordinator_img',
        'userImg', 'coordinatorImg', 'imgUrl',
        'user_img_url', 'coordinator_img_url',
        'userImgUrl', 'coordinatorImgUrl',
      ]),
      createdAt: StrTools.tryParse(json, keys: [
        'created_at', 'createdAt', 'user_created_at', 'coordinator_created_at',
        'userCreatedAt', 'coordinatorCreatedAt', 'createdAt',
      ]),
      updatedAt: StrTools.tryParse(json, keys: [
        'updated_at', 'updatedAt', 'user_updated_at', 'coordinator_updated_at',
        'userUpdatedAt', 'coordinatorUpdatedAt', 'updatedAt',
      ]),
      isActive: NumberTools.tryParse(json, keys: [
        'is_active', 'isActive', 'user_is_active', 'coordinator_is_active',
        'userIsActive', 'coordinatorIsActive'
      ]) != 0,
      isDeleted: BoolTools.tryParse(json, keys: [
        'is_deleted', 'isDeleted', 'user_is_deleted', 'coordinator_is_deleted',
        'userIsDeleted', 'coordinatorIsDeleted'
      ]),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  @override
  toJson({UserStDT userStDT = UserStDT.BLOCK}) {
    return {
      ...super.toJson(userStDT: UserStDT.NONE), 
      'email': email,
      if([UserStDT.BLOCK, UserStDT.BOTH].contains(userStDT)) ...{'details': details, 'password': password}
      else if([UserStDT.EXTRACT, UserStDT.BOTH].contains(userStDT)) ...{...details, 'password': password}
      else ...{'password': password},
    };
  }
  
  @override
  Coordinator copyWith({
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
    String? password,
    Map<String, dynamic>? details,
  }) {
    details = {...(details ?? this.details), 'password': password ?? this.password};
    
    return Coordinator(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      email: email ?? this.email,
      password: details['password'],
      imgUrl: imgUrl ?? this.imgUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      details: details,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
      ];
}
