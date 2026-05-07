import 'package:get/get.dart';
import '../../notifications/bindings/notification_binding.dart';
import '../../clients/bindings/client_binding.dart' show ClientBinding;
import '../../coordinators/bindings/coordinator_binding.dart' show CoordinatorBinding;
import '../../incomes/bindings/income_binding.dart';
import '../../suppliers/bindings/supplier_binding.dart' show SupplierBinding;
import '../../services/bindings/service_binding.dart' show ServiceBinding;
import '../../tasks/bindings/task_binding.dart' show TaskBinding;
import '../provider/event_provider.dart' show EventProvider;
import '../data/repository/event_repository.dart' show EventRepository;
import '../controller/event_controller.dart' show EventController;

class EventBinding extends Bindings 
{
  @override
  void dependencies() 
  {
    Get.lazyPut(() => EventRepository(), fenix: true);
    Get.lazyPut(() => EventController(), fenix: true);
    Get.lazyPut(() => EventProvider(), fenix: true);
    NotificationBinding().dependencies();
    ClientBinding().dependencies();
    CoordinatorBinding().dependencies();
    SupplierBinding().dependencies();
    ServiceBinding().dependencies();
    TaskBinding().dependencies();
    IncomeBinding().dependencies();
  }
}
