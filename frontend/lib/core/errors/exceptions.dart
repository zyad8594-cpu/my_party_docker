class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException(super.message, {super.statusCode});
}

class NetworkException extends AppException {
  NetworkException(super.message) : super(statusCode: 0);
}

class AuthException extends AppException {
  AuthException(super.message, {super.statusCode = 401});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.statusCode = 422});
}
