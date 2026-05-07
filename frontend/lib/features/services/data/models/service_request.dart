import 'package:equatable/equatable.dart';

import '../../../../core/utils/bool_toolse.dart' show BoolTools;
import '../../../../core/utils/number_toolse.dart' show NumberTools;
import '../../../../core/utils/string_toolse.dart' show StrTools;

class ServiceRequest extends Equatable {
  final int id;
  final int supplierId;
  final String supplierName;
  final String serviceName;
  final String? description;
  final String status;
  final bool isDeleted;
  final String? createdAt;
  final String? supplierEmail;
  final String? supplierPhone;
  final String? supplierAddress;
  final String? supplierImg;

  const ServiceRequest({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.serviceName,
    this.description,
    required this.status,
    required this.isDeleted,
    this.createdAt,
    this.supplierEmail,
    this.supplierPhone,
    this.supplierAddress,
    this.supplierImg,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: NumberTools.tryParseInt(json, keys: ['id']),
      supplierId: NumberTools.tryParseInt(json, keys: ['supplier_id', 'supplierId', 'user_id', 'userId']),
      supplierName: StrTools.tryParse(json, keys: ['supplier_name', 'supplierName'], defaultV: 'غير معروف'),
      serviceName: StrTools.tryParse(json, keys: ['service_name', 'serviceName'], ),
      description: StrTools.tryParse(json, keys: ['description'], ),
      status: StrTools.tryParse(json, keys: ['status'], defaultV: 'PENDING'),
      isDeleted: BoolTools.tryParse(json, keys: ['is_deleted', 'isDeleted'], defaultV: false),
      createdAt: StrTools.tryParse(json, keys: ['created_at', 'createdAt'], ),
      supplierEmail: StrTools.tryParse(json, keys: ['supplier_email', 'supplierEmail'], ),
      supplierPhone: StrTools.tryParse(json, keys: ['supplier_phone', 'supplierPhone'], ),
      supplierAddress: StrTools.tryParse(json, keys: ['supplier_address', 'supplierAddress'], ),
      supplierImg: StrTools.tryParse(json, keys: ['supplier_img', 'supplierImg'], ),
    );
  }

  ServiceRequest copyWith({
    int? id,
    int? supplierId,
    String? supplierName,
    String? serviceName,
    String? description,
    String? status,
    bool? isDeleted,
    String? createdAt,
    String? supplierEmail,
    String? supplierPhone,
    String? supplierAddress,
    String? supplierImg,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      supplierEmail: supplierEmail ?? this.supplierEmail,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      supplierAddress: supplierAddress ?? this.supplierAddress,
      supplierImg: supplierImg ?? this.supplierImg,
    );
  }

  @override
  List<Object?> get props => [
        id,
        supplierId,
        supplierName,
        serviceName,
        description,
        status,
        createdAt,
        supplierEmail,
        supplierPhone,
        supplierAddress,
        supplierImg,
      ];
}
