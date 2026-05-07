import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart' as dio;
import '../errors/exceptions.dart';
import '../services/config_service.dart';
import 'auth_service.dart' show AuthService;

class ApiService extends GetxService 
{
  late final dio.Dio _dio;
  // String? _token;
  /*
    dio.options.headers['User-Agent'] = 'MyPartyApp/1.0.0 (Android; 13)';
   */
  Future<ApiService> init() async 
  {
    final config = Get.find<ConfigService>();
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: config.baseUrl.value,
    // يمكن ضبط timeouts أخرى أيضًا
        sendTimeout: const Duration(seconds: 10),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: <String, dynamic>
        {
          'Accept': 'application/json',
          'user-agent': 'my_party_pro',
        },
      )
    );

    // Watch for base URL changes
    ever(config.baseUrl, (String newUrl) {
      _dio.options.baseUrl = newUrl;
    });

    // Optional: Add logging interceptor for debugging
    // _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    return this;
  }

  // void setToken(String token) 
  // {
  //   _token = token;
  // }

  // void clearToken() 
  // {
  //   _token = null;
  // }

  dio.Options _getOptions() 
  {
    // debugPrint("Token: $_token");
    return dio.Options(
      headers: 
      {
        if (AuthService.token.isNotEmpty) 'Authorization': 'Bearer ${AuthService.token}',
      },
    );
  }

  Future<dynamic> get(String endpoint) async 
  {
    try 
    {
      final response = await _dio.get(endpoint, options: _getOptions(),);
      return _handleResponse(response);
    } 
    on dio.DioException catch (e) 
    {
      throw _handleDioError(e);
    } 
    catch (e) 
    {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<dynamic> post(String endpoint, {dynamic data}) async 
  {
    try 
    {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: _getOptions(),
      );
      return _handleResponse(response);
    } 
    on dio.DioException catch (e) 
    {
      throw _handleDioError(e);
    } 
    catch (e) 
    {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<dynamic> put(String endpoint, {dynamic data}) async 
  {
    try 
    {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: _getOptions(),
      );
      return _handleResponse(response);
    } 
    on dio.DioException catch (e) 
    {
      throw _handleDioError(e);
    } 
    catch (e) 
    {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {dynamic data}) async 
  {
    try 
    {
      final response = await _dio.delete(
        endpoint,
        data: data,
        options: _getOptions(),
      );
      return _handleResponse(response);
    } 
    on dio.DioException catch (e) 
    {
      throw _handleDioError(e);
    } 
    catch (e) 
    {
      throw Exception('Unexpected error: $e');
    }
  }

  dynamic _handleResponse(dio.Response response) 
  {
    // Dio automatically decodes JSON if the content-type is application/json
    return response.data;
  }

  String _extractMessage(dynamic data, String defaultMsg) {
    if (data is Map) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return defaultMsg;
  }

  Exception _handleDioError(dio.DioException e) 
  {
    if (e.response != null) 
    {
      return  AuthException(
        _extractMessage(e.response?.data, switch(e.response?.statusCode){
          401 => 'غير مصرح لك للوصول',
          404 =>  'العنصر المطلوب غير موجود',
          422 => 'يوجد خطأ في البيانات المدخلة',
          _ => 'حدث خطأ في الخادم',
        }), 
        statusCode: e.response?.statusCode
      );
    } 
    else 
    {
      final targetUrl = _dio.options.baseUrl;
      final endpoint = e.requestOptions.path;
      debugPrint("❌ Network Error: ${e.error}");
      debugPrint("🔗 Full URL attempted: $targetUrl$endpoint");
      return NetworkException('لا يوجد اتصال بالمعالج ($targetUrl). يرجى التحقق من اتصالك بنفس شبكة الواي فاي أو مراجعة عنوان المسار.');
    }
  }
}
