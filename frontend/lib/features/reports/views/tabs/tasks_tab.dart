import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/components/globle_card.dart' show GlobleCard;
import '../../../../core/utils/date_formatter.dart' show DateFormatter;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../core/components/app_image.dart';
import '../../../tasks/data/models/task.dart';
import '../../../../core/utils/status.dart';
import '../../controller/reports_controller.dart' show ReportsController;
import '../widgets/reports_common_widgets.dart';

class TasksTab extends GetView<ReportsController> {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.taskStats;
      final tasks = controller.displayTasks;

      return Column(
        children: [
          ReportsCommonWidgets.buildSearchAndFilter(context, controller.tasksSearchQuery, () => controller.exportReport('PDF', tabName: 'المهام'), controller.collapseAll),
          Expanded(
            child: ListView(
              key: ValueKey('tasks_list_${controller.collapseKey.value}'),
              padding: const EdgeInsets.only(bottom: 20),
              primary: false,
              children: [
                ReportsCommonWidgets.buildStatHeader([
                  GlobleCard(title: 'إجمالي المهام', value: '${stats['total']}', icon: Icons.task, color: AppColors.blue),
                  GlobleCard(title: 'مكتملة', value: '${stats['completed']}', icon: Icons.check_circle, color: AppColors.green),
                  GlobleCard(title: 'قيد التنفيذ', value: '${stats['inProgress']}', icon: Icons.run_circle_outlined, color: AppColors.orange),
                  GlobleCard(title: 'قيد الانتظار', value: '${stats['pending']}', icon: Icons.hourglass_empty, color: AppColors.blueAccent),
                  GlobleCard(title: 'ملغاة', value: '${stats['cancelled']}', icon: Icons.cancel, color: AppColors.red),
                  GlobleCard(title: 'مرفوضة', value: '${stats['rejected']}', icon: Icons.thumb_down, color: AppColors.black),
                  GlobleCard(title: 'قيد المراجعة', value: '${stats['inReview']}', icon: Icons.rate_review, color: AppColors.purple),
                  GlobleCard(title: 'إجمالي المصروفات', value: '${stats['totalExpenses'].toStringAsFixed(0)}', icon: Icons.money_off, color: AppColors.deepOrange),
                ]),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('قائمة المهام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...tasks.map((t) => _buildTaskCard(context, t)),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final brightness = Theme.of(context).brightness;
    final supplier = controller.supplierController.suppliers.firstWhereOrNull((s) => s.id == task.userAssignId);
    final event = controller.eventController.events.firstWhereOrNull((e) => e.id == task.eventId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: task.status.tryColor(brightness).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.task, color: task.status.tryColor(brightness)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.typeTask ?? 'مهمة', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(task.status.tryText(), style: TextStyle(color: task.status.tryColor(brightness), fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${task.cost.toStringAsFixed(0)} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.green)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => controller.exportSingleItem('Task', task),
                  child: const Icon(Icons.print, size: 20, color: AppColors.blueAccent),
                ),
              ],
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(16.0),
        children: [
          // Event info
          if (event != null) ...[
            Row(
              children: [
                ClipOval(
                  child: AppImage.network(
                    event.imgUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    viewerTitle: event.eventName,
                    fallbackWidget: const Icon(Icons.event),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('المناسبة', style: TextStyle(fontSize: 10, color: AppColors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
          ],

          // Supplier Info
          Row(
            children: [
              ClipOval(
                child: AppImage.network(
                  supplier?.imgUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  viewerTitle: supplier?.name,
                  fallbackWidget: const Icon(Icons.person),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.assigneName ?? supplier?.name ?? 'غير معين', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (supplier?.email != null && supplier!.email.isNotEmpty) 
                      Text(supplier.email, style: TextStyle(fontSize: 11, color: AppColors.grey[600])),
                    if (supplier?.phoneNumber != null && supplier!.phoneNumber!.isNotEmpty) 
                      Text(supplier.phoneNumber!, style: TextStyle(fontSize: 11, color: AppColors.grey[600])),
                    if (supplier == null)
                      Text('المورد المكلّف', style: TextStyle(fontSize: 10, color: AppColors.grey[600])),
                  ],
                ),
              ),
              if (task.rating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.amber, size: 16),
                    Text(' ${task.rating!.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          
          const Divider(height: 24),
          
          // Dates & Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const Text('وصف المهمة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(task.description!, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                  const Divider(),
                ],
                _buildDateRow('تاريخ المهمة', task.createdAt),
                _buildDateRow('تاريخ الاستحقاق', task.dateDue),
                _buildDateRow('تاريخ التسليم', task.dateCompletion),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          Text(DateFormatter.format(dateStr), style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
