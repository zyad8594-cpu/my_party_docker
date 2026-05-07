import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/utils.dart' show MyPUtils;
import '../api/auth_service.dart';
import '../routes/app_routes.dart';

/// خدمة مراقبة شاملة
class GlobalMonitorService extends GetxService {
  /// اشتراك في مراقبة الاتصال بالإنترنت
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  /// مؤقت لمراقبة جلسة المصادقة
  Timer? _authTimer;

  /// تهيئة الخدمة
  /// 
  /// المعاملات:
  /// 
  /// لا يوجد
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<GlobalMonitorService>`: ترجع الخدمة بعد تهيئتها
  Future<GlobalMonitorService> init() async {
    /// 1. مراقبة الاتصال بالإنترنت
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        if (!Get.isSnackbarOpen && Get.currentRoute != AppRoutes.networkError) {
          MyPUtils.showSnackbar(
            'تنبيه',
            'انقطع الاتصال بالإنترنت',
            position: SnackPosition.TOP,
          );
          Get.toNamed(AppRoutes.networkError);
        }
      }
    });

    /// 2. مراقبة جلسة المصادقة بشكل دوري
    _authTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final authService = Get.find<AuthService>();
      // Get.snackbar('title', 'message');
      
      if (!authService.isLoggedIn) {
        if (AppRoutes.requireAuth(Get.currentRoute)) {
          AuthService.logout();
        }
      }
    });

    return this;
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _authTimer?.cancel();
    super.onClose();
  }
}
