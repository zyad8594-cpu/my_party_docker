import 'package:flutter/material.dart';
import 'error_screen.dart';
import 'package:get/get.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفحة غير موجودة'),
        centerTitle: true,
      ),
      body: ErrorScreen(
        icon: Icons.search_off_rounded,
        message: 'عذراً، الصفحة أو العنصر الذي تبحث عنه غير موجود.',
        retryText: 'العودة',
        onRetry: () {
          Get.back();
        },
      ),
    );
  }
}
