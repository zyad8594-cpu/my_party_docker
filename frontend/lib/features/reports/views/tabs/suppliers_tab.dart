import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/components/globle_card.dart' show GlobleCard;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../core/components/app_image.dart';
import '../../../suppliers/data/models/supplier.dart';
import '../../controller/reports_controller.dart' show ReportsController;
import '../widgets/reports_common_widgets.dart';

class SuppliersTab extends GetView<ReportsController> {
  const SuppliersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.supplierStats;
      final suppliers = controller.displaySuppliers;

      return Column(
        children: [
          ReportsCommonWidgets.buildSearchAndFilter(context, controller.suppliersSearchQuery, () => controller.exportReport('PDF', tabName: 'الموردين'), controller.collapseAll),
          Expanded(
            child: ListView(
              key: ValueKey('suppliers_list_${controller.collapseKey.value}'),
              primary: false,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                ReportsCommonWidgets.buildStatHeader([
                  GlobleCard(title: 'إجمالي الموردين النشطين', value: '${stats['total']}', icon: Icons.people, color: AppColors.blue),
                ]),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('قائمة الموردين وأدائهم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...suppliers.map((s) => _buildSupplierCard(context, s)),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSupplierCard(BuildContext context, Supplier supplier) {
    final stats = controller.getSupplierDetailedStats(supplier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: ClipOval(
          child: AppImage.network(
            supplier.imgUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            viewerTitle: supplier.name,
            fallbackWidget: const Icon(Icons.person),
          ),
        ),
        title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(supplier.email, style: const TextStyle(fontSize: 10)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.print, size: 20, color: AppColors.blueAccent),
              onPressed: () => controller.exportSingleItem('Supplier', supplier),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.amber, size: 16),
                    Text(' ${((supplier.averageRating ?? 0.0) / 5.0 * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('${supplier.details["services"].length} خدمات', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إحصائيات المهام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey[300]!),
                    color: AppColors.surface.getByBrightness(Theme.of(context).brightness),
                  ),
                  child: Column(
                    children: [
                      ReportsCommonWidgets.buildDetailedRow('الحالة', 'العدد', 'التكلفة', isHeader: true),
                      const Divider(height: 1),
                      ReportsCommonWidgets.buildDetailedRow('الكل', stats['taskCounts']['total'].toString(), '${stats['taskCosts']['total']} ر.س'),
                      ReportsCommonWidgets.buildDetailedRow('مكتملة', stats['taskCounts']['completed'].toString(), '${stats['taskCosts']['completed']} ر.س', color: AppColors.green),
                      ReportsCommonWidgets.buildDetailedRow('تنفيذ', stats['taskCounts']['inProgress'].toString(), '${stats['taskCosts']['inProgress']} ر.س', color: AppColors.orange),
                      ReportsCommonWidgets.buildDetailedRow('انتظار', stats['taskCounts']['pending'].toString(), '${stats['taskCosts']['pending']} ر.س', color: AppColors.blue),
                      ReportsCommonWidgets.buildDetailedRow('ملغاة/مرفوضة', (stats['taskCounts']['cancelled'] + stats['taskCounts']['rejected']).toString(), '${stats['taskCosts']['cancelled'] + stats['taskCosts']['rejected']} ر.س', color: AppColors.red),
                    ],
                  ),
                ),
                const Divider(),
                const Text('المشاركة في المناسبات', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReportsCommonWidgets.buildSmallInfo('الكل', '${stats['totalEvents']}'),
                    ReportsCommonWidgets.buildSmallInfo('مكتملة', '${stats['eventsCompleted']}'),
                    ReportsCommonWidgets.buildSmallInfo('تنفيذ', '${stats['eventsInProgress']}'),
                    ReportsCommonWidgets.buildSmallInfo('انتظار', '${stats['eventsPending']}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
