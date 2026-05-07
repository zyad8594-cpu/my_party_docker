import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart' show StatusExtension;
import '../../../core/api/auth_service.dart' show AuthService;
import '../../../core/api/api_service.dart';
import '../../tasks/controller/task_controller.dart' show TaskController;
import '../../tasks/data/models/task.dart' show Task;
import '../../notifications/controller/notification_controller.dart' show NotificationController;
import '../../notifications/data/models/notification.dart' show NotificationModel;

class SupplierDashboardController extends GetxController 
{
  final isLoading = false.obs;
  final selectedFilter = 'الكل'.obs;
  final searchQuery = ''.obs;

  final ApiService _apiService = Get.find<ApiService>();

  // Real data from TaskController
  final activeTasks = <Task>[].obs;
  final allMyTasks = <Task>[].obs;
  final taskStats = {
    'pending': 0, 'in_progress': 0, 'under_review': 0, 
    'completed': 0, 'cancelled': 0, 'rejected': 0,
  }.obs;
  final eventStats = {
    'pending': 0, 'in_progress': 0, 'completed': 0, 'cancelled': 0, 'total': 0
  }.obs;
  
  final recentNotifications = <NotificationModel>[].obs;

  final totalEarnings = 0.0.obs;
  final rating = 4.8.obs; // Mock rating since it might not be in the model yet

  // final authUser = AuthService.to.user;

  List<Task> get filteredTasks{
     return allMyTasks.where((t) {
        final query = searchQuery.value.toLowerCase();
        final matchesSearch = query.isEmpty ||
            (t.typeTask?.toLowerCase().contains(query) ?? false) ||
            (t.description?.toLowerCase().contains(query) ?? false) ||
            (t.eventName.toLowerCase().contains(query));

        if (selectedFilter.value == 'الكل') return matchesSearch;
        return matchesSearch && t.status.tryText() == selectedFilter.value;
    }).toList();
  }
  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    try {
      if (Get.isRegistered<TaskController>()) {
        final taskController = Get.find<TaskController>();
        await taskController.fetchTasks();

        if (Get.isRegistered<NotificationController>()) {
          final notifController = Get.find<NotificationController>();
          await notifController.fetchNotifications();
          recentNotifications.value = notifController.notifications.take(4).toList();
        }

        final supplierId = AuthService.user.value.id;
        
        final myTasks = taskController.tasks
            .where((t) => t.userAssignId == supplierId)
            .toList();

        allMyTasks.value = myTasks;

        activeTasks.value = myTasks
            .where(
              (t) =>
                  t.status.isInProgress ||
                  t.status.isPending,
            )
            .toList();

        // Fetch supplier stats from API
        final response = await _apiService.get('/dashboard/supplier-stats');
        if (response != null && response['success'] == true) {
          final data = response['data'] ?? {};
          taskStats.value = {
            'pending': data['pending_tasks'] ?? 0,
            'in_progress': data['in_progress_tasks'] ?? 0,
            'under_review': data['under_review_tasks'] ?? 0,
            'completed': data['completed_tasks'] ?? 0,
            'cancelled': data['cancelled_tasks'] ?? 0,
            'rejected': data['rejected_tasks'] ?? 0,
          };
          
          eventStats.value = {
            'pending': data['pending_events'] ?? 0,
            'in_progress': data['in_progress_events'] ?? 0,
            'completed': data['completed_events'] ?? 0,
            'cancelled': data['cancelled_events'] ?? 0,
            'total': data['total_events'] ?? 0,
          };
        } else {
           // Fallback to local task stats if API fails
           taskStats.value = {
            'pending': myTasks.where((t) => t.status.isPending).length,
            'in_progress': myTasks.where((t) => t.status.isInProgress).length,
            'under_review': myTasks.where((t) => t.status.isUnderReview).length,
            'completed': myTasks.where((t) => t.status.isCompleted).length,
            'cancelled': myTasks.where((t) => t.status.isCancelled).length,
            'rejected': myTasks.where((t) => t.status.isRejected).length,
          };
        }

        totalEarnings.value = myTasks
            .where((t) => t.status.isCompleted)
            .fold(0.0, (sum, item) => sum + (item.totalCost));
      }
    } catch (e) {
      debugPrint('Dashboard error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTaskStatus(int taskId, newStatus, {String? note, dynamic urlImage, double? adjustmentAmount, String? adjustmentType}) async {
    isLoading.value = true;
    bool success = false;
    try {
      if (Get.isRegistered<TaskController>()) {
        final taskController = Get.find<TaskController>();
        // Wait for update
        await taskController.updateTaskStatus(
          taskId, 
          newStatus, 
          note: note, 
          urlImage: urlImage,
          adjustmentAmount: adjustmentAmount,
          adjustmentType: adjustmentType,
        );
        
        // We consider it a success if the task status locally reflects it (assuming TaskController handles its own errors properly)
        final updatedTask = taskController.tasks.firstWhereOrNull((t) => t.id == taskId);
        if (updatedTask != null) {
          success = true;
        }
        await refreshDashboard();
      }
    } catch (e, stackTrace) {
      debugPrint('=== ERROR in updateTaskStatus ===\n$e\n$stackTrace');
      Get.snackbar('خطأ', 'فشل تحديث حالة المهمة: $e');
    } finally {
      isLoading.value = false;
    }
    return success;
  }
}
