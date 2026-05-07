// import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart' show AuthController;
import '../themes/app_colors.dart';


void logoutDialog()
{
  
  Get.defaultDialog(
    title: 'تسجيل الخروج',
    middleText: 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
    textConfirm: 'نعم',
    textCancel: 'إلغاء',
    confirmTextColor: AppColors.white,
    buttonColor: AppColors.red,
    onConfirm: ()=> Get.find<AuthController>().logout(),
  );
}