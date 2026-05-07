import 'package:get/get.dart';
import '../models/income.dart';
import '../../provider/income_provider.dart' show IncomeProvider;
import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';

class IncomeRepository 
{
  final IncomeProvider _incomeProvider = Get.find<IncomeProvider>();

  Future<ApiResult<List<Income>>> getAll() async 
  {
    try {
      final data = await _incomeProvider.getAll();
      return ApiResult.success(data.map((e) => Income.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Income>> getById(int id) async 
  {
    try {
      final data = await _incomeProvider.getById(id);
      return ApiResult.success(Income.fromJson(data));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Income>> create(dynamic data) async 
  {
    try {
      final response = await _incomeProvider.create(data);
      return ApiResult.success(Income.fromJson(response['result'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Income>> update(int id, dynamic data) async 
  {
    try {
      final response = await _incomeProvider.update(id, data);
      return ApiResult.success(Income.fromJson(response['result'] ?? response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> delete(int id) async 
  {
    try {
      await _incomeProvider.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
