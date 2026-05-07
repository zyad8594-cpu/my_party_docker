import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static AppFailure handle(dynamic error) 
  {
    if (error is AppException) 
    {
      final msg = error.message;
      if (error is AuthException) 
      {
        return AuthFailure(msg, statusCode: error.statusCode);
      } 
      else if (error is ServerException) 
      {
        return ServerFailure(msg, statusCode: error.statusCode);
      } 
      else if (error is NetworkException) 
      {
        return NetworkFailure(msg);
      } 
      else if (error is ValidationException) 
      {
        return ValidationFailure(msg, statusCode: error.statusCode);
      }
      return AppFailure(msg, statusCode: error.statusCode);
    } 
    else if (error is DioException) 
    {
      final targetUrl = error.requestOptions.baseUrl + error.requestOptions.path;
      return NetworkFailure('لا يوجد اتصال بالخادم ($targetUrl). يرجى التأكد من أنك على نفس الشبكة وأن السيرفر يعمل.');
    }
    return AppFailure('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.\n$error');
  }
}
