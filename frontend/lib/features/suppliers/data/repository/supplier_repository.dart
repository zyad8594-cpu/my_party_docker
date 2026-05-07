import 'package:get/get.dart';
import '../../../services/data/models/service_request.dart';

import '../models/supplier.dart';
import '../../provider/supplier_provider.dart' show SupplierProvider;
import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';

class SupplierRepository 
{
  final SupplierProvider _supplierProvider = Get.find<SupplierProvider>();

  Future<ApiResult<List<Supplier>>> getAll() async 
  {
    try {
      final data = await _supplierProvider.getAll();

      return ApiResult.success(data.map((supplierJson) => Supplier.fromJson(supplierJson)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<Supplier>>> getAllByServiceId(int serviceId) async 
  {
    try {
      final data = await _supplierProvider.getAllByServiceId(serviceId);
      return ApiResult.success(data.map((supplierJson) => Supplier.fromJson(supplierJson)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Supplier>> getById(int id) async 
  {
    try {
      final data = await _supplierProvider.getById(id);
      return ApiResult.success(Supplier.fromJson(data));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Supplier>> create(Map<String, dynamic> data) async 
  {
    try {
      final response = await _supplierProvider.create(data);
      return ApiResult.success(Supplier.fromJson(response['user'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Supplier>> update(int id, data) async 
  {
    try {
      final response = await _supplierProvider.update(id, data);
      return ApiResult.success(Supplier.fromJson(response['user'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> delete(int id) async 
  {
    try {
      await _supplierProvider.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> assignServiceToSupplier(int supplierId, int serviceId) async
  {
    try {
      await _supplierProvider.assignServiceToSupplier(supplierId, serviceId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deleteService(int id, int serviceId) async
  {
    try {
      await _supplierProvider.deleteService(id, serviceId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
  
  Future<ApiResult<void>> clearAllServices(int id) async
  {
    try {
      await _supplierProvider.clearAllServices(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<int>> proposeService(int supplierId, String serviceName, String description) async {
    try {
      final response = await _supplierProvider.proposeService(supplierId, serviceName, description);
      return ApiResult.success(response['requestId']);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<ServiceRequest>>> getMyProposals() async {
    try {
      final response = await _supplierProvider.getMyProposals();
      return ApiResult.success(response.map((e) => ServiceRequest.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<dynamic>>> getMyServices() async {
    try {
      final response = await _supplierProvider.getMyServices();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> withdrawProposal(int id) async {
    try {
      await _supplierProvider.withdrawProposal(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<dynamic>>> getNotifications(int id) async 
  {
    try {
      final data = await _supplierProvider.getNotifications(id);
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<dynamic>>> getNotification(int id, int notificationId) async 
  {
    try {
      final data = await _supplierProvider.getNotification(id, notificationId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deleteNotification(int id, int notificationId) async
  {
    try {
      await _supplierProvider.deleteNotification(id, notificationId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
  
  Future<ApiResult<void>> clearAllNotifications(int id) async
  {
    try {
      await _supplierProvider.clearAllNotifications(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> toggleStatus(int id, bool isActive) async {
    try {
      await _supplierProvider.toggleStatus(id, isActive);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
