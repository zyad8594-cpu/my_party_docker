import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/components/globle_card.dart' show GlobleCard;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../controller/reports_controller.dart' show ReportsController;
import '../widgets/reports_common_widgets.dart';

class FinancialTab extends GetView<ReportsController> {
  const FinancialTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.financialStats;
      // final brightness = Theme.of(context).brightness;

      return SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            ReportsCommonWidgets.buildSearchAndFilter(context, controller.financialSearchQuery, () => controller.exportReport('PDF'), controller.collapseAll),
            ReportsCommonWidgets.buildStatHeader([
              GlobleCard(title: 'إجمالي الميزانية', value: '${stats['totalBudget'].toStringAsFixed(0)}', icon: Icons.account_balance, color: AppColors.blue),
              GlobleCard(title: 'إجمالي الدخل', value: '${stats['totalIncome'].toStringAsFixed(0)}', icon: Icons.trending_up, color: AppColors.green),
              GlobleCard(title: 'إجمالي المصروفات', value: '${stats['totalExpenses'].toStringAsFixed(0)}', icon: Icons.trending_down, color: AppColors.red),
              GlobleCard(title: 'إجمالي المتبقي', value: '${stats['totalRemaining'].toStringAsFixed(0)}', icon: Icons.account_balance_wallet, color: AppColors.purple),
              GlobleCard(title: 'إجمالي الأرباح', value: '${stats['totalProfit'].toStringAsFixed(0)}', icon: Icons.monetization_on, color: AppColors.teal),
              GlobleCard(title: 'إجمالي الخسارة', value: '${stats['totalLoss'].toStringAsFixed(0)}', icon: Icons.money_off, color: AppColors.redAccent),
            ]),
            // const SizedBox(height: 20),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Container(
            //     padding: const EdgeInsets.all(20),
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(colors: [AppColors.primary.getByBrightness(brightness), AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.7)]),
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: Column(
            //       children: [
            //         const Text('تحليل كفاءة الميزانية', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            //         const SizedBox(height: 20),
            //         _buildFinancialCircularIndicator(stats['totalExpenses'], stats['totalBudget'], 'المصروفات من الميزانية'),
            //       ],
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),
            // ReportsCommonWidgets.buildSectionHeader('التدفق المالي'),
            // _buildFinancialSummaryCard(context, 'صافي التدفق النقدي', '${(stats['totalIncome'] - stats['totalExpenses']).toStringAsFixed(0)} ر.س', Icons.swap_vert),
          ],
        ),
      );
    });
  }

  // Widget _buildFinancialCircularIndicator(double value, double total, String label) {
  //   final percent = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
  //   return Column(
  //     children: [
  //       Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           SizedBox(
  //             height: 120,
  //             width: 120,
  //             child: CircularProgressIndicator(
  //               value: percent,
  //               strokeWidth: 10,
  //               backgroundColor: AppColors.white.withValues(alpha: 0.2),
  //               valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
  //             ),
  //           ),
  //           Text('${(percent * 100).toStringAsFixed(1)}%', style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //       const SizedBox(height: 12),
  //       Text(label, style: const TextStyle(color: AppColors.white, fontSize: 14)),
  //     ],
  //   );
  // }

  // Widget _buildFinancialSummaryCard(BuildContext context, String title, String value, IconData icon) {
  //   final brightness = Theme.of(context).brightness;
  //   return Card(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     child: ListTile(
  //       leading: Icon(icon, color: AppColors.primary.getByBrightness(brightness)),
  //       title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  //       trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue)),
  //     ),
  //   );
  // }

}
