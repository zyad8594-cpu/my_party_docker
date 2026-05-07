import 'package:get/get.dart';
import 'api_service.dart' show ApiService;

abstract class ApiProvider extends GetxService 
{
  final ApiService service;
  ApiProvider([ApiService? service]) : this.service = service ?? Get.find<ApiService>();

  Future<List<dynamic>> getAll();

  Future<Map<String, dynamic>> getById(int id);

  Future<Map<String, dynamic>> create(dynamic data);

  Future<Map<String, dynamic>> update(int id,dynamic data);

  Future<dynamic> delete(int id);
  
  Future<void> restore(int id) async {
    throw UnimplementedError('restore not implemented');
  }

  Future<void> toggleStatus(int id, bool isActive) async {
    throw UnimplementedError('toggleStatus not implemented');
  }
  
}