import 'package:get/get.dart';
import '../models/coordinator.dart' show Coordinator;
import '../../provider/coordinator_provider.dart' show CoordinatorProvider;
import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';

class CoordinatorRepository 
{
  final CoordinatorProvider _provider = Get.find<CoordinatorProvider>();

  Future<ApiResult<List<Coordinator>>> getAll() async 
  {
    try {
      final data = await _provider.getAll();
      return ApiResult.success(data.map((e) => Coordinator.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Coordinator>> getById(int id) async 
  {
    try {
      final data = await _provider.getById(id);
      return ApiResult.success(Coordinator.fromJson(data));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Coordinator>> create(dynamic data) async 
  {
    try {
      final response = await _provider.create(data);
      return ApiResult.success(Coordinator.fromJson(response['user'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Coordinator>> update(int id, dynamic data) async 
  {
    try {
      final response = await _provider.update(id, data);
      return ApiResult.success(Coordinator.fromJson(response['user'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> delete(int id) async 
  {
    try {
      await _provider.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<dynamic>>> getNotifications(int id) async 
  {
    try {
      final data = await _provider.getNotifications(id);
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<List<dynamic>>> getNotification(int id, int notificationId) async 
  {
    try {
      final data = await _provider.getNotification(id, notificationId);
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deleteNotification(int id, int notificationId) async
  {
    try {
      await _provider.deleteNotification(id, notificationId);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
  
  Future<ApiResult<void>> clearAllNotifications(int id) async
  {
    try {
      await _provider.clearAllNotifications(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> toggleStatus(int id, bool isActive) async {
    try {
      await _provider.toggleStatus(id, isActive);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
