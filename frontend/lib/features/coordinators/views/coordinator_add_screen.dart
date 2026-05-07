import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../controller/coordinator_controller.dart' show CoordinatorController;
import '../data/models/coordinator.dart' show Coordinator;

class CoordinatorAddScreen extends GetView<CoordinatorController> 
{
  CoordinatorAddScreen({super.key});
final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final Coordinator? coordinator = Get.arguments as Coordinator?;
    final isEditing = coordinator != null;

    if (isEditing) {
      controller.populateFields(coordinator);
    } else {
      controller.clearFields();
    }

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        // authController: authController,
        showBackButton: true,
        title: isEditing ? 'تعديل بيانات المنسق' : 'إضافة منسق جديد',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'coordinator_profile_image',
                child: Obx(() => InkWell(
                  onTap: controller.pickImage,
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surface.getByBrightness(brightness),
                      shape: BoxShape.circle,
                      image: controller.profileImage.value != null 
                        ? DecorationImage(
                            image: FileImage(controller.profileImage.value!),
                            fit: BoxFit.cover,
                          )
                        : (isEditing && coordinator.imgUrl != null)
                          ? DecorationImage(
                              image: NetworkImage(coordinator.imgUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: (controller.profileImage.value == null && (!isEditing || coordinator.imgUrl == null))
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 32,
                              color: AppColors.primary.getByBrightness(brightness),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'صورة',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary.getByBrightness(brightness),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.getByBrightness(brightness),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isEditing ? 'تحديث المعلومات' : 'البيانات الأساسية للمنسق',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: isEditing ? coordinator.name : null,
                    onChanged: (val) => controller.fullNameRx.value = val,
                    decoration: AppFormWidgets.fieldDecoration('الاسم الكامل', Icons.person_outline_rounded, context),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: isEditing ? coordinator.email : null,
                    onChanged: (val) => controller.emailRx.value = val,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppFormWidgets.fieldDecoration('البريد الإلكتروني', Icons.email_outlined, context),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: isEditing ? coordinator.phoneNumber : null,
                    onChanged: (val) => controller.phoneNumberRx.value = val,
                    keyboardType: TextInputType.phone,
                    decoration: AppFormWidgets.fieldDecoration('رقم الهاتف', Icons.phone_outlined, context),
                  ),
                  Obx(() {
                    if (!isEditing || controller.showPasswordEdit.value) {
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            onChanged: (val) => controller.passwordRx.value = val,
                            obscureText: !controller.isPasswordVisible.value,
                            decoration: AppFormWidgets.passwordFieldDecoration(
                              label: isEditing ? 'كلمة المرور الجديدة' : 'كلمة المرور',
                              icon: Icons.lock_outline_rounded,
                              isVisible: controller.isPasswordVisible.value,
                              onToggle: () => controller.isPasswordVisible.toggle(),
                              context: context,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () => controller.showPasswordEdit.value = true,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('تغيير كلمة المرور', style: TextStyle(color: AppColors.primary.getByBrightness(brightness))),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Obx(
                () => CheckboxListTile(
                  value: controller.isActiveRx.value,
                  onChanged: (val) => controller.isActiveRx.value = val ?? true,
                  title: Text(
                    'حساب نشط',
                    style: TextStyle(
                      color: AppColors.textBody.getByBrightness(brightness),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'يمكن للمنسق تسجيل الدخول واستخدام النظام',
                    style: TextStyle(
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                      fontSize: 12,
                    ),
                  ),
                  activeColor: AppColors.primary.getByBrightness(brightness),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Obx(
              () => GradientButton(
                text: isEditing ? 'حفظ التعديلات' : 'إضافة منسق',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (controller.fullNameRx.value.isEmpty) {
                    Get.snackbar(
                      'تنبيه',
                      'يرجى إدخال اسم المنسق',
                      backgroundColor: AppColors.accent.getByBrightness(brightness).withValues(alpha: 0.1),
                      colorText: AppColors.accent.getByBrightness(brightness),
                      icon: Icon(Icons.warning_amber_rounded, color: AppColors.accent.getByBrightness(brightness)),
                    );
                    return;
                  }
                  if (isEditing) {
                    controller.edit(coordinator.id);
                  } else {
                    controller.create();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
