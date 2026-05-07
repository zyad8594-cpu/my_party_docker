import 'package:get/get.dart';
import '../models/service.dart';
import '../models/service_request.dart';
import '../../provider/service_provider.dart' show ServiceProvider;
import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';

class ServiceRepository {
  final ServiceProvider _serviceProvider = Get.find<ServiceProvider>();

  Future<ApiResult<List<Service>>> getAll() async 
  {
    try {
      final data = await _serviceProvider.getAll();
      return ApiResult.success(data.map((e) => Service.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Service>> getById(int id) async 
  {
    try {
      final data = await _serviceProvider.getById(id);
      return ApiResult.success(Service.fromJson(data));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Service>> create(Map<String, dynamic> data) async 
  {
    try {
      final response = await _serviceProvider.create(data);
      return ApiResult.success(Service.fromJson(response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Service>> update(int id, Map<String, dynamic> data) async 
  {
    try {
      final response = await _serviceProvider.update(id, data);
      return ApiResult.success(Service.fromJson(response['result'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> delete(int id) async 
  {
    try {
      await _serviceProvider.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<ServiceRequest>>> getAllRequests() async 
  {
    try {
      final data = await _serviceProvider.getAllRequests();
      return ApiResult.success(data.map((e) => ServiceRequest.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<ServiceRequest>>> getMyRequests() async 
  {
    try {
      final data = await _serviceProvider.getMyRequests();
      return ApiResult.success(data.map((e) => ServiceRequest.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> updateRequestStatus(int id, String status) async 
  {
    try {
      await _serviceProvider.updateRequestStatus(id, status);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Service>> approveRequest(int id, Map<String, dynamic> data) async 
  {
    try {
      final response = await _serviceProvider.approveRequest(id, data);
      return ApiResult.success(Service.fromJson(response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> withdrawRequest(int id) async 
  {
    try {
      await _serviceProvider.withdrawRequest(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
