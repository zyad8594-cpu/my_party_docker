import 'package:connectivity_plus/connectivity_plus.dart' show Connectivity, ConnectivityResult;
import 'package:get/get.dart';
import '../routes/app_routes.dart' show AppRoutes;

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final isConnected = true.obs;
  final onReconnected = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      isConnected.value = false;
      if (Get.currentRoute != AppRoutes.networkError) {
        Get.toNamed(AppRoutes.networkError);
      }
    } else {
      // If we were disconnected and now we are back
      if (!isConnected.value) {
        isConnected.value = true;
        onReconnected.value++; // Trigger refresh for listeners
      }
      
      // If we are on the network error screen and connection is back, go back
      if (Get.currentRoute == AppRoutes.networkError) {
        Get.back();
      }
    }
  }
}
