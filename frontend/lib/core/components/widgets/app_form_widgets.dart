import 'package:flutter/material.dart' show BuildContext, Theme, InputDecoration, IconData, Icon, BorderRadius, Offset, Border, BoxShadow, EdgeInsets, BoxDecoration, OutlineInputBorder, BorderSide, Icons, IconButton, VoidCallback, TextStyle;
import '../../themes/app_colors.dart';


class AppFormWidgets 
{
  static InputDecoration fieldDecoration(String label, IconData icon, BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary.getByBrightness(brightness), size: 22),
    );
  }

  static InputDecoration passwordFieldDecoration({
    required String label,
    String? hintText,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onToggle,
    required BuildContext context,
  }) {
    final brightness = Theme.of(context).brightness;
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icon, color: AppColors.primary.getByBrightness(brightness), size: 22),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: AppColors.textSubtitle.getByBrightness(brightness),
          size: 20,
        ),
        onPressed: onToggle,
      ),
    );
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return BoxDecoration(
      color: AppColors.surface.getByBrightness(brightness),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.04),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration dateDecoration(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return BoxDecoration(
      color: AppColors.surface.getByBrightness(brightness),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.15),
      ),
    );
  }

  static InputDecoration searchDecoration(String hint, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return InputDecoration(
      hintStyle: TextStyle(
        color: AppColors.textSubtitle.getByBrightness(brightness),
      ),
      hintText: hint,
      prefixIcon: Icon(
        Icons.search_rounded,
        color: AppColors.primary.getByBrightness(brightness),
      ),
      filled: true,
      fillColor: AppColors.searchBarFillColor.getByBrightness(brightness).withValues(alpha: 0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }
}
