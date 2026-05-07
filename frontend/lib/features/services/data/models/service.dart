import 'package:equatable/equatable.dart';
import '../../../suppliers/data/models/supplier.dart';

class Service extends Equatable {
  final int id;
  final String serviceName;
  final String? description;
  final String? createdAt;
  final bool isDeleted;
  final List _suppliers;

  List<Supplier> get suppliers => _suppliers.map((e) => Supplier.fromJson(e)).toList();

  const Service({
    required this.id,
    required this.serviceName,
    required this.isDeleted,
    this.description,
    this.createdAt,
    List suppliers = const [],
  }): this._suppliers = suppliers;

  Service assignAllSuppliers(List<Supplier> suppliers) {
    _suppliers.clear();
    _suppliers.addAll(suppliers.map((e) => e.toJson()).toList());
    return this;
  }
  
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['service_id'] ?? json['id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      description: json['description'],
      createdAt: json['created_at'],
      isDeleted: json['is_deleted'] ?? false,
      suppliers: json['suppliers'] != null ? List<dynamic>.from(json['suppliers']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_name': serviceName,
      'description': description,
      'is_deleted': isDeleted,
      'created_at': createdAt,
      'suppliers': _suppliers,
    };
  }

  @override
  List<Object?> get props => [
        id,
        serviceName,
        description,
        createdAt,
        suppliers,
        isDeleted,
      ];
}