import 'package:get/get.dart';
import '../provider/income_provider.dart';
import '../../../features/incomes/data/repository/income_repository.dart' show IncomeRepository;
import '../../../features/incomes/controller/income_controller.dart' show IncomeController;
// import '../../events/bindings/event_binding.dart' show EventBinding;

class IncomeBinding extends Bindings
{
  @override
  void dependencies() 
  {
    Get.lazyPut(() => IncomeRepository());
    Get.lazyPut(() => IncomeController());
    Get.lazyPut(() => IncomeProvider());
  }
}
