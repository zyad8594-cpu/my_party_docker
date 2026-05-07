import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/main_layout_controller.dart' show MainLayoutController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../controller/supplier_dashboard_controller.dart' show SupplierDashboardController;
import '../widgets/supplier_dashboard_widgets.dart' show SupplierActiveTasksList, SupplierEmptyTasksState, SupplierGreeting, SupplierStatsGrid, SupplierNotificationsSection;
import '../../../core/routes/app_routes.dart' show AppRoutes;

class SupplierDashboardScreen extends GetView<SupplierDashboardController> {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        title: 'لوحة التحكم',
        beforeActions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Get.toNamed(AppRoutes.supplierReports),
            tooltip: 'التقارير',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        return RefreshIndicator(
          onRefresh: () async => controller.refreshDashboard(),
          color: AppColors.primary.getByBrightness(brightness),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SupplierGreeting(),
              const SizedBox(height: 24),

              const SupplierStatsGrid(),
              const SizedBox(height: 24),
              
              const SizedBox(height: 32),
              _buildSectionHeader(context,'المهام الحالية', 'عرض الكل'),
              const SizedBox(height: 16),

              if (controller.activeTasks.isEmpty)
                const SupplierEmptyTasksState()
              else
                const SupplierActiveTasksList(),
              const SizedBox(height: 32),

              _buildSectionHeader(context,'آخر الإشعارات', 'عرض المزيد', onAction: () {
                Get.toNamed(AppRoutes.notifications);
              }),
              const SizedBox(height: 16),
              const SupplierNotificationsSection(),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action, {VoidCallback? onAction}) 
  {
    final brightness = Theme.of(context).brightness;
    final  mainLayoutController = Get.find<MainLayoutController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textBody.getByBrightness(brightness),
          ),
        ),
        TextButton(
          onPressed: onAction ?? () => mainLayoutController.changePage(2),
          child: Text(
            action,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary.getByBrightness(brightness),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
