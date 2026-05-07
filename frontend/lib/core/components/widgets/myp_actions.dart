import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';


class MyPActions  {
  static Widget floatButton(BuildContext context, {required IconData icon, required Function() onPressed, Object? heroTag}) {
    final brightness = Theme.of(context).brightness;
    return Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient.getByBrightness(brightness),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed,
          backgroundColor: AppColors.transparent,
          elevation: 0,
          child: Icon(icon, color: AppColors.white, size: 30),
        ),
      );
  }
}