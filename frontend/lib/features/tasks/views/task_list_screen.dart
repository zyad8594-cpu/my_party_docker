import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart';
import '../data/models/task.dart' show Task;
import '../controller/task_controller.dart' show TaskController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../shared/widgets/base_list_screen.dart';

class TaskListScreen extends BaseListScreen<Task, TaskController> {
  const TaskListScreen({super.key});

  @override
  String get title => 'المهام';

  @override
  String get searchPlaceholder => 'البحث عن مهمة...';

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient.getByBrightness(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.getByBrightness(Theme.of(context).brightness).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'add_task',
        onPressed: () => Get.toNamed(AppRoutes.taskAdd),
        backgroundColor: AppColors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_task_rounded,
          color: AppColors.white,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget buildHeader(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
                'الكل',
                'قيد الانتظار',
                'قيد التنفيذ',
                'مكتملة',
                'ملغاة',
              ].map((status) {
                return Obx(() {
                  final isSelected = controller.selectedStatus.value == status;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectedStatus.value = status;
                        }
                      },
                      selectedColor: AppColors.primary.getByBrightness(brightness),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.textBody.getByBrightness(brightness),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.surface.getByBrightness(brightness),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      showCheckmark: false,
                    ),
                  );
                });
              }).toList(),
        ),
      ),
    );
  }

  @override
  List<Task> getItems() => controller.filteredTasks;

  @override
  Widget buildListItem(BuildContext context, Task item) => _buildTaskCard(item, context);

  Widget _buildTaskCard(Task task, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final statusColor = task.status.tryColor(brightness);
    final statusText = task.status.tryText();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppFormWidgets.cardDecoration(context),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.taskDetail, arguments: task),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              task.typeTask ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBody.getByBrightness(brightness),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(statusText, statusColor),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.eventName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_rounded,
                                size: 12,
                                color: AppColors.textSubtitle.getByBrightness(brightness),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.description?.substring(
                                      0,
                                      task.description!.length > 20
                                          ? 20
                                          : task.description!.length,
                                    ) ??
                                    '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSubtitle.getByBrightness(brightness),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.edit_rounded,
                                  size: 18,
                                  color: AppColors.primary.getByBrightness(brightness),
                                ),
                                onPressed: () => Get.toNamed(
                                  AppRoutes.taskAdd,
                                  arguments: task,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.delete_rounded,
                                  size: 18,
                                  color: AppColors.accent.getByBrightness(brightness),
                                ),
                                onPressed: () => _delete(task.id, brightness),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }







  void _delete(int id, Brightness brightness) async {
Get.defaultDialog(
      title: 'تأكيد الحذف',
      titleStyle: TextStyle(
        color: AppColors.primary.getByBrightness(brightness),
        fontWeight: FontWeight.bold,
      ),
      middleText: 'هل أنت متأكد من حذف هذه المهمة؟',
      middleTextStyle: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
      backgroundColor: AppColors.surface.getByBrightness(brightness),
      radius: 20,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          controller.deleteTask(id);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent.getByBrightness(brightness),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('نعم، احذف', style: TextStyle(color: AppColors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text('إلغاء', style: TextStyle(color: AppColors.primary.getByBrightness(brightness))),
      ),
    );
  }
}
