import 'package:get/get.dart';
import '../../../core/api/api_service.dart' show ApiService;
import '../../../core/api/api_constants.dart' show ApiConstants, ApiEndpoints;

class AuthProvider extends GetxService 
{
  final ApiService _service = Get.find<ApiService>();

  Future<Map<String, dynamic>> login(String email, String password) async 
  {
    
    final response = await _service.post(
      '${ApiConstants.baseUrl}${ApiEndpoints.login}',
      data: {'email': email, 'password': password},
    );
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<Map<String, dynamic>> register(dynamic data) async 
  {
    final response = await _service.post(ApiEndpoints.register, data: data);
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<Map<String, dynamic>> updateProfile(int id, dynamic data) async {
    final response = await _service.put(
      '${ApiEndpoints.users}/$id',
      data: data,
    );
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }

  Future<Map<String, dynamic>> changePassword(int id, String oldPassword, String newPassword) async {
    final response = await _service.put(
      '${ApiEndpoints.userChangePassword}/$id',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
    
    return Map<String, dynamic>.from(response['data'] ?? response['result'] ?? response);
  }
}