// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart';
import '../../../core/api/auth_service.dart' show AuthService;
import '../controller/supplier_dashboard_controller.dart' show SupplierDashboardController;
import '../../tasks/data/models/task.dart' show Task;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../../core/utils/date_formatter.dart' show DateFormatter;
import 'dart:io' show File;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import '../../tasks/widgets/task_utils.dart' show showRejectTaskBottomSheet;

class SupplierDashboardWidgets {
  static Widget buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppFormWidgets.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBody.getByBrightness(brightness),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSubtitle.getByBrightness(brightness),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SupplierGreeting extends StatelessWidget {

  const SupplierGreeting({super.key,});

  @override
  Widget build(BuildContext context) 
  {
    final authUser = AuthService.user;
    final brightness = Theme.of(context).brightness;
    final name = authUser.value.name.isNotEmpty? authUser.value.name : 'شريكنا العزيز';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً بك، $name ',
          style: TextStyle(
            color: AppColors.textBody.getByBrightness(brightness),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'نظرة سريعة على أدائك ومهامك اليوم',
          style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 14),
        ),
      ],
    );
  }
}

class SupplierStatsGrid extends GetView<SupplierDashboardController> {

  const SupplierStatsGrid({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: [
        SupplierDashboardWidgets.buildStatCard(
          'إجمالي المهام',
          '${controller.allMyTasks.length}',
          Icons.task_alt_rounded,
          AppColors.primary.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مهام قيد الإنتظار',
          '${controller.taskStats['pending']}',
          Icons.pending_actions_rounded,
          AppColors.brown,
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مهام قيد التنفيذ',
          '${controller.taskStats['in_progress']}',
          Icons.sync_rounded,
          AppColors.info.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مهام قيد المراجعة',
          '${controller.taskStats['under_review']}',
          Icons.rate_review_rounded,
          AppColors.warning.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مهام مكتملة',
          '${controller.taskStats['completed']}',
          Icons.check_circle_rounded,
          AppColors.success.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مهام ملغية',
          '${controller.taskStats['cancelled']}',
          Icons.cancel_rounded,
          AppColors.accent.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مهام مرفوضة',
          '${controller.taskStats['rejected']}',
          Icons.thumb_down_alt_rounded,
          AppColors.rejected.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'إجمالي المناسبات',
          '${controller.eventStats['total']}',
          Icons.event_note_rounded,
          AppColors.primary.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مناسبات قيد الإنتظار',
          '${controller.eventStats['pending']}',
          Icons.event_available_rounded,
          AppColors.brown,
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مناسبات قيد التنفيذ',
          '${controller.eventStats['in_progress']}',
          Icons.event_busy_rounded,
          AppColors.info.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مناسبات مكتملة',
          '${controller.eventStats['completed']}',
          Icons.event_available_rounded,
          AppColors.success.getByBrightness(brightness),
          context,
        ),

        SupplierDashboardWidgets.buildStatCard(
          'مناسبات ملغية',
          '${controller.eventStats['cancelled']}',
          Icons.event_busy_rounded,
          AppColors.accent.getByBrightness(brightness),
          context,
        ),
      ],
    ));
  }
}

class SupplierActiveTasksList extends GetView<SupplierDashboardController> {
  

