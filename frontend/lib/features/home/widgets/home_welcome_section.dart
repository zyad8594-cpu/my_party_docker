import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/themes/app_colors.dart' show AppColors;

class HomeWelcomeSection extends StatelessWidget 
{

  const HomeWelcomeSection({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            'أهلاً بك، ${AuthService.user.value.name.isNotEmpty? AuthService.user.value.name : 'أحمد'}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBody.getByBrightness(brightness),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'إليك تحديثات أعمالك لهذا اليوم',
          style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 14),
        ),
      ],
    );
  }
}
