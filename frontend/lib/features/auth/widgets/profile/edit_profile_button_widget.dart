// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/auth_service.dart' show AuthService;
import '../../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../../core/controllers/auth_controller.dart' show AuthController;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../core/utils/utils.dart' show MyPUtils;
import 'sections_widgets.dart' show ProfileSectionsWidgets;

class EditProfileButtonWidget extends GetView<AuthController>{

  const EditProfileButtonWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.getByBrightness(brightness),
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 4,
          shadowColor: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _showEditProfileBottomSheet(context),
        icon: const Icon(Icons.edit_rounded, color: AppColors.white, size: 22),
        label: const Text(
          'تعديل الملف الشخصي', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    final nameController = TextEditingController(text: controller.user.value.name);
    final emailController = TextEditingController(text: controller.user.value.email ?? '');
    final phoneController = TextEditingController(text: controller.user.value.phoneNumber ?? '');
    
    final extraDetails = controller.user.value.details;
    final extraControllers = <String, TextEditingController>{};
    extraDetails.forEach((key, value) {
      if(value == null || value == '' || value is List? || value is Map? ) return;
      extraControllers[key] = TextEditingController(text: value.toString());
    });
    
    final brightness = Theme.of(context).brightness;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.surface.getByBrightness(brightness),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('تعديل الملف الشخصي', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    Obx(() => Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2),
                        backgroundImage: controller.profileImage.value != null 
                            ? FileImage(controller.profileImage.value!) 
                            : (controller.user.value.imgUrl != null ? NetworkImage('${controller.user.value.imgUrl!}?v=${AuthService.profileImgVersion.value}') : null) as ImageProvider?,
                        child: (controller.profileImage.value == null && controller.user.value.imgUrl == null)
                            ? Icon(Icons.person_rounded, size: 50, color: AppColors.primary.getByBrightness(brightness))
                            : null,
                      ),
                    )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accent.getByBrightness(brightness),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface.getByBrightness(brightness), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: AppColors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ProfileSectionsWidgets.textInputField(nameController, 'الاسم الكامل', Icons.person_rounded, brightness),
              const SizedBox(height: 16),
              ProfileSectionsWidgets.textInputField(emailController, 'البريد الإلكتروني', Icons.email_rounded, brightness, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              ProfileSectionsWidgets.textInputField(phoneController, 'رقم الجوال', Icons.phone_rounded, brightness, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              ...extraControllers.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProfileSectionsWidgets.textInputField(e.value, e.key.replaceAll('_', ' ').capitalizeFirst!, Icons.info_outline_rounded, brightness),
              )),
              const SizedBox(height: 32),
              Obx(() => SizedBox(
                width: double.infinity,
                child: controller.isLoading.value? const LoadingWidget() : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.getByBrightness(brightness),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: controller.isLoading.value ? null : () async {
                    final updatedExtra = <String, dynamic>{};
                    extraControllers.forEach((key, ctrl) {
                      updatedExtra[key] = ctrl.text.trim();
                    });
                    
                    final success = await controller.updateProfile(
                      newName: nameController.text.trim(),
                      newEmail: emailController.text.trim(),
                      newPhone: phoneController.text.trim(),
                      newImage: controller.profileImage.value,
                      extraDetails: updatedExtra,
                    );
                    
                    if (success) 
                    {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      MyPUtils.showSnackbar('نجاح', 'تم تحديث الملف الشخصي بنجاح');
                    }
                  },
                  child: Obx(()=> controller.isLoading.value 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Text('حفظ التعديلات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),),
                ),
              )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}  