import 'package:get/get.dart';
import '../../coordinators/bindings/coordinator_binding.dart' show CoordinatorBinding;
import '../../events/bindings/event_binding.dart' show EventBinding;
import '../../suppliers/bindings/supplier_binding.dart' show SupplierBinding;
import '../../auth/bindings/auth_binding.dart' show AuthBinding;
import '../../incomes/bindings/income_binding.dart' show IncomeBinding;
import '../../tasks/bindings/task_binding.dart' show TaskBinding;

import '../controller/admin_dashboard_controller.dart' show AdminDashboardController;
import '../controller/home_controller.dart' show HomeController;
import '../controller/main_layout_controller.dart' show MainLayoutController;

class HomeBinding extends Bindings 
{
  @override
  void dependencies() 
  {
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => MainLayoutController(), fenix: true);
    Get.lazyPut(() => AdminDashboardController(), fenix: true);
    CoordinatorBinding().dependencies();
    EventBinding().dependencies();
    SupplierBinding().dependencies();
    AuthBinding().dependencies();
    IncomeBinding().dependencies();
    TaskBinding().dependencies();
    SupplierBinding().dependencies();
  }
}
