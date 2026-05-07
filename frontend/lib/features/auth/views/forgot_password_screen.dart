import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart' show AuthController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;

class ForgotPasswordScreen extends GetView<AuthController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBody.getByBrightness(brightness)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.lock_reset_rounded,
              size: 80,
              color: AppColors.primary.getByBrightness(brightness),
            ),
            const SizedBox(height: 24),
            Text(
              'نسيت كلمة المرور؟',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'أدخل بريدك الإلكتروني أدناه وسنرسل لك رابطاً لإعادة تعيين كلمة المرور الخاصة بك.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSubtitle.getByBrightness(brightness),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            
            // حقل الإيميل
            Container(
              decoration: AppFormWidgets.cardDecoration(context),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: AppFormWidgets.fieldDecoration(
                  'البريد الإلكتروني',
                  Icons.email_outlined,
                  context,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // زر الإرسال
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient.getByBrightness(brightness),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'تم الإرسال',
                    'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني بنجاح.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success.getByBrightness(brightness).withValues(alpha: 0.1),
                    colorText: AppColors.success.getByBrightness(brightness),
                    margin: const EdgeInsets.all(20),
                    duration: const Duration(seconds: 4),
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    Get.back();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.transparent,
                  shadowColor: AppColors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'إرسال الرابط',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
