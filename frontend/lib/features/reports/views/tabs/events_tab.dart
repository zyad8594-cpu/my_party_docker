import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/components/globle_card.dart' show GlobleCard;
import '../../../../../core/utils/date_formatter.dart' show DateFormatter;
import '../../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../../core/components/app_image.dart';
import '../../../events/data/models/event.dart';
import '../../../../../core/utils/status.dart';
import '../../../../../core/utils/translate_duration_unit.dart';
import '../../controller/reports_controller.dart' show ReportsController;
import '../widgets/reports_common_widgets.dart';

class EventsTab extends GetView<ReportsController> {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.eventStats;
      final events = controller.displayEvents;
      
      return Column(
        children: [
          ReportsCommonWidgets.buildSearchAndFilter(context, controller.eventsSearchQuery, () => controller.exportReport('PDF', tabName: 'المناسبات'), controller.collapseAll),
          Expanded(
            child: ListView(
              key: ValueKey('events_list_${controller.collapseKey.value}'),
              primary: false,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                ReportsCommonWidgets.buildStatHeader([
                  GlobleCard(title: 'إجمالي المناسبات', value: '${stats['total']}', icon: Icons.event, color: AppColors.blue),
                  GlobleCard(title: 'مكتملة', value: '${stats['completed']}', icon: Icons.check_circle, color: AppColors.green),
                  GlobleCard(title: 'قيد الانتظار', value: '${stats['pending']}', icon: Icons.hourglass_empty, color: AppColors.orange),
                  GlobleCard(title: 'قيد التنفيذ', value: '${stats['inProgress']}', icon: Icons.run_circle_outlined, color: AppColors.blueAccent),
                  GlobleCard(title: 'ملغاة', value: '${stats['cancelled']}', icon: Icons.cancel, color: AppColors.red),
                  GlobleCard(title: 'إجمالي الميزانية', value: '${stats['totalBudget'].toStringAsFixed(0)}', icon: Icons.money, color: AppColors.purple),
                  GlobleCard(title: 'إجمالي المصروفات', value: '${stats['totalExpenses'].toStringAsFixed(0)}', icon: Icons.outbox, color: AppColors.deepOrange),
                  GlobleCard(title: 'إجمالي الدفعات', value: '${stats['totalPayments'].toStringAsFixed(0)}', icon: Icons.payments, color: AppColors.teal),
                ]),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('قائمة المناسبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...events.map((e) => _buildEventCard(context, e)),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final brightness = Theme.of(context).brightness;
    final progress = event.totalTasks > 0 ? (event.completedTasks / event.totalTasks) : 0.0;
    
    final stats = controller.getEventDetailedStats(event);
    final counts = stats['counts'] as Map<Status, int>;
    final costs = stats['costs'] as Map<Status, double>;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: ClipOval(
          child: AppImage.network(
            event.imgUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            viewerTitle: event.eventName,
            fallbackWidget: const Icon(Icons.event),
          ),
        ),
        title: Text(event.eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormatter.format(event.eventDate), style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.print, size: 20, color: AppColors.blueAccent),
              onPressed: () => controller.exportSingleItem('Event', event),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: event.status.tryColor(brightness).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(event.status.tryText(), style: TextStyle(color: event.status.tryColor(brightness), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- معلومات العميل ---
                const Text('معلومات العميل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipOval(
                      child: AppImage.network(
                        event.clientImg,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        viewerTitle: event.clientName,
                        fallbackWidget: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(event.clientEmail, style: TextStyle(fontSize: 11, color: AppColors.grey[600])),
                          Text(event.clientPhone, style: TextStyle(fontSize: 11, color: AppColors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // --- تحليل الربح والميزانية ---
                const Text('التحليل المالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReportsCommonWidgets.buildSmallInfo('الميزانية', event.budget.toStringAsFixed(0)),
                    ReportsCommonWidgets.buildSmallInfo('المصروفات', event.totalExpenses.toStringAsFixed(0), color: AppColors.red),
                    ReportsCommonWidgets.buildSmallInfo('الدفعات', event.totalIncome.toStringAsFixed(0), color: AppColors.green),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReportsCommonWidgets.buildSmallInfo('المتبقي للعميل', (event.budget - event.totalIncome).toStringAsFixed(0), color: AppColors.orange),
                    ReportsCommonWidgets.buildSmallInfo('الربح المتوقع', (event.budget - event.totalExpenses).toStringAsFixed(0), color: AppColors.blue),
                    ReportsCommonWidgets.buildSmallInfo('الربح الفعلي', (event.totalIncome - event.totalExpenses).toStringAsFixed(0), color: AppColors.teal),
                  ],
                ),
                
                const Divider(height: 24),

                // --- تفاصيل المهام لكل حالة ---
                const Text('تفاصيل المهام والحالات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey[300]!),
                    // color: AppColors.surface.getByBrightness(brightness),
                  ),
                  child: Column(
                    children: [
                      ReportsCommonWidgets.buildDetailedRow('الحالة', 'العدد', 'التكلفة', isHeader: true),
                      const Divider(height: 1),
                      ReportsCommonWidgets.buildDetailedRow('مكتملة', counts[Status.COMPLETED].toString(), '${costs[Status.COMPLETED]?.toStringAsFixed(0)} ر.س', color: AppColors.green),
                      ReportsCommonWidgets.buildDetailedRow('قيد التنفيذ', counts[Status.IN_PROGRESS].toString(), '${costs[Status.IN_PROGRESS]?.toStringAsFixed(0)} ر.س', color: AppColors.orange),
                      ReportsCommonWidgets.buildDetailedRow('قيد الانتظار', counts[Status.PENDING].toString(), '${costs[Status.PENDING]?.toStringAsFixed(0)} ر.س', color: AppColors.blue),
                      ReportsCommonWidgets.buildDetailedRow('قيد المراجعة', (counts[Status.UNDER_REVIEW] ?? 0).toString(), '${(costs[Status.UNDER_REVIEW] ?? 0).toStringAsFixed(0)} ر.س', color: AppColors.purple),
                      ReportsCommonWidgets.buildDetailedRow('مرفوضة', (counts[Status.REJECTED] ?? 0).toString(), '${(costs[Status.REJECTED] ?? 0).toStringAsFixed(0)} ر.س', color: AppColors.black),
                      ReportsCommonWidgets.buildDetailedRow('ملغاة', counts[Status.CANCELLED].toString(), '${costs[Status.CANCELLED]?.toStringAsFixed(0)} ر.س', color: AppColors.red),
                    ],
                  ),
                ),

                const Divider(height: 24),

                // --- مدة المناسبة ونسبة الإنجاز ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المدة: ${translateDurationUnit(event.eventDurationUnit, event.eventDuration)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('الموردين: ${controller.getSuppliersCountForEvent(event.id)}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.getByBrightness(brightness)),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text('نسبة الإنجاز الإجمالية: ${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
