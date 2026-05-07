import 'package:get/get.dart';
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiEndpoints;
import '../../../core/api/api_provider.dart' show ApiProvider;

class CoordinatorProvider extends ApiProvider 
{
  CoordinatorProvider():super(Get.find<ApiService>());

  
  @override
  Future<List> getAll() async 
  {
    final response = await service.get(ApiEndpoints.coordinators);
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future<Map<String, dynamic>> getById(int id) async
  {
    final response = await service.get("${ApiEndpoints.coordinators}/$id");
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> create(dynamic data) async 
  {
    final response = await service.post(ApiEndpoints.coordinators, data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> update(int id, dynamic data) async
  {
    final response = await service.put("${ApiEndpoints.coordinators}/admin/$id", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future delete(int id) async 
  {
    return await service.delete("${ApiEndpoints.coordinators}/$id");
  }
  


  Future<List<dynamic>> getNotifications(int id) async 
  {
    final response = await service.get(ApiEndpoints.notifications);
    return List<dynamic>.from(response['data'] ?? response);
  }

  Future<List<dynamic>> getNotification(int id, int notificationId) async 
  {
    final response = await service.get("${ApiEndpoints.notifications}/$notificationId");
    return List<dynamic>.from(response['data'] ?? response);
  }


  Future<void> deleteNotification(int id, int notificationId) async
  {
    await service.delete("${ApiEndpoints.notifications}/$notificationId");
  }
  
  
  Future<void> clearAllNotifications(int id) async
  {
    await service.delete(ApiEndpoints.notificationsClear);
  }

  @override
  Future<void> toggleStatus(int id, bool isActive) async {
    await service.put("${ApiEndpoints.users}/$id/set_active", data: {'is_active': isActive});
  }
}