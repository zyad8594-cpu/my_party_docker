import 'package:get/get.dart';
import 'package:flutter/material.dart';
  
import '../../../core/components/logout_dialog.dart' show logoutDialog;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../notifications/controller/notification_controller.dart' show NotificationController;
import '../data/models/client.dart' show Client;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/app_image.dart';
import '../widgets/client_detail_widgets.dart' show ClientDetailHeader, ClientContactSection, ClientEventsList;

class ClientDetailScreen extends StatelessWidget 
{
  const ClientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    final Client client = Get.arguments;

    return Scaffold
    (
      backgroundColor: AppColors.background.getByBrightness(brightness),
      body: CustomScrollView
      (
        slivers: <Widget>
        [
          _buildSliverAppBar(client, brightness),
          SliverToBoxAdapter
          (
            child: Padding
            (
              padding: const EdgeInsets.all(20),
              child: Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>
                [
                  ClientDetailHeader(client: client),
                  const SizedBox(height: 24),

                  ClientContactSection(client: client),
                  const SizedBox(height: 32),

                  Text
                  (
                    'المناسبات المرتبطة',
                    style: TextStyle
                    (
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBody.getByBrightness(brightness),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ClientEventsList(client: client),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Client client, Brightness brightness) 
  {
    return SliverAppBar
    (
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary.getByBrightness(brightness),
      flexibleSpace: FlexibleSpaceBar
      (
        background: Stack(
          fit: StackFit.expand,
          // decoration: BoxDecoration(gradient: AppColors.primaryGradient.getByBrightness(brightness)),
          children: [
             // Event Cover Image
                        ClipOval(
                  child: Image.asset(
                    'assets/icons/app_icon2009x1961.png',
                    fit: BoxFit.fill,
                  ),
                ),
                      
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.transparent,
                              AppColors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),

            Center(
              child: ClipOval(
                child: AppImage.network(
                  client.imgUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  viewerTitle: client.name,
                  fallbackWidget: Container(
                    width: 100,
                    height: 100,
                    color: AppColors.white.withValues(alpha: 0.2),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton
      (
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
        onPressed: () => Get.back(),
      ),

      actions: [
         IconButton(
            onPressed: () { 
                Get.toNamed(AppRoutes.notifications);
              // mainController.changePage(AuthService.userIsSupplier? 3 : 4);
              },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Obx(() {
                    final count = Get.find<NotificationController>().notiNotReadCount.value;
                    if (count == 0) return const SizedBox.shrink();
                    
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: logoutDialog,
            icon: Icon(Icons.logout_rounded, color: AppColors.accent.getByBrightness(brightness)),
          ),
      ],
    );
  }
}
