import 'package:get/get.dart';
import '../../../core/controllers/main_layout_controller.dart';
import '../provider/auth_provider.dart';
import '../data/repository/auth_repository.dart';
import '../controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthProvider());
    Get.lazyPut(() => AuthRepository());
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => MainLayoutController());
  }
}
