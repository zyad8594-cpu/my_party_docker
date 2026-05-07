import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/utils/string_toolse.dart' show StrTools;
import '../../../data/models/notification.dart' show NotificationModel;
import '../../notifications/controller/notification_controller.dart' show NotificationController;

class HomeRecentNotifications extends StatelessWidget 
{
  const HomeRecentNotifications({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    final NotificationController notificationController = Get.find<NotificationController>();

    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آخر الإشعارات',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
            TextButton(onPressed: () {
              Get.toNamed(AppRoutes.notifications);
            }, child: const Text('عرض الكل')),
          ],
        ),
        const SizedBox(height: 16),
        Obx((){
          final unreadNotis = notificationController.notifications.where((n) => !n.isRead).toList();
          unreadNotis.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final seenTypes = <String>{};
          final notifications = unreadNotis.where((n) => seenTypes.add(n.type ?? 'general')).take(3).toList();
          int index = 0;
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface.getByBrightness(brightness),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: notifications.map((noti)=> _buildNotificationItem(
                context, noti, index++

                )).toList()
              // [
              //   _buildNotificationItem(
              //     'تم إسناد مهمة جديدة',
              //     'قام أحمد بإسناد مهمة تنسيق الصوتيات.',
              //     'قبل 5 دقائق',
              //     Icons.assignment_turned_in_rounded,
              //     AppColors.primary.getByBrightness(brightness),
              //     brightness,
              //     0,
              //   ),
              //   _buildNotificationItem(
              //     'ميزانية تجوزت الحد',
              //     'تجاوزت مصروفات حفل التخرج الميزانية المحددة.',
              //     'قبل ساعة',
              //     Icons.warning_amber_rounded,
              //     AppColors.accent.getByBrightness(brightness),
              //     brightness,
              //     1,
              //   ),
              //   _buildNotificationItem(
              //     'اكتمل حفل الزفاف',
              //     'تم إغلاق جميع المهام المتعلقة بحفل زفاف آل عثمان.',
              //     'منذ ساعتين',
              //     Icons.done_all_rounded,
              //     AppColors.success.getByBrightness(brightness),
              //     brightness,
              //     2,
              //   ),
              // ],
            ),
          );
        }
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel n,
    int index,
  ) {
    final brightness = Theme.of(context).brightness;
    final desc = StrTools.take(n.message.split("\n").join(" "), 50);
    final time = DateFormat('yy/mm/dd').format(DateTime.parse(n.createdAt));
    final color = AppColors.green;
    final icon = Icons.g_mobiledata;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (index * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(offset: Offset(50 * (1 - val), 0), child: child),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          n.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textBody.getByBrightness(brightness),
          ),
        ),
        subtitle: Text(
          desc,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSubtitle.getByBrightness(brightness),
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(fontSize: 10, color: AppColors.text.getByBrightness(brightness)),
        ),
      ),
    );
  }
}
