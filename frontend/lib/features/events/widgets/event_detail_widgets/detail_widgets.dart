export 'event_tabs/detail_tabs.dart';
import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart' show AppColors;

Widget buildStatusBadge(String text, Color color, {bool small = false}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: small ? 8 : 12,
      vertical: small ? 4 : 6,
    ),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: small ? 10 : 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget infoTile(IconData icon, String label, String value, Brightness brightness) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSubtitle.getByBrightness(brightness)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSubtitle.getByBrightness(brightness),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textBody.getByBrightness(brightness),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildInfoCard(
  Brightness brightness, {
  required String title,
  List<Widget>? items,
  Widget? child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface.getByBrightness(brightness),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(
        color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.05),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBody.getByBrightness(brightness),
          ),
        ),
        const SizedBox(height: 16),
        if (items != null) ...items,
        if (child != null) child,
      ],
    ),
  );
}
