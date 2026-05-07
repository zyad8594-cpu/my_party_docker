import 'package:get/get.dart';
import '../../../core/api/api_provider.dart' show ApiProvider;
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiEndpoints;

class IncomeProvider extends ApiProvider 
{
  IncomeProvider():super(Get.find<ApiService>());

  
  @override
  Future<List> getAll() async   
  {
    final response = await service.get(ApiEndpoints.incomes);
    return List<dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future<Map<String, dynamic>> getById(int id) async
  {
    final response = await service.get("${ApiEndpoints.incomes}/$id");
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> create(dynamic data) async 
  {
    final response = await service.post(ApiEndpoints.incomes, data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> update(int id, dynamic data) async
  {
    final response = await service.put("${ApiEndpoints.incomes}/$id", data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
  
  @override
  Future delete(int id) async 
  {
    return await service.delete("${ApiEndpoints.incomes}/$id");
  }
  
}