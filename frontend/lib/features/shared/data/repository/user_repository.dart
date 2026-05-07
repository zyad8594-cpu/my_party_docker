import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../data/models/user.dart';
import '../../../../core/api/api_provider.dart';

class UserRepository<T extends User> 
{
  final ApiProvider _provider;
  final T Function(dynamic) fromJson;

  UserRepository({
    required ApiProvider provider,
    required this.fromJson,
  }) : _provider = provider;

  Future<ApiResult<List<T>>> getAll() async 
  {
    try {
      final data = await _provider.getAll();
      return ApiResult.success(data.map((json) => fromJson(json)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<T>> getById(int id) async 
  {
    try {
      final data = await _provider.getById(id);
      return ApiResult.success(fromJson(data));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<T>> create(dynamic data) async 
  {
    try {
      final response = await _provider.create(data);
      return ApiResult.success(fromJson(response['user'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<T>> update(int id, dynamic data) async 
  {
    try {
      final response = await _provider.update(id, data);
      return ApiResult.success(fromJson(response['user'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> delete(int id) async 
  {
    try {
      await _provider.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> toggleStatus(int id, bool isActive) async {
    try {
      await _provider.toggleStatus(id, isActive);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> restore(int id) async {
    try {
      await _provider.restore(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
