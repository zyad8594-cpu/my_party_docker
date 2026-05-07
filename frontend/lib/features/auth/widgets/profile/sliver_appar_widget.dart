import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/auth_service.dart' show AuthService;
import '../../../../core/components/app_image.dart' show AppImage;
import '../../../../core/controllers/auth_controller.dart' show AuthController;
import '../../../../core/themes/app_colors.dart' show AppColors;

class SliverApparWidget extends GetView<AuthController>{

  const SliverApparWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SliverAppBar(
      title: Text(
        'الملف الشخصي',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primary.getByBrightness(brightness),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
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
                              AppColors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
            
            Positioned(
              bottom: -30,
              right: -60,
              child: Icon(
                Icons.celebration_rounded,
                size: 250,
                color: AppColors.white.withValues(alpha: 0.05),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.getByBrightness(brightness),
                        child: ClipOval(
                          child: controller.user.value.imgUrl != null && controller.user.value.imgUrl!.isNotEmpty
                              ? AppImage.network(
                                  '${controller.user.value.imgUrl!}?v=${AuthService.profileImgVersion.value}',
                                  key: ValueKey('profile_img_${AuthService.profileImgVersion.value}'),
                                  width: 120, 
                                  height: 120,
                                  fit: BoxFit.cover,
                                  viewerTitle: 'الملف الشخصي',
                                  fallbackWidget: const Icon(Icons.person_rounded, size: 50, color: AppColors.white),
                                )
                            : const Icon(Icons.person_rounded, size: 50, color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.user.value.name.isNotEmpty?  controller.user.value.name:  'مستخدم',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.user.value.role == 'supplier' ? 'مزود خدمة' : (controller.user.value.role == 'coordinator' ? 'منسق حفلات' : (controller.user.value.role.isNotEmpty? controller.user.value.role: '')),
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
        onPressed: () => Get.back(),
      ),
    );
  }
  
}

