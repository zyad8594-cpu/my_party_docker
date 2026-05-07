import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import '../../../../core/components/widgets/app_detail_widgets.dart';
import '../../../../core/components/app_image.dart';
import '../../../../core/themes/app_colors.dart';


class TaskProofOfWorkSection extends StatelessWidget {
  final Task task;

  const TaskProofOfWorkSection({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppDetailWidgets.buildInfoCard(
      context,
      title: 'إثبات الإنجاز',
      icon: Icons.photo_library_rounded,
      child: Column(
        children: [
          
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AppImage.network(
              task.urlImage,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              viewerTitle: 'إثبات الإنجاز - ${task.typeTask}',
              fallbackWidget: Container(
                height: 200,
                width: double.infinity,
                color: AppColors.grey[100],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_rounded,
                        color: AppColors.grey[400],
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لم يتم رفع صورة للإنجاز',
                        style: TextStyle(color: AppColors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background.getByBrightness(brightness).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.notes ?? 'لا توجد ملاحظات',
                    style: TextStyle(
                      color: AppColors.textBody.getByBrightness(brightness),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
