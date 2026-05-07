import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../utils/utils.dart' show MyPUtils;
import 'error_screen.dart';
import 'package:get/get.dart';

class NetworkErrorScreen extends StatelessWidget {
  const NetworkErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // يمنع الرجوع للخلف عن طريق زر الرجوع في الهاتف
      child: Scaffold(
        appBar: AppBar(
          title: const Text('خطأ في الاتصال'),
          centerTitle: true,
          automaticallyImplyLeading: false, // يمنع إظهار زر الرجوع في الـ AppBar
        ),
        body: ErrorScreen(
          icon: Icons.wifi_off_rounded,
          message: 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة الخاصة بك والمحاولة مرة أخرى.',
          retryText: 'إعادة المحاولة',
          onRetry: () async {
            // التحقق يدوياً عند الضغط على إعادة المحاولة
            final connectivityResult = await Connectivity().checkConnectivity();
            // if (connectivityResult != ConnectivityResult.none) {
            if (connectivityResult.isNotEmpty && connectivityResult.any((result) => result == ConnectivityResult.wifi || result == ConnectivityResult.mobile)) {
              Get.back();
            } else {
              MyPUtils.showSnackbar(
                'تنبيه',
                'ما زلت غير متصل بالإنترنت',
                position: SnackPosition.TOP,
                isError: true
              );
            }
          },
        ),
      ),
    );
  }
}
