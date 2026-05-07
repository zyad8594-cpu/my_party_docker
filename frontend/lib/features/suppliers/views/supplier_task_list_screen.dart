// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart';
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;

import '../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../core/components/empty_state_widget.dart' show EmptyStateWidget;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../controller/supplier_dashboard_controller.dart' show SupplierDashboardController;
import '../../tasks/data/models/task.dart' show Task;
import 'package:intl/intl.dart' show DateFormat;

import '../widgets/supplier_dashboard_widgets.dart' show showProofOfWorkBottomSheet;
import '../../tasks/widgets/task_utils.dart' show showRejectTaskBottomSheet;


class SupplierTaskListScreen extends GetView<SupplierDashboardController> 
{
  const SupplierTaskListScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    // We can reuse the same controller or a similar one
    final controller = Get.find<SupplierDashboardController>();
    

    return RefreshIndicator(
      onRefresh: controller.refreshDashboard,
      child: Scaffold(
        backgroundColor: AppColors.background.getByBrightness(brightness),
        appBar: CustomAppBar(title: 'مهامي'),
      
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextFormField(
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'بحث في مهامي...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.card.getByBrightness(brightness),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            _buildFilterChips(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingWidget();
                }
      
                // Actually, let's just use the controller's activeTasks for now or fetch all.
                // For a better implementation, the controller should have a 'allSupplierTasks' list.
      
                
                final filteredTasks = controller.filteredTasks;
      
                if (filteredTasks.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const EmptyStateWidget(message: 'لا توجد مهام مطابقة للمرشح', icon: Icons.assignment_turned_in_rounded)
                      ),
                    ],
                  );
                }
      
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(context, filteredTasks[index]);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) 
  {
    final controller = Get.find<SupplierDashboardController>();
    final brightness = Theme.of(context).brightness;
    final filters = StatusTools.getAllStatusText(prepend: ['الكل'], remove: ['ملغاة']);
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Obx(
            () => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(filters[index]),
                selected: controller.selectedFilter.value == filters[index],
                onSelected: (val) => controller.selectedFilter.value = filters[index],
                selectedColor: AppColors.primary.getByBrightness(brightness),
                labelStyle: TextStyle(
                  color: controller.selectedFilter.value == filters[index]
                      ? AppColors.white
                      : AppColors.textBody.getByBrightness(brightness),
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: AppColors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                showCheckmark: false,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) 
  {
    final controller = Get.find<SupplierDashboardController>();
    final brightness = Theme.of(context).brightness;
    
    

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.taskDetail, arguments: task),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          task.eventName ,
                          style: TextStyle(
                            color: AppColors.textSubtitle.getByBrightness(brightness),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(task.status, brightness),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'تاريخ التسليم: ${_formatDate(task.dateDue)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (task.status == Status.IN_PROGRESS || task.status == Status.PENDING)
                Row(
                  children: [
                    if (task.status.isPending) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => showRejectTaskBottomSheet(context, controller, task.id, brightness),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent.getByBrightness(brightness),
                            side: BorderSide(color: AppColors.accent.getByBrightness(brightness)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'رفض المهمة',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () {
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
                          } else if (task.status.isInProgress) {
                            showProofOfWorkBottomSheet(context, task);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: task.status.tryColor(brightness),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: controller.isLoading.value && (task.status.isPending || task.status.isInProgress)
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                          : Text(
                              task.status.isPending ? 'بدء المهمة' : 'تسليم للمراجعة',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      )),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildStatusBadge(Status status, Brightness brightness) {
    Color color=status.color(brightness);
    
    

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.tryText(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd', 'ar').format(date);
    } catch (_) {
      return dateStr;
    }
  }


}
