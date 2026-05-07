import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../../core/controllers/auth_controller.dart' show AuthController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
// import '../../../core/routes/app_routes.dart' show AppRoutes;
// import '../../auth/controller/auth_controller.dart' show AuthController;

import '../../notifications/controller/notification_controller.dart' show NotificationController;
import '../controller/home_controller.dart' show HomeController;
// import '../controller/main_layout_controller.dart' show MainLayoutController;
// import '../controller/home_controller.dart' show HomeController;

import '../widgets/home_welcome_section.dart' show HomeWelcomeSection;
import '../widgets/home_stats_grid.dart' show HomeStatsGrid;
import '../widgets/home_charts_section.dart' show HomeChartsSection;
import '../widgets/home_recent_notifications.dart' show HomeRecentNotifications;

class HomeScreen extends GetView<HomeController> 
{
  const HomeScreen({super.key});
@override
  Widget build(BuildContext context) 
  {
    Get.find<NotificationController>().fetchNotifications();
    final brightness = Theme.of(context).brightness;
    // final AuthController authController = Get.find<AuthController>();
    // final MainLayoutController mainController = Get.find<MainLayoutController>();
    
    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        title: 'لوحة التحكم',
        beforeActions: [
          
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ()=> controller.refreshStatistics(force: true),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeWelcomeSection(), const SizedBox(height: 32),
              HomeStatsGrid(), const SizedBox(height: 32),

              HomeChartsSection('حالات المهام', isTasks: true, sections: [
                {'title': 'pending', 'color': AppColors.brown },
                {'title': 'completed', 'color': AppColors.success.getByBrightness(brightness), },
                {'title': 'under_review', 'color': AppColors.warning.getByBrightness(brightness), },
                {'title': 'in_progress', 'color': AppColors.info.getByBrightness(brightness),},
                {'title': 'cancelled','color': AppColors.accent.getByBrightness(brightness), },
                {'title': 'rejected', 'color': AppColors.rejected.getByBrightness(brightness),},
              ]),
              const SizedBox(height: 32),
              
              HomeChartsSection('حالات المناسبات', isTasks: false, sections: [
                {'title': 'pending', 'color': AppColors.brown },
                {'title': 'completed', 'color': AppColors.success.getByBrightness(brightness), },
                {'title': 'in_progress', 'color': AppColors.info.getByBrightness(brightness), },
                {'title': 'cancelled', 'color': AppColors.accent.getByBrightness(brightness),},
              ]),
              const SizedBox(height: 32),

              const HomeRecentNotifications(),
            ],
          ),
        ),
      ),
    );
  }
}
