import 'package:get/get.dart';
import '../../../core/api/api_provider.dart' show ApiProvider;
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiEndpoints;

class ServiceProvider extends ApiProvider 
{
  ServiceProvider():super(Get.find<ApiService>());

  Map<String, dynamic> getSingleResponse(dynamic response) {
    if (response is Map) {
      if (response.containsKey('data') && response['data'] is Map && (response['data'] as Map).containsKey('result')) {
        return Map<String, dynamic>.from(response['data']['result']);
      }
      if (response.containsKey('result') && response['result'] is Map && (response['result'] as Map).containsKey('data')) {
        return Map<String, dynamic>.from(response['result']['data']);
      }
      if (response.containsKey('data') && response['data'] is Map) {
         return Map<String, dynamic>.from(response['data']);
      }
      if (response.containsKey('result') && response['result'] is Map) {
         return Map<String, dynamic>.from(response['result']);
      }
      return Map<String, dynamic>.from(response);
    }
    return {};
  }
    
  List<dynamic> getMultiResponse(dynamic response) {
    return List<dynamic>.from(
      response['data'] ??
      response['result'] ??
      response
    );
  }
  
  @override
  Future<List> getAll() async 
  {
    final response = await service.get(ApiEndpoints.services);
    return getMultiResponse(response);
  }
  
  @override
  Future<Map<String, dynamic>> getById(int id) async
  {
    final response = await service.get("${ApiEndpoints.services}/$id");
    return getSingleResponse(response);
  }

  @override
  Future<Map<String, dynamic>> create(dynamic data) async 
  {
    final response = await service.post(ApiEndpoints.services, data: data);
    return getSingleResponse(response);
  }

  @override
  Future<Map<String, dynamic>> update(int id, dynamic data) async
  {
    final response = await service.put("${ApiEndpoints.services}/$id", data: data);
    return getSingleResponse(response);
  }
  
  @override
  Future delete(int id) async 
  {
    return await service.delete("${ApiEndpoints.services}/$id");
  }

  Future<List> getAllRequests() async 
  {
    final response = await service.get("${ApiEndpoints.serviceRequests}/all");
    return getMultiResponse(response);
  }

  Future<List> getMyRequests() async 
  {
    final response = await service.get("${ApiEndpoints.serviceRequests}/my");
    return getMultiResponse(response);
  }

  Future<Map<String, dynamic>> updateRequestStatus(int id, String status) async
  {
    final response = await service.put("${ApiEndpoints.serviceRequests}/$id/status", data: {'status': status});
    return getSingleResponse(response);
  }

  Future<Map<String, dynamic>> approveRequest(int id, dynamic data) async
  {
    final response = await service.post("${ApiEndpoints.serviceRequests}/$id/approve", data: data);
    return getSingleResponse(response);
  }

  Future<void> withdrawRequest(int id) async
  {
    await service.delete("${ApiEndpoints.serviceRequests}/$id/withdraw");
  }
}