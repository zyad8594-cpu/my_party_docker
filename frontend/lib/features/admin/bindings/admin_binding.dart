import 'package:get/get.dart';
import '../controller/admin_controller.dart';
import '../data/repository/admin_repository.dart';
import '../../home/controller/admin_dashboard_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminRepository>(() => AdminRepository());
    Get.lazyPut<AdminController>(() => AdminController(repository: Get.find()));
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
  }
}
