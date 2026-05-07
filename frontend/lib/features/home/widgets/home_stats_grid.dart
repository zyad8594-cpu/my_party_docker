// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/globle_card.dart' show GlobleCard;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../controller/home_controller.dart';
// import '../controller/home_controller.dart' show HomeController;

class HomeStatsGrid extends GetView<HomeController> 
{
  const HomeStatsGrid({super.key});


  @override
  Widget build(BuildContext context) 
  {
    // controller.onInit();
    final brightness = Theme.of(context).brightness;

    return Obx((){
      final isLoading = controller.isLoading.value == true;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        // crossAxisSpacing: 2,
        // mainAxisSpacing: 2,
        childAspectRatio: 0.8,
        children: [
          GlobleCard(
            title: 'المناسبات قيد التنفيذ', 
            value: controller.eventStatusStats['in_progress']!.toString(), 
            icon: Icons.calendar_today_rounded, 
            color: AppColors.info.getByBrightness(brightness)
          ),

          GlobleCard(
           title:  'مهام قيد التنفيذ',
           value:  controller.taskStatusStats['in_progress'].toString(), // 
           icon:  Icons.sync_rounded,
           color:  AppColors.info.getByBrightness(brightness),
          ),  

          GlobleCard(
            title: 'مناسبات مكتملة',
            value: controller.taskStatusStats['completed'].toString(), // 
            icon: Icons.check_circle_rounded,
           color:  AppColors.success.getByBrightness(brightness),
          ),

          GlobleCard(
            title: 'مهام مكتملة',
            value: controller.taskStatusStats['completed'].toString(), // 
            icon: Icons.check_circle_rounded,
           color:  AppColors.success.getByBrightness(brightness),
          ),
          
          GlobleCard(
            title:  'مناسبات قيد الإنتظار',
            value:  controller.eventStatusStats['pending'].toString(), // events_planned
            icon:  Icons.error_outline_rounded,
            color:  AppColors.brown,
          ),

          GlobleCard(
            title:  'مهام قيد الإنتظار',
            value:  controller.taskStatusStats['pending'].toString(), // events_planned
            icon:  Icons.error_outline_rounded,
            color:  AppColors.brown,
          ),

          GlobleCard(
            title: 'مناسبات ملغية',
            value: controller.eventStatusStats['cancelled'].toString(), // tasks_in_review
            icon: Icons.cancel_rounded,
            color: AppColors.accent.getByBrightness(brightness),
          ),

          GlobleCard(
            title: 'مهام ملغية',
            value: controller.taskStatusStats['cancelled'].toString(), // tasks_in_review
            icon: Icons.cancel_rounded,
            color: AppColors.accent.getByBrightness(brightness),
          ),

          GlobleCard(
            title: 'مهام مرفوضة',
            value: controller.taskStatusStats['rejected'].toString(), // tasks_in_review
            icon: Icons.thumb_down_alt_rounded,
            color: AppColors.rejected.getByBrightness(brightness),
          ),
          
          GlobleCard(
            title: 'مهام قيد المراجعة',
            value: controller.taskStatusStats['under_review'].toString(), // tasks_in_review
            icon: Icons.rate_review_rounded,
            color: AppColors.warning.getByBrightness(brightness),
          ),
        ],
      );
    }
    );
  }
}
