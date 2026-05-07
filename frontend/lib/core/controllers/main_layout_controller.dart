import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class MainLayoutController extends GetxController 
{
  final RxInt currentIndex = 0.obs;
  DateTime? lastBackPressTime;

  void changePage(int index) 
  {
    currentIndex.value = index;
  }

  void handleBackPress(bool didPop) {
    if (didPop) return;
    
    final now = DateTime.now();
    if (lastBackPressTime == null || 
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;
      Get.rawSnackbar(
        message: 'اضغط مرة أخرى للخروج من التطبيق',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } else {
      SystemNavigator.pop();
    }
  }
}
