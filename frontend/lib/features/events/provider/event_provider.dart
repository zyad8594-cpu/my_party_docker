import 'package:get/get.dart';
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiEndpoints;
import '../../../core/api/api_provider.dart' show ApiProvider;

class EventProvider extends ApiProvider 
{
  EventProvider():super(Get.find<ApiService>());

  
  @override
  Future<List> getAll() async 
  {
    final response = await service.get(ApiEndpoints.events);
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future<Map<String, dynamic>> getById(int id) async
  {
    final response = await service.get("${ApiEndpoints.events}/$id");
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> create(dynamic data) async 
  {
    final response = await service.post(ApiEndpoints.events, data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> update(int id, dynamic data) async
  {
    final response = await service.put("${ApiEndpoints.events}/$id", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  Future<void> updateStatus(int id, String status) async 
  {
    await service.put("${ApiEndpoints.events}/$id/status", data: {'status': status});
  }
  
  @override
  Future delete(int id) async 
  {
    return await service.delete("${ApiEndpoints.events}/$id");
  }
  
}