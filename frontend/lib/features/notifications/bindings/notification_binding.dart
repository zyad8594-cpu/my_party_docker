import 'package:get/get.dart';
import '../data/repository/notification_repository.dart';
import '../controller/notification_controller.dart';
import '../provider/notification_provider.dart';

class NotificationBinding extends Bindings 
{
  @override
  void dependencies() 
  {
    if(!Get.isRegistered<NotificationRepository>()){
      Get.put(NotificationRepository(), permanent: true);
    }
    if(!Get.isRegistered<NotificationController>()){
      Get.put(NotificationController(), permanent: true);
    }
    if(!Get.isRegistered<NotificationProvider>()){
      Get.put(NotificationProvider(), permanent: true);
    }
  }
}
