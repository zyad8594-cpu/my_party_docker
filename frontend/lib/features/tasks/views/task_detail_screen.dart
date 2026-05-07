import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart';
// import '../../auth/controller/auth_controller.dart' show AuthController;
import '../data/models/task.dart' show Task;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/api/auth_service.dart' show AuthService;
import '../controller/task_controller.dart' show TaskController;
import '../../events/controller/event_controller.dart' show EventController;
import '../../coordinators/controller/coordinator_controller.dart' show CoordinatorController;
import '../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../../clients/controller/client_controller.dart' show ClientController;
import '../widgets/task_detail/task_proof_of_work_section.dart';
import '../widgets/task_detail/task_action_buttons_section.dart';
import '../widgets/task_detail/task_evaluation_section.dart';
import '../widgets/task_detail/event_client_section.dart';
import '../widgets/task_detail/task_assignment_section.dart';
import '../../services/controller/service_controller.dart' show ServiceController;

class TaskDetailScreen extends GetView<TaskController> {
  TaskDetailScreen({super.key}){
    _fetchMissingData();
  }

  Future<void> _fetchMissingData() async {
    final eventController = Get.find<EventController>();
    final coordinatorController = Get.find<CoordinatorController>();
    final supplierController = Get.find<SupplierController>();
    final clientController = Get.find<ClientController>();

    final dynamic args = Get.arguments;
    if (args == null || args is! Task) return;
    final Task task = args;

    // Fetch event if missing
    if (eventController.list.every((e) => e.id != task.eventId)) {
      await eventController.fetchById(task.eventId);
    }

    final event = eventController.list.firstWhereOrNull((e) => e.id == task.eventId);

    // Fetch coordinator if missing
    if (coordinatorController.list.every((c) => c.id != task.coordinatorId)) {
      await coordinatorController.fetchById(task.coordinatorId);
    }

    // Fetch client if missing
    if (event != null && clientController.list.every((c) => c.id != event.clientId)) {
      await clientController.fetchById(event.clientId);
    }

    // Fetch supplier if missing
    if (task.assignmentType.toUpperCase() == 'SUPPLIER' &&
        supplierController.list.every((s) => s.id != task.userAssignId)) {
      await supplierController.fetchById(task.userAssignId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final coordinatorController = Get.find<CoordinatorController>();
    final supplierController = Get.find<SupplierController>();
    // final clientController = Get.find<ClientController>();

    final brightness = Theme.of(context).brightness;
    final dynamic args = Get.arguments;
    if (args == null || args is! Task) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('بيانات المهمة غير متوفرة')),
      );
    }
    final Task task = args;
    final role = AuthService.user.value.role.isNotEmpty? AuthService.user.value.role : 'coordinator';

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
          showBackButton: true, title: task.typeTask ?? 'تفاصيل المهمة'),
      body: SelectionArea(
        child: Obx(() {
          // Find the latest task from the controller to ensure reactivity
          final currentTask = controller.list.firstWhere(
            (t) => t.id == task.id,
            orElse: () => task,
          );

          // Fetch related data from other controllers
          final event = eventController.list
              .firstWhereOrNull((e) => e.id == currentTask.eventId);
          final coordinator = coordinatorController.list
              .firstWhereOrNull((c) => c.id == currentTask.coordinatorId);
          final supplier = currentTask.assignmentType.toUpperCase() == 'SUPPLIER'
              ? supplierController.list
                  .firstWhereOrNull((s) => s.id == currentTask.userAssignId)
              : null;
          final service = Get.find<ServiceController>().list.firstWhereOrNull((s) => s.id == currentTask.serviceId);

          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchTasks();
              await _fetchMissingData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (service != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.miscellaneous_services_rounded, size: 18, color: AppColors.primary.getByBrightness(brightness)),
                          const SizedBox(width: 8),
                          Text(
                            'الخدمة: ${service.serviceName}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary.getByBrightness(brightness),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // بيانات المهمة
                  TaskAssignmentSection(
                    task: currentTask,
                    assignedName: AuthService.userIsSupplier
                        ? (event?.coordinatorName ?? currentTask.takCreatorName)
                        : (supplier != null
                            ? (currentTask.assigneName ?? supplier.name)
                            : null),
                    assignedPhone: AuthService.userIsSupplier
                        ? (event?.coordinatorPhone ?? coordinator?.phoneNumber)
                        : (supplier?.phoneNumber),
                    assignedEmail: AuthService.userIsSupplier
                        ? coordinator?.email
                        : supplier?.email,
                    assignedImageUrl: AuthService.userIsSupplier
                        ? coordinator?.imgUrl
                        : supplier?.imgUrl,
                    assignedRoleTitle: AuthService.userIsSupplier
                        ? 'منسق المناسبة'
                        : (supplier != null ? 'مورد الخدمات' : null),
                  ),
                  const SizedBox(height: 24),

                  // بيانات العميل والمناسبة
                  EventClientSection(
                    event: event
                  ),
                  const SizedBox(height: 24),

                  if ((currentTask.status.isCompleted ||
                      currentTask.status.isUnderReview) && currentTask.assignmentType.toUpperCase() == 'SUPPLIER') ...[
                    const SizedBox(height: 24),
                    TaskProofOfWorkSection(task: currentTask),
                  ],

                  if (currentTask.status.isCompleted && currentTask.assignmentType.toUpperCase() == 'SUPPLIER') ...[
                    const SizedBox(height: 24),
                    
                    TaskEvaluationSection(
                      task: currentTask,
                      role: role,
                    ),
                  ],
                  const SizedBox(height: 32),

                  TaskActionButtonsSection(
                    task: currentTask, 
                    role: role, 
                    showEditButton: (event != null && !event.status.isCancelled && !event.isDeleted),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