  const SupplierActiveTasksList({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Obx(() => Column(
      children: controller.activeTasks
          .map((task) => _buildTaskCard(task, context))
          .take(3).toList(),
    ));
  }

  Widget _buildTaskCard(Task task, BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    // final bool isPending = ;
    final bool isInProgress = task.status.isInProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppFormWidgets.cardDecoration(context),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.taskDetail, arguments: task),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.assignment_rounded,
                      color: AppColors.primary.getByBrightness(brightness),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.typeTask!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBody.getByBrightness(brightness),
                          ),
                        ),
                        Text(
                          task.eventName,
                          style: TextStyle(
                            color: AppColors.textSubtitle.getByBrightness(brightness),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isInProgress ? AppColors.info : AppColors.warning).getByBrightness(brightness).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(() {
                      final bool val = controller.isLoading.value;
                      return Text(
                        task.status.tryText(),
                        style: TextStyle(
                          color: task.status.tryColor(brightness),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  // Expanded(
                  //   child: OutlinedButton(
                  //     onPressed: () =>
                  //         Get.toNamed(AppRoutes.taskDetail, arguments: task),
                  //     style: OutlinedButton.styleFrom(
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       side: BorderSide(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
                  //     ),
                  //     child: Text(
                  //       'التفاصيل',
                  //       style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
                  //     ),
                  //   ),
                  // ),
                  if (task.status.isPending || task.status.isInProgress)
                    Expanded(
                      child: Row(
                        children: [
                          if (task.status.isPending) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => showRejectTaskBottomSheet(context, controller, task.id, brightness),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: AppColors.accent.getByBrightness(brightness)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'رفض',
                                  style: TextStyle(color: AppColors.accent.getByBrightness(brightness), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          Expanded(
                            flex: 2,
                            child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value ? null : () {
                                if (task.status.isPending) {
                                  controller.updateTaskStatus(task.id, Status.IN_PROGRESS);
                                  controller.isLoading.value = false;
                                  return;
                                }
                                showProofOfWorkBottomSheet(context, task);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: task.status.tryColor(brightness),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: controller.isLoading.value && task.status.isPending
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                                : Text(
                                task.status.isPending ? 'بدء المهمة' : 'تسليم للمراجعة',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, color: AppColors.white),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  if (task.status.isUnderReview || task.status.isCompleted || task.status.isCancelled || task.status.isRejected)
                    const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupplierEmptyTasksState extends StatelessWidget {
  const SupplierEmptyTasksState({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppFormWidgets.cardDecoration(context),
      child: Column(
        children: [
          Icon(
            Icons.assignment_turned_in_rounded,
            size: 60,
            color: AppColors.grey[200],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مهام نشطة حالياً',
            style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

void showProofOfWorkBottomSheet(BuildContext context, Task task) 
{
  final brightness = Theme.of(context).brightness;
  final controller = Get.find<SupplierDashboardController>();
  
  final noteController = TextEditingController();
  final adjustmentController = TextEditingController();
  final adjustmentType = 'NONE'.obs;
  final imageFile = Rxn<File>();
  final picker = ImagePicker();

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إرفاق إثبات التنفيذ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            Obx(() => imageFile.value == null
              ? OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      imageFile.value = File(picked.path);
                    }
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('التقاط أو اختيار صورة إثبات'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
                  ),
                )
              : Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.getByBrightness(brightness)),
                    image: DecorationImage(
                      image: FileImage(imageFile.value!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 28),
                      style: IconButton.styleFrom(backgroundColor: AppColors.black54),
                      onPressed: () => imageFile.value = null,
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            
            /*
            // --- قسم تعديل السعر (Price Adjustment Section) ---
            Text(
              'تعديل التكلفة (اختياري)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Row(
              children: [
                _buildTypeButton('NONE', 'بدون تعديل', adjustmentType, brightness),
                const SizedBox(width: 8),
                _buildTypeButton('INCREASE', 'زيادة', adjustmentType, brightness),
                const SizedBox(width: 8),
                _buildTypeButton('DECREASE', 'نقصان', adjustmentType, brightness),
              ],
            )),
            
            Obx(() => adjustmentType.value != 'NONE' 
              ? Column(
                  children: [
                    const SizedBox(height: 12),
                    TextField(
                      controller: adjustmentController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'قيمة ال${adjustmentType.value == 'INCREASE' ? 'زيادة' : 'نقصان'}',
                        prefixIcon: Icon(
                          adjustmentType.value == 'INCREASE' ? Icons.add_circle_outline : Icons.remove_circle_outline,
                          color: adjustmentType.value == 'INCREASE' ? AppColors.success.getByBrightness(brightness) : AppColors.accent.getByBrightness(brightness),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ) 
              : const SizedBox.shrink()),
            */
            
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'ملاحظات إضافية للمنسق (اختياري)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final double adjAmt = double.tryParse(adjustmentController.text) ?? 0.0;
                Get.back(); // close bottom sheet
                controller.updateTaskStatus(
                  task.id, 
                  Status.UNDER_REVIEW, 
                  note: noteController.text, 
                  urlImage: imageFile.value,
                  adjustmentAmount: adjAmt,
                  adjustmentType: adjustmentType.value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.getByBrightness(brightness),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تأكيد التسليم للمراجعة', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

/*
Widget _buildTypeButton(String type, String label, RxString currentType, Brightness brightness) {
  final bool isSelected = currentType.value == type;
  return Expanded(
    child: InkWell(
      onTap: () => currentType.value = type,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.getByBrightness(brightness) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary.getByBrightness(brightness) : AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.white : AppColors.textBody.getByBrightness(brightness),
          ),
        ),
      ),
    ),
  );
}
*/

class SupplierNotificationsSection extends GetView<SupplierDashboardController> {
  const SupplierNotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Obx(() {
      if (controller.recentNotifications.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: AppFormWidgets.cardDecoration(context),
          child: Column(
            children: [
              Icon(Icons.notifications_off_rounded, size: 40, color: AppColors.textSubtitle.getByBrightness(brightness)),
              const SizedBox(height: 10),
              Text(
                'لا توجد إشعارات حديثة',
                style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentNotifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notification = controller.recentNotifications[index];
          return Container(
            decoration: AppFormWidgets.cardDecoration(context),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded, 
                  color: AppColors.primary.getByBrightness(brightness),
                  size: 20
                ),
              ),
              title: Text(
                notification.title, 
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness)),
              ),
              subtitle: Text(
                notification.message, 
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 13),
              ),
              trailing: Text(
                DateFormatter.formatDateTime(notification.createdAt.toString()), 
                style: TextStyle(fontSize: 12, color: AppColors.textSubtitle.getByBrightness(brightness))
              ),
              onTap: () {
                Get.toNamed(AppRoutes.notifications);
              },
            ),
          );
        },
      );
    });
  }
}