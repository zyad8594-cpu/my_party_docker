import 'package:get/get.dart';
import '../../clients/data/repository/client_repository.dart' show ClientRepository;
import '../controller/supplier_dashboard_controller.dart' show SupplierDashboardController;
import '../data/repository/supplier_repository.dart' show SupplierRepository;
import '../controller/supplier_controller.dart' show SupplierController;
import '../../auth/data/repository/auth_repository.dart' show AuthRepository;
import '../provider/supplier_provider.dart' show SupplierProvider;

class SupplierBinding extends Bindings 
{
  @override
  void dependencies() 
  {
    Get.lazyPut(() => SupplierRepository(), fenix: true);
    Get.lazyPut(() => SupplierController(), fenix: true);
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => SupplierProvider(), fenix: true);
    Get.lazyPut(() => SupplierDashboardController(), fenix: true);
    if(!Get.isRegistered<ClientRepository>()) Get.put(ClientRepository());
  }
}
