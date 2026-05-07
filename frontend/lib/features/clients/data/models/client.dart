
import '../../../../core/utils/bool_toolse.dart';
import '../../../../core/utils/number_toolse.dart';
import '../../../../core/utils/string_toolse.dart';
import '../../../../data/models/user.dart';

class Client extends User
{
  String? get address => details['address'];
  // set address(String? value) => details['address'] = value;
  int get coordinatorId => details['coordinator_id'] ?? details['coordinatorId'];
  // set coordinatorId(int value) => details['coordinator_id'] = value;

  @override
  String get phoneNumber => super.phoneNumber ?? '';
  
  Client({
    required super.id, 
    required int coordinatorId,
    required super.name, 
    super.email,
    required String phoneNumber, 
    super.imgUrl, 
    super.isActive,
    super.isDeleted,
    super.createdAt,
    super.updatedAt,
    String? address,
    Map<String, dynamic> details = const {},
  }): super(role: 'CLIENT', phoneNumber: phoneNumber, details: {
    ...details,
    'coordinator_id': coordinatorId,
    'address': address,
  });

  factory Client.fromJson(dynamic json) {
    return Client(
      id: NumberTools.tryParseInt(json, keys: [
        'id', 'user_id', 'client_id',
        'userId', 'clientId'
      ]),
      coordinatorId: NumberTools.tryParseInt(json, keys: [
        'coordinator_id', 'coordinatorId',
      ]),
        name: StrTools.tryParse(json, keys: [
        'name', 'full_name', 'user_name', 'client_name',
        'fullName', 'clientName', 'userName',
        'userFullName', 'clientFullName',
        'user_full_name', 'client_full_name',
      ]),
      email: StrTools.tryParse(json, keys: [
        'email', 'user_email', 'client_email',
        'userEmail', 'clientEmail'
      ]),
      phoneNumber: StrTools.tryParse(json, keys: [
        'phone', 'phone_number', 'user_phone', 'client_phone',
        'userPhone', 'clientPhone', 'phoneNumber',
        'user_phone_number', 'client_phone_number',
        'userPhoneNumber', 'clientPhoneNumber'
      ]),
      imgUrl: StrTools.tryParse(json, keys: [
        'img_url', 'imgUrl', 'user_img_url', 'client_img_url',
        'userImgUrl', 'clientImgUrl'
      ]),
      isActive: BoolTools.tryParse(json, keys: [
        'is_active', 'isActive', 'user_is_active', 'client_is_active',
        'userIsActive', 'clientIsActive'
      ]),
      isDeleted: BoolTools.tryParse(json, keys: [
        'is_deleted', 'isDeleted', 'user_is_deleted', 'client_is_deleted',
        'userIsDeleted', 'clientIsDeleted'
      ]),
      address: StrTools.tryParse(json, keys: [
        'address', 'user_address', 'client_address',
        'userAddress', 'clientAddress'
      ]),
      createdAt: StrTools.tryParse(json, keys: [
        'created_at', 'createdAt', 'user_created_at', 'client_created_at',
        'userCreatedAt', 'clientCreatedAt'
      ]),
      updatedAt: StrTools.tryParse(json, keys: [
        'updated_at', 'updatedAt', 'user_updated_at', 'client_updated_at',
        'userUpdatedAt', 'clientUpdatedAt'
      ]),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  @override
  toJson({UserStDT userStDT = UserStDT.BLOCK}) {
    return {
      ...super.toJson(userStDT: UserStDT.NONE), 
      'phone_number': phoneNumber,
      if([UserStDT.BLOCK, UserStDT.BOTH].contains(userStDT)) 'details': {...details, 'coordinator_id': coordinatorId, 'address': address}
      else if([UserStDT.EXTRACT, UserStDT.BOTH].contains(userStDT)) ...{...details, 'coordinator_id': coordinatorId, 'address': address}
      else ...{'coordinator_id': coordinatorId, 'address': address},
    };
  }

  @override
  Client copyWith({
    int? id,
    int? coordinatorId,
    String? name,
    String? role,
    String? email,
    String? phoneNumber,
    String? imgUrl,
    bool? isActive,
    bool? isDeleted,
    String? createdAt,
    String? updatedAt,
    String? address,
    Map<String, dynamic>? details,
  }) {
    details = {
      ...(details ?? this.details), 
      'coordinator_id': coordinatorId ?? this.coordinatorId, 
      'address': address ?? this.address
    };
    return Client(
      id: id ?? this.id,
      coordinatorId: details['coordinator_id'],
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imgUrl: imgUrl ?? this.imgUrl,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: details['address'],
      details: details,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        address,
      ];
}
