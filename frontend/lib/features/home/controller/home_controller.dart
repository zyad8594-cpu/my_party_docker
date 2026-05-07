import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart';
// import '../../../core/api/api_constants.dart';
// import '../../../core/api/api_result.dart';
// import '../../../core/api/api_service.dart';
// import '../../clients/controller/client_controller.dart' show ClientController;
import '../../events/controller/event_controller.dart' show EventController;
// import '../../incomes/controller/income_controller.dart' show IncomeController;
// import '../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../../tasks/controller/task_controller.dart' show TaskController;
import '../../tasks/data/models/task.dart' show Task;
import '../../../core/controllers/network_controller.dart' show NetworkController;


class HomeController extends GetxController {

  // الإحصائيات للصفحة الرئيسية
  final isLoading = false.obs;

  // late final IncomeController incomeController;
  // late final ClientController clientController;
  // late final SupplierController supplierController;

  final RxList<dynamic> ratingsList = <dynamic>[].obs;


  final taskStatusStats = <String, RxInt>{
    'pending': 0.obs,
    'in_progress': 0.obs,
    'under_review': 0.obs,
    'completed': 0.obs,
    'cancelled': 0.obs,
    'rejected': 0.obs,
  };
  final eventStatusStats = <String, RxInt>{
    'pending': 0.obs,
    'in_progress': 0.obs,
    'completed': 0.obs,
    'cancelled': 0.obs,
  };
  
  double getPercentage(String key, {bool isTasks = true}) {
    if(isTasks)
    {
      if(totalTasks.value == 0) return 0;
      return (taskStatusStats[key.toLowerCase()]?.toDouble() ?? 0) / totalTasks.value * 100;
    }
    else
    {
      if(totalEvents.value == 0) return 0;
      return (eventStatusStats[key.toLowerCase()]?.toDouble() ?? 0) / totalEvents.value * 100;
    }
  }
  
  // final totalCoordinators = 0.obs;
  // final totalSuppliers = 0.obs;
  final totalEvents = 0.obs;
  final totalTasks = 0.obs;
  // final totalClients = 0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // incomeController = Get.put(IncomeController());
    // clientController = Get.put(ClientController());
    // supplierController = Get.put(SupplierController());
    refreshStatistics();

    // Listen to reconnection to auto-refresh statistics
    if (Get.isRegistered<NetworkController>()) {
      ever(Get.find<NetworkController>().onReconnected, (_) {
        if (totalEvents.value == 0 || totalTasks.value == 0) {
          refreshStatistics(force: true);
        }
      });
    }
  }

  EventController get eventController => Get.isRegistered<EventController>()? Get.find<EventController>(): Get.put(EventController());
  TaskController get taskController => Get.isRegistered<TaskController>()? Get.find<TaskController>(): Get.put(TaskController());
  
  List<Task> get filteredTasks {
    final events = eventController.events; 
    var raw = taskController.tasks.toList();
    return raw.where((task){
      var event = events.firstWhereOrNull((e) => e.id == task.eventId);
      if(event == null) return false;
      
      return !event.status.isCancelled;
    }).toList();
  }
  

  Future<void> refreshStatistics({bool force = false}) async 
  {
    if(isLoading.value) return;
    
    isLoading.value = true;
    await eventController.fetchAll(force:  force);
    await taskController.fetchTasks(force: force);

    try {
      final tasks = filteredTasks;
      final events = eventController.events;

      totalEvents.value = events.length;
      eventStatusStats['pending'] = 0.obs;
      eventStatusStats['in_progress'] = 0.obs;
      eventStatusStats['completed'] = 0.obs;
      eventStatusStats['cancelled'] = 0.obs;

      for (var event in events) {
        if(event.status.isPending)
        {
          eventStatusStats['pending']!.value++;
        }
        else if(event.status.isInProgress)
        {
          eventStatusStats['in_progress']!.value++;
        }
        else if(event.status.isCompleted)
        {
          eventStatusStats['completed']!.value++;
        }
        else if(event.status.isCancelled)
        {
          eventStatusStats['cancelled']!.value++;
        }
      }

      totalTasks.value = tasks.length;
      taskStatusStats['pending'] = 0.obs;
      taskStatusStats['in_progress'] = 0.obs;
      taskStatusStats['under_review'] = 0.obs;
      taskStatusStats['completed'] = 0.obs;
      taskStatusStats['rejected'] = 0.obs;
      taskStatusStats['cancelled'] = 0.obs;
      
      for (var task in tasks) {
        if(task.status.isPending)
        {
          taskStatusStats['pending']!.value++;
        }
        else if(task.status.isInProgress)
        {
          taskStatusStats['in_progress']!.value++;
        }
        else if(task.status.isUnderReview)
        {
          taskStatusStats['under_review']!.value++;
        }
        else if(task.status.isCompleted)
        {
          taskStatusStats['completed']!.value++;
        }
        else if(task.status.isRejected)
        {
          taskStatusStats['rejected']!.value++;
        }
        else if(task.status.isCancelled)
        {
          taskStatusStats['cancelled']!.value++;
        }
      }
      

      // totalClients.value = data['total_clients'] ?? 0;
      // totalCoordinators.value = data['total_coordinators'] ?? 0;
      // totalSuppliers.value = data['total_suppliers'] ?? 0;
     
        
    } catch (e) {
      debugPrint('Exception in refreshStatistics: $e');
    }

    isLoading.value = false;
  }
}
