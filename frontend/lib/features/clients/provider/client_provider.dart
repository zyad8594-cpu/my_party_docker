import 'package:get/get.dart';
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiEndpoints;
import '../../../core/api/api_provider.dart' show ApiProvider;

class ClientProvider extends ApiProvider 
{
  ClientProvider():super(Get.find<ApiService>());

  @override
  Future<List> getAll() async 
  {
    final response = await service.get(ApiEndpoints.clients);
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future<Map<String, dynamic>> getById(int id) async
  {
    final response = await service.get("${ApiEndpoints.clients}/$id");
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<Map<String, dynamic>> create(dynamic data) async 
  {
    final response = await service.post(ApiEndpoints.clients, data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> update(int id, dynamic data) async
  {
    final response = await service.put("${ApiEndpoints.clients}/$id", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future delete(int id) async 
  {
    return await service.delete("${ApiEndpoints.clients}/$id");
  }
  
  @override
  Future<void> restore(int id) async 
  {
    await service.put("${ApiEndpoints.clients}/$id/restore");
  }

  @override
  Future<void> toggleStatus(int id, bool isActive) async {
    await service.put("${ApiEndpoints.clients}/$id/active", data: {'is_active': isActive});
  }
}