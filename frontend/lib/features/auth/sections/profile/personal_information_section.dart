
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/components/glass_card.dart' show GlassCard;
import '../../../../core/controllers/auth_controller.dart' show AuthController;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../widgets/profile/sections_widgets.dart' show ProfileSectionsWidgets;

class PersonalInformationSection extends GetView<AuthController> {
  const PersonalInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionsWidgets.title(context, 'المعلومات الشخصية'),
        const SizedBox(height: 12),
        _buildPersonalInfoSection(context),
      ],
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ProfileSectionsWidgets.tile(
            context,
            icon: Icons.email_rounded,
            color: AppColors.info.getByBrightness(brightness),
            label: 'البريد الإلكتروني',
            value: controller.user.value.email ?? 'غير متوفر',
            showBorder: true,
          ),
          ProfileSectionsWidgets.tile(
            context,
            icon: Icons.phone_rounded,
            color: AppColors.success.getByBrightness(brightness),
            label: 'رقم الجوال',
            value: controller.user.value.phoneNumber ?? 'غير متوفر',
            showBorder: false,
          ),

          ...((List<MapEntry<String, dynamic>> extraDetails)=>extraDetails.asMap().entries.map((entry) {
                final isLast = entry.key == extraDetails.length - 1;
                final e = entry.value;
                return ProfileSectionsWidgets.tile(
                  context,
                  icon: Icons.info_outline_rounded,
                  color: AppColors.primary.getByBrightness(brightness),
                  label: e.key.replaceAll('_', ' ').capitalizeFirst!,
                  value: e.value.toString(),
                  showBorder: !isLast,
                );
              }))(controller.user.value.details.entries
          .where((e) => e.value != null && e.value is! Map && e.value is! List)
          .map((e)=> MapEntry(e.key, (e.value == null || e.value == '')? 'غير محدد': e.value))
          .toList())
        ],
      ),
    );
  }
  
}