import 'package:flutter/material.dart';

import '../../../../core/utils/number_toolse.dart';
import '../../../../core/utils/string_toolse.dart';
import '../../../../data/models/user.dart';
import '../../../services/data/models/service.dart' show Service;
import '../../../tasks/data/models/task.dart';

class Supplier extends User
{
  String get password => details['password'];
  String? get address => details['address'];
  String? get notes => details['notes'];
  double? get averageRating => details['average_rating'] ?? details['averageRating'];
  
  List<Service> get services{
    final s = details['services'];
    try {
      return switch(s){
        List<Map<String, dynamic>>()=> s.map((e) => Service.fromJson(e)).toList(),
        List<Service>()=> s,
        _=> []
      };
    } catch(e){
      debugPrint(e.toString());
      return [];
    }
  }

  // set services(List<Service> _services){
  //   details['services'] = _services.map((e) => e.toJson()).toList();
  // }
  // List<int> get serviceIds => details['services'].map((e) => NumberTools.tryParseInt(e, keys: ['id', 'service_id', 'serviceId'])).toList();  
  
  List<Task> get tasks
  {
    final tk = details['tasks'];
    try {
      return switch(tk){
        List<Map<String, dynamic>>()=> tk.map((e)=>Task.fromJson(e)).toList(),
        List<Task>()=> tk,
        _=> []
      };
    } catch(e){
      debugPrint(e.toString());
      return [];
    }
  }
  
  // set tasks(List<Task> _tasks){
  //   details['tasks'] = _tasks.map((e) => e.toJson()).toList();
  // }
  
  // List<int> get taskIds => details['tasks'].map((e) => NumberTools.tryParseInt(e, keys: ['id', 'task_id', 'taskId'])).toList();

  @override
  String get email => super.email ?? '';

  Supplier({
    required super.id,
    required super.name,
    required String email,
    super.phoneNumber,
    super.imgUrl,
    super.isActive = false,
    super.isDeleted = false,
    super.createdAt = '',
    super.updatedAt = '',
    required String password,
    String? address,
    String? notes,
    double? averageRating,
    List services = const [],
    List tasks = const [],
    Map<String, dynamic> details = const {},
  }): super(role: 'SUPPLIER', email: email, details: {
      ...details,
      'password': password,
      'address': address,
      'notes': notes,
      'average_rating': averageRating,
      'services': services,
      'tasks': tasks,
    });
  
  factory Supplier.fromJson(dynamic json) {
    return Supplier(
      id: NumberTools.tryParseInt(json, keys: [
        'id', 'supplier_id', 'user_id',
        'supplierId', 'userId'
      ]),
      imgUrl: StrTools.tryParse(json, keys: [
        'img_url', 'imgUrl', 'user_img', 'supplier_img',
        'userImg', 'supplierImg', 'imgUrl',
        'user_img_url', 'supplier_img_url',
        'userImgUrl', 'supplierImgUrl'
      ]),
      name: StrTools.tryParse(json, keys: [
        'name', 'full_name', 'user_name', 'supplier_name',
        'fullName', 'supplierName', 'userName',
        'userFullName', 'supplierFullName',
        'user_full_name', 'supplier_full_name'
      ]),
      email: StrTools.tryParse(json, keys: [
        'email', 'user_email', 'supplier_email',
        'userEmail', 'supplierEmail', 'email',
      ]),
      password: StrTools.tryParse(json, keys: [
        'password', 'user_password', 'supplier_password',
        'userPassword', 'supplierPassword'
      ]),
      phoneNumber: StrTools.tryParse(json, keys: [
        'phone', 'phone_number', 'user_phone', 'supplier_phone',
        'userPhone', 'supplierPhone', 'phoneNumber',
        'user_phone_number', 'supplier_phone_number',
        'userPhoneNumber', 'supplierPhoneNumber'
      ]),
      address: StrTools.tryParse(json, keys: [
        'address', 'user_address', 'supplier_address',
        'userAddress', 'supplierAddress'
      ]),
      notes: StrTools.tryParse(json, keys: [
        'notes', 'user_notes', 'supplier_notes',
        'userNotes', 'supplierNotes'
      ]),
      createdAt: StrTools.tryParse(json, keys: [
        'created_at', 'createdAt', 'user_created_at', 'supplier_created_at',
        'userCreatedAt', 'supplierCreatedAt'
      ]),
      isActive: NumberTools.tryParse(json, keys: [
        'is_active', 'isActive', 'user_is_active', 'supplier_is_active',
        'userIsActive', 'supplierIsActive'
      ]) != 0,
      isDeleted: NumberTools.tryParse(json, keys: [
        'is_deleted', 'isDeleted', 'user_is_deleted', 'supplier_is_deleted',
        'userIsDeleted', 'supplierIsDeleted'
      ]) != 0,
      averageRating: NumberTools.tryParseDouble(json, keys: ['average_rating', 'averageRating', 'rating']),
      services: json['services'] ?? [],
      tasks: json['tasks'] ?? [],
    );
  }

  @override
  toJson({UserStDT userStDT = UserStDT.BLOCK}) {
    return {
      ...super.toJson(userStDT: UserStDT.NONE),
      if([UserStDT.BLOCK, UserStDT.BOTH].contains(userStDT)) ...{
        'details': details,
        'password': password,
        'address': address,
        'notes': notes,
        'average_rating': averageRating,
        'services': services.map((e) => e.toJson()).toList(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
      }
      else if([UserStDT.EXTRACT, UserStDT.BOTH].contains(userStDT)) ...{
        ...details,
        'password': password,
        'address': address,
        'notes': notes,
        'average_rating': averageRating,
        'services': services.map((e) => e.toJson()).toList(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
      }
      else ...{
        'password': password,
        'address': address,
        'notes': notes,
        'average_rating': averageRating,
        'services': services.map((e) => e.toJson()).toList(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
      },
    };
  }

  @override
  Supplier copyWith({
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
    String? address,
    String? notes,
    double? averageRating,
    List<Service>? services,
    List<Task>? tasks,
    Map<String, dynamic>? details,
  }) {
    details = {
      ...(details ?? this.details), 
      'password': password ?? this.password,
      'address': address ?? this.address,
      'notes': notes ?? this.notes,
      'average_rating': averageRating ?? this.averageRating,
      'services': (services ?? this.services).map((e) => e.toJson()).toList(),
      'tasks': (tasks ?? this.tasks).map((e) => e.toJson()).toList(),
    };
    return Supplier(
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
      address: details['address'],
      notes: details['notes'],
      averageRating: details['average_rating'],
      services: details['services'],
      tasks: details['tasks'],
      details: details,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        password,
        address,
        notes,
        averageRating,
        services,
        tasks,
        // serviceIds,
        // taskIds,
      ];
}
