import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart' show AppColors;






//         حالة عدم وجود مناسبات
class EventEmptyState extends StatelessWidget {
  const EventEmptyState({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),

            /**
             *         ايقونة عدم وجود مناسبات
             */
            child: Icon(
              Icons.event_busy_rounded,
              size: 80,
              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),

          /**
           *         عنوان عدم وجود مناسبات
           */
          Text(
            'لا توجد مناسبات مسجلة',
            style: TextStyle(
              color: AppColors.textSubtitle.getByBrightness(brightness),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          /**
           *         وصف عدم وجود مناسبات
           */
          Text(
            'اضغط على زر الإضافة لإضافة مناسبة جديدة',
            style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
  