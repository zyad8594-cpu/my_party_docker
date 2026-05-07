import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/status.dart';
import '../../../../core/api/auth_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/task.dart';
import '../../controller/task_controller.dart';
import '../../../suppliers/widgets/supplier_dashboard_widgets.dart' show showProofOfWorkBottomSheet;
import '../task_utils.dart' show showRejectTaskBottomSheet;
import 'task_reminder_bottom_sheet.dart' show showTaskReminderBottomSheet, confirmDeleteReminder;

class TaskActionButtonsSection extends GetView<TaskController> {
  final Task task;
  final String role;
  final bool showEditButton;

  const TaskActionButtonsSection({
    super.key,
    required this.task,
    required this.role,
    required this.showEditButton,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSupplier = role.toLowerCase() == 'supplier';
    final bool isAdmin = role.toLowerCase() == 'admin';
    final bool isCoordinator = role.toLowerCase() == 'coordinator' || isAdmin;
    
    final currentUserId = AuthService.user.value.id;
    final bool isMyTask = task.userAssignId == currentUserId || (isCoordinator && task.userAssignId == 0);

    // View for the assignee (Supplier/Coordinator)
    if (isMyTask) {
      return _buildMyTaskActions(context, isSupplier, isCoordinator);
    }

    // Default view for Coordinators monitoring or editing others' tasks
    if (isCoordinator && !isMyTask) {
      return _buildCoordinatorWatchActions(context);
    }

    return const SizedBox.shrink();
  }

  /// لبناء أزرار المهمة الخاصة بالمستخدم نفسه.
  Widget _buildMyTaskActions(BuildContext context, bool isSupplier, bool isCoordinator) {
    if (task.status.isCancelled || task.status.isCompleted || task.status.isRejected) {
      return const SizedBox.shrink();
    }

    final bool assignedToSupplier = task.assignmentType.toUpperCase() == 'SUPPLIER';

    // If supplier task is under review, supplier can't do anything else.
    if (assignedToSupplier && isSupplier && task.status.isUnderReview) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (task.status.isPending || task.status.isInProgress) ...[
          _buildCancelOrRejectButton(context, isSupplier, assignedToSupplier),
          const SizedBox(width: 16),
        ],
        _buildStartOrCompleteButton(context, isSupplier),
        if (isSupplier || isCoordinator) ...[
          const SizedBox(width: 8),
          _buildReminderButton(context),
        ],
      ],
    );
  }

  Widget _buildCancelOrRejectButton(BuildContext context, bool isSupplier, bool assignedToSupplier) {
    final brightness = Theme.of(context).brightness;

    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          if (assignedToSupplier && isSupplier) 
          {
            showRejectTaskBottomSheet(context, controller, task.id, brightness);
          } 
          else 
          {
            Get.defaultDialog(
              title: 'تأكيد الإلغاء',
              middleText: 'هل أنت متأكد من رغبتك في إلغاء هذه المهمة؟',
              textConfirm: 'نعم، إلغاء',
              textCancel: 'تراجع',
              confirmTextColor: AppColors.white,
              onConfirm: () {
                Get.back();
                controller.updateTaskStatus(task.id, Status.CANCELLED);
              },
            );
          }
        },
        icon: Obx(() => controller.isLoading.value
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.grey))
            : Icon(Icons.close_rounded, color: AppColors.accent.getByBrightness(brightness))),
        label: Text(
          isSupplier ? 'رفض المهمة' : 'إلغاء المهمة',
          style: TextStyle(
            color: AppColors.accent.getByBrightness(brightness),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppColors.accent.getByBrightness(brightness)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildStartOrCompleteButton(BuildContext context, bool isSupplier) {
    final brightness = Theme.of(context).brightness;

    return Expanded(
      // flex: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient.getByBrightness(brightness),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            if (task.status.isPending) {
              Get.defaultDialog(
                title: 'تأكيد البدء',
                middleText: 'هل أنت متأكد من رغبتك في بدء تنفيذ هذه المهمة الآن؟',
                textConfirm: 'نعم، ابدأ',
                textCancel: 'تراجع',
                confirmTextColor: AppColors.white,
                onConfirm: () {
                  Get.back();
                  controller.updateTaskStatus(task.id, Status.IN_PROGRESS);
                },
              );
            } else if (task.status.isInProgress || task.status.isUnderReview) {
              _showProofOfWorkBottomSheet(context, isSupplier);
            }
          },
          icon: Icon(
            task.status.isPending 
              ? Icons.play_arrow_rounded 
              : (isSupplier ? Icons.file_upload_outlined : Icons.check_circle_rounded),
            color: AppColors.white,
          ),
          label: Text(
            task.status.isPending
                ? (isSupplier ? 'بدء المهمة' : 'بدء التنفيذ')
                : (isSupplier ? 'تسليم للإعتماد' : 'إكمال المهمة'),
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.transparent,
            shadowColor: AppColors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderButton(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bool hasReminder = task.reminderType != null && task.reminderType != 'none';

    return Container(
      decoration: BoxDecoration(
        color: (hasReminder ? AppColors.orange : AppColors.primary.getByBrightness(brightness))
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          IconButton(
            onPressed: () => showTaskReminderBottomSheet(context, task, controller),
            icon: Icon(
                hasReminder ? Icons.notifications_active_rounded : Icons.add_alarm_rounded,
                color: hasReminder ? AppColors.orange : AppColors.primary.getByBrightness(brightness)),
            tooltip: hasReminder ? 'تعديل التذكير' : 'إضافة تذكير',
          ),
          if (hasReminder)
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => confirmDeleteReminder(context, task, controller),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 10, color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoordinatorWatchActions(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final unSow = !task.status.isCancelled && !task.status.isRejected && !task.status.isCompleted;
    return Row(
      children: [
        if(unSow && !task.status.isUnderReview) ...[
          _buildCancelOrRejectButton(context, false, task.assignmentType.toUpperCase() == 'SUPPLIER'),
          const SizedBox(width: 16),
        ],

        if (unSow && showEditButton) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.taskAdd, arguments: task),
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text('تعديل البيانات'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],

        
        
        if (task.status.isUnderReview)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient.getByBrightness(brightness),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.updateTaskStatus(task.id, Status.COMPLETED);
                },
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text('اعتماد الإنجاز'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                  shadowColor: AppColors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showProofOfWorkBottomSheet(BuildContext context, bool isSupplier) {
    if (!isSupplier) {
      controller.updateTaskStatus(task.id, Status.COMPLETED);
      return;
    }
    showProofOfWorkBottomSheet(context, task);
  }
}
