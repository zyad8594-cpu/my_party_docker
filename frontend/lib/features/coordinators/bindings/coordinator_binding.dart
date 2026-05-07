import 'package:get/get.dart';
import '../data/repository/coordinator_repository.dart' show CoordinatorRepository;
import '../controller/coordinator_controller.dart' show CoordinatorController;
import '../provider/coordinator_provider.dart' show CoordinatorProvider;

class CoordinatorBinding extends Bindings 
{
  @override
  void dependencies() 
  {
    Get.lazyPut(() => CoordinatorRepository(), fenix: true);
    Get.lazyPut(() => CoordinatorController(), fenix: true);
    Get.lazyPut(() => CoordinatorProvider(), fenix: true);
  }
}
