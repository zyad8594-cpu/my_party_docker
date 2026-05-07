import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../data/models/notification.dart' show NotificationModel;

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    // Formatting date
    String formattedDate = '';
    try {
      final date = DateTime.parse(notification.createdAt);
      formattedDate = DateFormat('yyyy/MM/dd HH:mm', 'ar').format(date);
    } catch (_) {
      formattedDate = notification.createdAt;
    }

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: AppBar(
        title: const Text('تفاصيل الإشعار'),
        elevation: 0,
        backgroundColor: AppColors.background.getByBrightness(brightness),
        foregroundColor: AppColors.textBody.getByBrightness(brightness),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface.getByBrightness(brightness),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.primary.getByBrightness(brightness),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBody.getByBrightness(brightness),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'تاريخ الإشعار: $formattedDate',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textBody.getByBrightness(brightness).withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (notification.taskId > 0)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                         // Optional: Provide direct navigation from notification if available
                         Get.back();
                      },
                      icon: const Icon(Icons.assignment_rounded),
                      label: Text('المهمة المرتبطة: #${notification.taskId}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary.getByBrightness(brightness),
                        side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
