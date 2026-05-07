import 'package:get/get.dart';
import '../controller/reports_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReportsController(), fenix: true);
  }
}
