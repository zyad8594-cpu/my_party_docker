import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/themes/app_colors.dart';
import '../../../core/components/custom_app_bar.dart';
import '../../../core/components/widgets/loading_widget.dart';
import '../../notifications/controller/notification_controller.dart' show NotificationController;
import '../controller/admin_dashboard_controller.dart';
// import '../../../core/routes/app_routes.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/components/app_image.dart';
import '../../notifications/data/models/notification.dart' show NotificationModel;
import '../../notifications/views/notification_detail_screen.dart' show NotificationDetailScreen;

class AdminDashboardScreen extends GetView<AdminDashboardController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    Get.find<NotificationController>().fetchNotifications();
    final brightness = Theme.of(context).brightness;
    final userName = AuthService.user.value.name.isNotEmpty ? AuthService.user.value.name : 'مدير النظام';

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: const CustomAppBar(
        title: 'لوحة تحكم الإدارة',
        showBackButton: false,
        showLogoutButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.fetchAdminStats(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingWidget();
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(brightness, userName),
                const SizedBox(height: 24),
                
                Text(
                  'نظرة عامة', 
                  style: 
                  TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.textBody.getByBrightness(brightness)
                  )
                ),
                const SizedBox(height: 16),

                _buildStatGrid(brightness),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Text(
                      'آخر الإشعارات', 
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: AppColors.textBody.getByBrightness(brightness)
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.notifications);
                      },
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildRecentNotifications(brightness),
                const SizedBox(height: 48),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomeHeader(Brightness brightness, String userName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.getByBrightness(brightness),
            AppColors.secondary.getByBrightness(brightness),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: AppImage.network(
              AuthService.user.value.imgUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              viewerTitle: userName,
              fallbackWidget: Container(
                width: 60,
                height: 60,
                color: AppColors.white24,
                child: const Icon(Icons.shield_rounded, size: 30, color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أهلاً بك',
                  style: TextStyle(color: AppColors.white70, fontSize: 14),
                ),
                Text(
                  userName,
                  style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Admin', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(Brightness brightness) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: [
        // --- المستخدمين والتفعيل ---
        _buildStatCard(
          brightness,
          'إجمالي المستخدمين',
          controller.activationStats['total_users']?.toString() ?? '0',
          Icons.group_rounded,
          AppColors.primary.getByBrightness(brightness),
        ),
        _buildStatCard(
          brightness,
          'مستخدمون مفعلون',
          controller.activationStats['active_users']?.toString() ?? '0',
          Icons.how_to_reg_rounded,
          AppColors.green,
        ),
        _buildStatCard(
          brightness,
          'مستخدمون غير مفعلين',
          controller.activationStats['inactive_users']?.toString() ?? '0',
          Icons.person_off_rounded,
          AppColors.red,
        ),

        _buildStatCard(
          brightness,
          'إجمالي المنسقين',
          controller.usersStats['COORDINATOR']?.toString() ?? '0',
          Icons.badge_rounded,
          AppColors.indigo,
        ),
        _buildStatCard(
          brightness,
          'منسقون مفعلون',
          controller.activationStats['active_coordinators']?.toString() ?? '0',
          Icons.verified_user_rounded,
          AppColors.success.getByBrightness(brightness),
        ),
        _buildStatCard(
          brightness,
          'منسقون غير مفعلين',
          controller.activationStats['inactive_coordinators']?.toString() ?? '0',
          Icons.block_flipped,
          AppColors.rejected.getByBrightness(brightness),
        ),
         
        _buildStatCard(
          brightness,
          'إجمالي الموردين',
          controller.usersStats['SUPPLIER']?.toString() ?? '0',
          Icons.local_shipping_rounded,
          AppColors.brown,
        ),
        _buildStatCard(
          brightness,
          'موردون مفعلون',
          controller.activationStats['active_suppliers']?.toString() ?? '0',
          Icons.storefront_rounded,
          AppColors.success.getByBrightness(brightness),
        ),
        _buildStatCard(
          brightness,
          'موردون غير مفعلين',
          controller.activationStats['inactive_suppliers']?.toString() ?? '0',
          Icons.no_meeting_room_rounded,
          AppColors.rejected.getByBrightness(brightness),
        ),

        _buildStatCard(
          brightness,
          'مسؤولين النظام',
          controller.usersStats['ADMIN']?.toString() ?? '0',
          Icons.admin_panel_settings_rounded,
          AppColors.purple,
        ),

        // --- الخدمات والاقتراحات ---
        _buildStatCard(
          brightness,
          'إجمالي الخدمات',
          controller.servicesStats.value.toString(),
          Icons.room_service_rounded,
          AppColors.deepOrange,
        ),
        _buildStatCard(
          brightness,
          'إجمالي الاقتراحات',
          controller.proposalsStats['total']?.toString() ?? '0',
          Icons.assessment_rounded,
          AppColors.info.getByBrightness(brightness),
        ),
        _buildStatCard(
          brightness,
          'اقتراحات معلقة',
          controller.proposalsStats['pending']?.toString() ?? '0',
          Icons.inbox_rounded,
          AppColors.warning.getByBrightness(brightness),
        ),
        _buildStatCard(
          brightness,
          'اقتراحات معتمدة',
          controller.proposalsStats['approved']?.toString() ?? '0',
          Icons.check_circle_rounded,
          AppColors.green,
        ),
        _buildStatCard(
          brightness,
          'اقتراحات مرفوضة',
          controller.proposalsStats['rejected']?.toString() ?? '0',
          Icons.cancel_rounded,
          AppColors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(Brightness brightness, String title, String count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(icon, size: 50, color: color.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  count, 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.textBody.getByBrightness(brightness)
                  )
                ),
                const SizedBox(height: 2),
                Text(
                  title, 
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10, 
                    color: AppColors.textSubtitle.getByBrightness(brightness),
                    height: 1.1,
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotifications(Brightness brightness) {
    if (controller.recentNotifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            'لا توجد إشعارات حديثة',
            style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
          ),
        ),
      );
    }
    
    return Column(
      children: controller.recentNotifications.map((notification) {
        final title = notification['title'] ?? 'إشعار';
        final message = notification['message'] ?? '';
        final isRead = (notification['is_read'] is int) 
            ? notification['is_read'] == 1 
            : notification['is_read'] == true;
            
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.getByBrightness(brightness),
            borderRadius: BorderRadius.circular(16),
            border: isRead ? null : Border.all(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            onTap: () {
              final notificationModel = NotificationModel.fromJson(Map<String, dynamic>.from(notification));
              Get.find<NotificationController>().markAsRead(notificationModel.id);
              Get.to(() => NotificationDetailScreen(notification: notificationModel));
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
              child: Icon(Icons.notifications_active_rounded, color: AppColors.primary.getByBrightness(brightness), size: 20),
            ),
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textBody.getByBrightness(brightness)),
            ),
            subtitle: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.textSubtitle.getByBrightness(brightness)),
            ),
          ),
        );
      }).toList(),
    );
  }

}
