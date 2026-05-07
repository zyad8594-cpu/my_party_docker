import 'package:get/get.dart';
import '../../provider/auth_provider.dart' show AuthProvider;
import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';

class AuthRepository 
{
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  Future<ApiResult<dynamic>> login(String email, String password) async 
  {
    try {
      final response = await _authProvider.login(email, password);
      return ApiResult.success(response['data'] ?? response['result'] ?? response);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> register(dynamic data) async 
  {
    try 
    {
      final response = await _authProvider.register(data);
      return ApiResult.success(response);
    } 
    catch (e) 
    {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<dynamic>> updateProfile(int id, dynamic data) async {

    try {      
      final response = await _authProvider.updateProfile(id, data);
      return ApiResult.success(response['data'] ?? response['result'] ?? response);
    } 
    catch (e) 
    {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<dynamic>> changePassword(int id, String oldPassword, String newPassword) async {
    try {
      final response = await _authProvider.changePassword(id, oldPassword, newPassword);
      return ApiResult.success(response['data'] ?? response['result'] ?? response);
    } 
    catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
  

}
