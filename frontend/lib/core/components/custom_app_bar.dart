// import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
  
import '../../features/notifications/controller/notification_controller.dart';
import '../api/auth_service.dart';
// import '../controllers/main_layout_controller.dart';
import '../themes/app_colors.dart';
import '../routes/app_routes.dart' show AppRoutes;
import 'logout_dialog.dart' show logoutDialog;
import 'app_image.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget 
{
  final String title;
  final List<Widget> beforeActions;
  final List<Widget> afterActions;
  final bool showBackButton;
  final bool showNotificationButton;
  final bool showLogoutButton;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key, 
    required this.title, 
    this.beforeActions = const [],
    this.afterActions = const [],
    this.showBackButton = false,
    this.showNotificationButton = true,
    this.showLogoutButton = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    final Color textColor = AppColors.textBasec.getByBrightness(brightness);
    // final mainController = Get.find<MainLayoutController>();
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      // backgroundColor: AppColors.primary.getByBrightness(brightness),
      backgroundColor: AppColors.appBarBackground.getByBrightness(brightness),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: textColor),
      bottom: bottom,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
              onPressed: () => Get.back(),
            )
          : Obx(() => IconButton(
              onPressed: () => Get.toNamed(AppRoutes.profile),
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.getByBrightness(brightness),
                child: ClipOval(
                  child: Get.find<AuthService>().isLoggedIn && AuthService.user.value.imgUrl != null
                    ? AppImage.network(
                        '${AuthService.user.value.imgUrl!}?v=${AuthService.profileImgVersion.value}',
                        key: ValueKey('bar_profile_img_${AuthService.profileImgVersion.value}'),
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        isClickable: false,
                        viewerTitle: 'الملف الشخصي',
                        fallbackWidget: const Icon(Icons.person, size: 20, color: Colors.white),
                      )
                    : const Icon(Icons.person, size: 20, color: Colors.white),
                ),
              ),
            )),
      actions: [
        ...beforeActions,
        if(showNotificationButton) IconButton(
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
          if(showLogoutButton) IconButton(
            onPressed: logoutDialog,
            icon: Icon(Icons.logout_rounded, color: AppColors.accent.getByBrightness(brightness)),
          ),
          if(showNotificationButton || showLogoutButton) 
            const SizedBox(width: 16),
          ...afterActions,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
