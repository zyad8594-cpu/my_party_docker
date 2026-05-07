import 'package:get/get.dart';
import '../models/notification.dart';
import '../../provider/notification_provider.dart' show NotificationProvider;

class NotificationRepository 
{
  final NotificationProvider _notificationProvider = Get.find<NotificationProvider>();

  Future<List<NotificationModel>> getAll() async 
  {
    final data = await _notificationProvider.getAll();
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> delete(int id) async 
  {
    await _notificationProvider.delete(id);
  }

  Future<void> markAsRead(int id) async 
  {
    await _notificationProvider.markAsRead(id);
  }

  Future<void> clearAll() async 
  {
    await _notificationProvider.clearAll();
  }

  Future<void> markAllAsRead() async 
  {
    await _notificationProvider.markAllAsRead();
  }
}
