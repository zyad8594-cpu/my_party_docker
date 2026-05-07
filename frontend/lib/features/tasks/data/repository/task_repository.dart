import 'package:get/get.dart';

import '../models/task.dart';
import '../../provider/task_provider.dart' show TaskProvider;
import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';

class TaskRepository 
{
  final TaskProvider _apiProvider = Get.find<TaskProvider>();

  Future<ApiResult<List<Task>>> getAll() async 
  {
    try {
      final data = await _apiProvider.getAll();
      return ApiResult.success(data.map((e) => Task.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Task>> getById(int id) async 
  {
    try {
      final data = await _apiProvider.getById(id);
      return ApiResult.success(Task.fromJson(data));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Task>> create(Map<String, dynamic> data) async 
  {
    try {
      final response = await _apiProvider.create(data);
      return ApiResult.success(Task.fromJson(response['result'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Task>> update(int id, Map<String, dynamic> data) async 
  {
    try {
      final response = await _apiProvider.update(id, data);
      return ApiResult.success(Task.fromJson(response['result'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> delete(int id) async 
  {
    try {
      await _apiProvider.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> updateTaskStatus(int id, dynamic data) async 
  {
    try {
      final response = await _apiProvider.updateTaskStatus(id, data);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
  
  Future<ApiResult<Map<String, dynamic>>> rate(int id, int value, String? comment) async 
  {
    try {
      final response = await _apiProvider.rate(id, value, comment);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> addTaskReminder(int id, Map<String, dynamic> data) async 
  {
    try {
      final response = await _apiProvider.addTaskReminder(id, data);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> updateTaskReminder(int id, Map<String, dynamic> data) async 
  {
    try {
      final response = await _apiProvider.updateTaskReminder(id, data);
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> deleteTaskReminder(int id) async 
  {
    try {
      await _apiProvider.deleteTaskReminder(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
