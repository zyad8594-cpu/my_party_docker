import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/components/custom_app_bar.dart';
import '../../home/controller/admin_dashboard_controller.dart';

class AdminManagementScreen extends GetView<AdminDashboardController> {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: const CustomAppBar(
        title: 'إدارة النظام',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الوصول السريع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickAccessTiles(brightness),
            const SizedBox(height: 32),
            Text(
              'التحكم المركزي (Super Admin)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 16),
            _buildCentralControlTiles(brightness),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessTiles(Brightness brightness) {
    return Row(
      children: [
        Expanded(
          child: _buildManagementTile(
            brightness,
            'المنسقين',
            Icons.badge_rounded,
            AppColors.indigo,
            () => Get.toNamed(AppRoutes.coordinators),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildManagementTile(
            brightness,
            'الموردين',
            Icons.local_shipping_rounded,
            AppColors.brown,
            () => Get.toNamed(AppRoutes.suppliers),
          ),
        ),
      ],
    );
  }

  Widget _buildCentralControlTiles(Brightness brightness) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildManagementTile(
                brightness,
                'إدارة المستخدمين',
                Icons.manage_accounts_rounded,
                AppColors.orangeAccent,
                () => Get.toNamed(AppRoutes.systemUsers),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementTile(
                brightness,
                'الأدوار والصلاحيات',
                Icons.shield_rounded,
                AppColors.purpleAccent,
                () => Get.toNamed(AppRoutes.roles),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildManagementTile(
          brightness,
          'إدارة الخدمات ومقترحات الموردين',
          Icons.room_service_rounded,
          AppColors.deepOrange,
          () => Get.toNamed(AppRoutes.services),
        ),
      ],
    );
  }

  Widget _buildManagementTile(Brightness brightness, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.getByBrightness(brightness),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textBody.getByBrightness(brightness),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
