import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/utils/status.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/components/custom_app_bar.dart';
import '../../../core/components/globle_card.dart';
import '../../../core/components/widgets/loading_widget.dart';
import '../controller/reports_controller.dart';
import '../../tasks/data/models/task.dart';

class SupplierReportScreen extends GetView<ReportsController> {
  const SupplierReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    // تأكد من أننا نستخدم البيانات الخاصة بالمورد فقط إذا كان المستخدم مورداً
    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: const CustomAppBar(
        title: 'تقارير أداء المورد',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        // جلب المهام الخاصة بالمورد الحالي فقط
        final myTasks = controller.taskController.tasks.where((t) => t.userAssignId == AuthService.user.value.id).toList();
        final stats = _computeSupplierStats(myTasks);

        return RefreshIndicator(
          onRefresh: controller.refreshStatistics,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummarySection(stats),
                const SizedBox(height: 32),
                const Text(
                  'التدفق النقدي والارباح',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildEarningsCard(brightness, stats['totalEarnings']),
                const SizedBox(height: 32),
                const Text(
                  'أداء المهام المستلمة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTasksHistory(context, myTasks),
              ],
            ),
          ),
        );
      }),
    );
  }

  Map<String, dynamic> _computeSupplierStats(List<Task> tasks) {
    double totalEarnings = 0;
    int completed = 0;
    int pending = 0;
    int rejected = 0;
    int inProgress = 0;

    for (var t in tasks) {
      if (t.status.isCompleted) {
        completed++;
        totalEarnings += t.cost;
      } else if (t.status.isPending) {
        pending++;
      } else if (t.status.isRejected) {
        rejected++;
      } else if (t.status.isInProgress) {
        inProgress++;
      }
    }

    return {
      'totalTasks': tasks.length,
      'completed': completed,
      'pending': pending,
      'rejected': rejected,
      'inProgress': inProgress,
      'totalEarnings': totalEarnings,
    };
  }

  Widget _buildSummarySection(Map<String, dynamic> stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: Get.width * 0.43,
          child: GlobleCard(
            title: 'إجمالي المهام',
            value: stats['totalTasks'].toString(),
            icon: Icons.assignment_rounded,
            color: AppColors.blue,
          ),
        ),
        SizedBox(
          width: Get.width * 0.43,
          child: GlobleCard(
            title: 'المهام المكتملة',
            value: stats['completed'].toString(),
            icon: Icons.check_circle_rounded,
            color: AppColors.green,
          ),
        ),
        SizedBox(
          width: Get.width * 0.43,
          child: GlobleCard(
            title: 'مهام قيد التنفيذ',
            value: stats['inProgress'].toString(),
            icon: Icons.sync_rounded,
            color: AppColors.orange,
          ),
        ),
        SizedBox(
          width: Get.width * 0.43,
          child: GlobleCard(
            title: 'مهام مرفوضة',
            value: stats['rejected'].toString(),
            icon: Icons.thumb_down_alt_rounded,
            color: AppColors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsCard(Brightness brightness, double earnings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.getByBrightness(brightness),
            AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_rounded, color: AppColors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'صافي الأرباح المكتملة',
            style: TextStyle(color: AppColors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${earnings.toStringAsFixed(2)} ر.س',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksHistory(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('لا توجد مهام حالياً'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length > 5 ? 5 : tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final brightness = Theme.of(context).brightness;
        return Card(
          elevation: 0,
          color: AppColors.surface.getByBrightness(brightness),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(task.typeTask ?? 'مهمة', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(task.createdAt),
            trailing: Text(
              '${task.cost} ر.س',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.green),
            ),
          ),
        );
      },
    );
  }
}
