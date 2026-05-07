import 'package:get/get.dart';
import '../../../core/api/api_provider.dart' show ApiProvider;
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiEndpoints;
import '../../../core/api/auth_service.dart' show AuthService;

class SupplierProvider extends ApiProvider 
{
  SupplierProvider():super(Get.find<ApiService>());

  
  @override
  Future<List> getAll() async 
  {
    if(AuthService.user.value.role == 'coordinator')
    {
      final response = await service.get(ApiEndpoints.suppliers);
      return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
    }
    else
    {
      final response = await service.get(ApiEndpoints.suppliers);
      return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
    }
  }
  
  @override
  Future<Map<String, dynamic>> getById(int id) async
  {
    final response = await service.get("${ApiEndpoints.suppliers}/$id");
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> create(dynamic data) async 
  {
    final response = await service.post(ApiEndpoints.suppliers, data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> update(int id,  data) async
  {
    final response = await service.put("${ApiEndpoints.suppliers}/$id", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future delete(int id) async 
  {
    return await service.delete("${ApiEndpoints.suppliers}/$id");
  }





  Future<List<dynamic>> getAllByServiceId(int serviceId) async 
  {
    final response = await service.get("${ApiEndpoints.suppliers}/${ApiEndpoints.services}/$serviceId");
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<Map<String, dynamic>> getByIdAndServiceId(int id, int serviceId) async 
  {
    final response = await service.get("${ApiEndpoints.suppliers}/$id/${ApiEndpoints.services}/$serviceId");
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<void> assignServiceToSupplier(int supplierId, int serviceId) async
  {
    await service.post("${ApiEndpoints.suppliers}/assign-service", data: {'supplier_id': supplierId, 'service_id': serviceId});
  }

  Future<void> deleteService(int supplierId, int serviceId) async
  {
    await service.post("${ApiEndpoints.suppliers}/remove-service", data: {'supplier_id': supplierId, 'service_id': serviceId});
  }
  
  Future<void> clearAllServices(int id) async
  {
    // If the backend support clearing all, use it. Otherwise, this might need a loop or a specific endpoint.
    // For now, let's keep it as delete but ensure the route exists or just use a placeholder.
    await service.delete("${ApiEndpoints.suppliers}/$id/${ApiEndpoints.services}");
  }

  Future<dynamic> proposeService(int supplierId, String serviceName, String description) async {
    final response = await service.post(ApiEndpoints.serviceRequests, data: {
      'service_name': serviceName,
      'description': description,
    });
    return response['data'] ?? response['result'] ?? response;
  }
  
  Future<List> getMyProposals() async {
    final response = await service.get("${ApiEndpoints.serviceRequests}/my");
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<List> getMyServices() async {
    final response = await service.get('${ApiEndpoints.suppliers}/my-services');
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<void> withdrawProposal(int id) async {
    await service.delete("${ApiEndpoints.serviceRequests}/$id/withdraw");
  }


  Future<List<dynamic>> getNotifications(int id) async 
  {
    final response = await service.get(ApiEndpoints.notifications);
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<List<dynamic>> getNotification(int id, int notificationId) async 
  {
    final response = await service.get("${ApiEndpoints.notifications}/$notificationId");
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
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