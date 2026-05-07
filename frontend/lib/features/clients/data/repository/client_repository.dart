import 'package:get/get.dart';
import '../models/client.dart';
import '../../provider/client_provider.dart' show ClientProvider;
import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';

class ClientRepository 
{
  final ClientProvider _clientProvider = Get.find<ClientProvider>();

  Future<ApiResult<List<Client>>> getAll() async 
  {
    try {
      final data = await _clientProvider.getAll();
      return ApiResult.success(data.map((e) => Client.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Client>> getById(int id) async 
  {
    try {
      final data = await _clientProvider.getById(id);
      return ApiResult.success(Client.fromJson(data));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Client>> create(dynamic data) async 
  {
    try {
      final response = await _clientProvider.create(data);
      return ApiResult.success(Client.fromJson(response['user'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Client>> update(int id, dynamic data) async 
  {
    try {
      final response = await _clientProvider.update(id, data);
      return ApiResult.success(Client.fromJson(response['user'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> delete(int id) async 
  {
    try {
      await _clientProvider.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> restore(int id) async 
  {
    try {
      await _clientProvider.restore(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
