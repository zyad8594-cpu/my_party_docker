import 'package:get/get.dart';

import '../../../core/controllers/main_layout_controller.dart' show MainLayoutController;
import 'home_binding.dart' show HomeBinding;
import '../../clients/bindings/client_binding.dart' show ClientBinding;
import '../../events/bindings/event_binding.dart' show EventBinding;
import '../../reports/bindings/report_binding.dart' show ReportBinding;
import '../../tasks/bindings/task_binding.dart' show TaskBinding;
import '../../suppliers/bindings/supplier_binding.dart' show SupplierBinding;
import '../../coordinators/bindings/coordinator_binding.dart' show CoordinatorBinding;
import '../../admin/bindings/admin_binding.dart' show AdminBinding;
import '../../services/bindings/service_binding.dart' show ServiceBinding;

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());
    HomeBinding().dependencies();
    ClientBinding().dependencies();
    EventBinding().dependencies();
    ReportBinding().dependencies();
    TaskBinding().dependencies();
    SupplierBinding().dependencies();
    CoordinatorBinding().dependencies();
    AdminBinding().dependencies();
    ServiceBinding().dependencies();
  }
}
