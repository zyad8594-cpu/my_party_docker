import 'package:get/get.dart';
import '../../../core/api/api_provider.dart' show ApiProvider;
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiEndpoints;
import '../../../core/api/auth_service.dart' show AuthService;


class TaskProvider extends ApiProvider 
{
  TaskProvider():super(Get.find<ApiService>());

  
  @override
  Future<List> getAll() async 
  {
    final response = await service.get(ApiEndpoints.tasks);
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future<Map<String, dynamic>> getById(int id) async
  {
    final response = await service.get("${ApiEndpoints.tasks}/$id");
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> create(dynamic data) async 
  {
    final response = await service.post(ApiEndpoints.tasks, data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> update(int id, dynamic data) async
  {
    final response = await service.put("${ApiEndpoints.tasks}/$id", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result']?? response);
  }
  
  Future<Map<String, dynamic>> updateTaskStatus(int id, dynamic data) async 
  {
    final response = await service.put("${ApiEndpoints.tasks}/$id/status", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  @override
  Future delete(int id) async 
  {
    return await service.delete("${ApiEndpoints.tasks}/$id");
  }

  Future<Map<String, dynamic>> rate(int id, int value, String? comment) async 
  { 
    final response = await service.post(
        "${ApiEndpoints.tasks}/$id/rating",
        data: {'value_rating': value, 'comment': comment, 'coordinator_id': AuthService.user.value.id},
      );
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response); 
  }

  Future<Map<String, dynamic>> addTaskReminder(int id, Map<String, dynamic> data) async 
  {
    final response = await service.post("${ApiEndpoints.tasks}/$id/reminders", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<Map<String, dynamic>> updateTaskReminder(int id, Map<String, dynamic> data) async 
  {
    final response = await service.put("${ApiEndpoints.tasks}/$id/reminders", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<void> deleteTaskReminder(int id) async 
  {
    await service.delete("${ApiEndpoints.tasks}/$id/reminders");
  }
}