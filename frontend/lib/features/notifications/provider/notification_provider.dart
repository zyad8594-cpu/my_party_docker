import 'package:get/get.dart';
import '../../../core/api/api_provider.dart' show ApiProvider;
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiEndpoints;

class NotificationProvider extends ApiProvider 
{
  NotificationProvider():super(Get.find<ApiService>());

  @override
  Future<List<dynamic>> getAll() async 
  {
    final response = await service.get(ApiEndpoints.notifications);
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> getById(int id) async
  {
    final response = await service.get("${ApiEndpoints.notifications}/$id");
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> create(dynamic data) async 
  {
    final response = await service.post(ApiEndpoints.notifications, data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> update(int id, dynamic data) async
  {
    final response = await service.put("${ApiEndpoints.notifications}/$id", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future delete(int id) async 
  {
    return await service.delete("${ApiEndpoints.notifications}/$id");
  }

  Future markAsRead(int id) async 
  {
    return await service.put("${ApiEndpoints.notifications}/$id", data: {});
  }

  Future markAllAsRead() async 
  {
    // Matches PUT /api/users/notifications-read-all
    return await service.put(ApiEndpoints.notificationsReadAll, data: {});
  }

  Future clearAll() async 
  {
    return await service.delete(ApiEndpoints.notifications);
  }
}