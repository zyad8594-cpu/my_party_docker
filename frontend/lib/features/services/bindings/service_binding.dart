import 'package:get/get.dart';
import '../data/repository/service_repository.dart' show ServiceRepository;
import '../controller/service_controller.dart' show ServiceController;
import '../provider/service_provider.dart' show ServiceProvider;

class ServiceBinding extends Bindings 
{
  @override
  void dependencies() 
  {
    Get.lazyPut(() => ServiceRepository(), fenix: true);
    Get.lazyPut(() => ServiceController(), fenix: true);
    Get.lazyPut(() => ServiceProvider(), fenix: true);
  }
}
