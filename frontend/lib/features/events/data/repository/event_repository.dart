import 'package:get/get.dart';
import '../models/event.dart' show Event;
import '../../provider/event_provider.dart' show EventProvider;
import '../../../../core/api/api_result.dart';
import '../../../../core/errors/error_handler.dart';

class EventRepository 
{
  final EventProvider _eventProvider = Get.find<EventProvider>();

  Future<ApiResult<List<Event>>> getAll() async 
  {
    try {
      final data = await _eventProvider.getAll();
      return ApiResult.success(data.map((e) => Event.fromJson(e)).toList());
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Event>> getById(int id) async 
  {
    try {
      final data = await _eventProvider.getById(id);
      return ApiResult.success(Event.fromJson(data));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Event>> create(dynamic event) async 
  {
    try {
      final response = await _eventProvider.create(event);
      return ApiResult.success(Event.fromJson(response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<Event>> update(int id, event) async 
  {
    try {
      final response = await _eventProvider.update(id, event);
      return ApiResult.success(Event.fromJson(response));
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> updateStatus(int id, String status) async 
  {
    try {
      await _eventProvider.updateStatus(id, status);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }

  Future<ApiResult<void>> delete(int id) async 
  {
    try {
      await _eventProvider.delete(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
