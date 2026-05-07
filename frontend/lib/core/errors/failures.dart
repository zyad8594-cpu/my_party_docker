class AppFailure {
  final String message;
  final int? statusCode;

  const AppFailure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message) : super(statusCode: 0);
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.statusCode = 401});
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.statusCode = 422});
}
