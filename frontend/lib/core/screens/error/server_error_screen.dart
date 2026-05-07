import 'package:flutter/material.dart';
import 'error_screen.dart';
import 'package:get/get.dart';

class ServerErrorScreen extends StatelessWidget {
  const ServerErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطأ في الخادم'),
        centerTitle: true,
      ),
      body: ErrorScreen(
        icon: Icons.cloud_off_rounded,
        message: 'حدث خطأ عام في الخادم. فريقنا يعمل على حله الآن. يرجى المحاولة لاحقاً.',
        retryText: 'العودة للخلف',
        onRetry: () {
          Get.back();
        },
      ),
    );
  }
}
