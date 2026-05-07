import 'package:get/get.dart';
import '../../clients/bindings/client_binding.dart' show ClientBinding;
import '../../events/controller/event_controller.dart' show EventController;
import '../../events/data/repository/event_repository.dart' show EventRepository;
import '../../events/provider/event_provider.dart' show EventProvider;
import '../../coordinators/controller/coordinator_controller.dart' show CoordinatorController;
import '../../coordinators/data/repository/coordinator_repository.dart' show CoordinatorRepository;
import '../../coordinators/provider/coordinator_provider.dart' show CoordinatorProvider;
import '../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../../suppliers/data/repository/supplier_repository.dart' show SupplierRepository;
import '../../suppliers/provider/supplier_provider.dart' show SupplierProvider;
import '../data/repository/task_repository.dart' show TaskRepository;
import '../controller/task_controller.dart' show TaskController;
import '../provider/task_provider.dart' show TaskProvider;
import '../../services/bindings/service_binding.dart' show ServiceBinding;
import '../../services/controller/service_controller.dart' show ServiceController;
import '../../services/data/repository/service_repository.dart' show ServiceRepository;
import '../../services/provider/service_provider.dart' show ServiceProvider;

class TaskBinding extends Bindings 
{
  @override
  void dependencies() 
  {
    Get.lazyPut(() => TaskRepository());
    Get.lazyPut(() => TaskController());
    Get.lazyPut(() => TaskProvider());

    // Event Dependencies
    if(!Get.isRegistered<EventController>()) Get.put(EventController());
    if(!Get.isRegistered<EventRepository>()) Get.put(EventRepository());
    if(!Get.isRegistered<EventProvider>()) Get.put(EventProvider());

    // Coordinator Dependencies
    if(!Get.isRegistered<CoordinatorController>()) Get.put(CoordinatorController());
    if(!Get.isRegistered<CoordinatorRepository>()) Get.put(CoordinatorRepository());
    if(!Get.isRegistered<CoordinatorProvider>()) Get.put(CoordinatorProvider());

    // Client Dependencies
    ClientBinding().dependencies();

    // Supplier Dependencies
    if(!Get.isRegistered<SupplierController>()) Get.put(SupplierController());
    if(!Get.isRegistered<SupplierRepository>()) Get.put(SupplierRepository());
    if(!Get.isRegistered<SupplierProvider>()) Get.put(SupplierProvider());

    // Service Dependencies
    ServiceBinding().dependencies();
    if(!Get.isRegistered<ServiceController>()) Get.put(ServiceController());
    if(!Get.isRegistered<ServiceRepository>()) Get.put(ServiceRepository());
    if(!Get.isRegistered<ServiceProvider>()) Get.put(ServiceProvider());
  }
}
