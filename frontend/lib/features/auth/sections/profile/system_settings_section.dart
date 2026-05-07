
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/glass_card.dart' show GlassCard;
import '../../../../core/controllers/auth_controller.dart' show AuthController;
import '../../../../core/services/config_service.dart' show ConfigService;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../core/themes/theme_service.dart' show ThemeService;
import '../../widgets/profile/sections_widgets.dart' show ProfileSectionsWidgets;

class SystemSettingsSection extends GetView<AuthController> {
  const SystemSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionsWidgets.title(context, 'إعدادات النظام'),
        const SizedBox(height: 12),
        _buildSystemSettingsSection(context),
      ],
    );
  }

  Widget _buildSystemSettingsSection(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            leading: ProfileSectionsWidgets.iconContainer(context, Icons.dark_mode_rounded, AppColors.primary.getByBrightness(brightness)),
            title: Text('الوضع الداكن', style: ProfileSectionsWidgets.settingTextStyle(context)),
            trailing: Switch(
              value: Get.isDarkMode,
              activeThumbColor: AppColors.primary.getByBrightness(brightness),
              onChanged: (value) {
                Get.find<ThemeService>().saveThemeToBox(value);
                Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          ProfileSectionsWidgets.divider(context),
          // Obx(() => ListTile(
          //   leading: _buildIconContainer(
          //     context, 
          //     Get.find<ConfigService>().notificationsEnabled.value ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
          //     AppColors.primary.getByBrightness(brightness),
          //   ),
          //   title: Text('تفعيل الإشعارات', style: _settingTextStyle(context)),
          //   trailing: Switch(
          //     value: Get.find<ConfigService>().notificationsEnabled.value,
          //     activeThumbColor: AppColors.primary.getByBrightness(brightness),
          //     onChanged: (value) => Get.find<ConfigService>().setNotificationsEnabled(value),
          //   ),
          // )),
          // _divider(context),
          Obx(() => ListTile(
            leading: ProfileSectionsWidgets.iconContainer(
              context,
              Get.find<ConfigService>().notificationSoundEnabled.value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              AppColors.accent.getByBrightness(brightness),
            ),
            title: Text('صوت الإشعارات', style: ProfileSectionsWidgets.settingTextStyle(context)),
            trailing: Switch(
              value: Get.find<ConfigService>().notificationSoundEnabled.value,
              activeThumbColor: AppColors.accent.getByBrightness(brightness),
              onChanged: (value) => Get.find<ConfigService>().setNotificationSoundEnabled(value),
            ),
          )),
          // Obx(() => Visibility(
          //   visible: Get.find<ConfigService>().notificationSoundEnabled.value,
          //   child: ListTile(
          //     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          //     title: Text('نغمة التنبيه', style: TextStyle(fontSize: 14, color: AppColors.textBody.getByBrightness(brightness))),
          //     subtitle: Text(
          //       Get.find<ConfigService>().notificationSoundName.value,
          //       style: TextStyle(fontSize: 12, color: AppColors.textSubtitle.getByBrightness(brightness)),
          //     ),
          //     trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSubtitle.getByBrightness(brightness)),
          //     onTap: () => _showSoundPicker(context),
          //   ),
          // )),
        ],
      ),
    );
  }
  
  
}