import 'package:get/get.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Wait for 3 seconds to show the elegant splash screen
    await Future.delayed(const Duration(seconds: 3));
    
    final isLoggedIn = Get.find<AuthService>().isLoggedIn;
    
    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
