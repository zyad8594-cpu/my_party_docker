import 'package:get/get.dart';
import '../data/repository/client_repository.dart' show ClientRepository;
import '../controller/client_controller.dart' show ClientController;
import '../../auth/bindings/auth_binding.dart' show AuthBinding;
import '../provider/client_provider.dart' show ClientProvider;

class ClientBinding extends Bindings 
{
  @override
  void dependencies() 
  {
    Get.lazyPut(() => ClientRepository());
    Get.lazyPut(() => ClientController());
    Get.lazyPut(() => ClientProvider());
    AuthBinding().dependencies();
  }
}
