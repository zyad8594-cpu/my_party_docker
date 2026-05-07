export 'event_search_and_filters_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../../core/themes/app_colors.dart' show AppColors, AppColorSet;
import '../../controller/event_controller.dart' show EventController;
import '../../../../core/utils/status.dart';
import '../../data/models/event.dart' show Event;
import '../../../../core/components/app_image.dart';

part 'event_card_widget.dart';

class EventListWidgets {
  static void showDeleteDialog(
    BuildContext context,
    int id,
    EventController controller,
  ) {
    final brightness = Theme.of(context).brightness;
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      titleStyle: TextStyle(
        color: AppColors.primary.getByBrightness(brightness),
        fontWeight: FontWeight.bold,
      ),
      middleText: 'هل أنت متأكد من حذف هذه المناسبة؟',
      middleTextStyle: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
      backgroundColor: AppColors.background.getByBrightness(brightness),
      radius: 20,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          controller.deleteEvent(id);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent.getByBrightness(brightness),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('نعم، احذف', style: TextStyle(color: AppColors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text('إلغاء', style: TextStyle(color: AppColors.primary.getByBrightness(brightness))),
      ),
    );
  }

  static void showCancelDialog(
    BuildContext context,
    int id,
    EventController controller,
  ) {
    final brightness = Theme.of(context).brightness;
    Get.defaultDialog(
      title: 'تأكيد الإلغاء',
      titleStyle: TextStyle(
        color: AppColors.primary.getByBrightness(brightness),
        fontWeight: FontWeight.bold,
      ),
      middleText: 'هل أنت متأكد من إلغاء هذه المناسبة؟',
      middleTextStyle: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
      backgroundColor: AppColors.background.getByBrightness(brightness),
      radius: 20,
      confirm: ElevatedButton(
        onPressed: () {
          controller.updateEventStatus(id, Status.CANCELLED);
          Get.back();
          
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent.getByBrightness(brightness),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('نعم، إلغاء', style: TextStyle(color: AppColors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text('تراجع', style: TextStyle(color: AppColors.primary.getByBrightness(brightness))),
      ),
    );
  }

  static void showRestoreDialog(
    BuildContext context,
    int id,
    EventController controller,
  ) {
    final brightness = Theme.of(context).brightness;
    Get.defaultDialog(
      title: 'استعادة المناسبة',
      titleStyle: TextStyle(
        color: AppColors.primary.getByBrightness(brightness),
        fontWeight: FontWeight.bold,
      ),
      middleText: 'هل تريد استعادة هذه المناسبة؟ سيعاد تعيين حالتها إلى "قيد الانتظار".',
      middleTextStyle: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
      backgroundColor: AppColors.background.getByBrightness(brightness),
      radius: 20,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          controller.updateEventStatus(id, Status.PENDING);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success.getByBrightness(brightness),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('نعم، استعادة', style: TextStyle(color: AppColors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text('إلغاء', style: TextStyle(color: AppColors.primary.getByBrightness(brightness))),
      ),
    );
  }
}
  