import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/validtor.dart' show MyPValidator;
import '../../../core/utils/utils.dart' show MyPUtils;
import '../controller/auth_controller.dart' show AuthController;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        showBackButton: true,
        title: 'إنشاء حساب',
        showNotificationButton: false,
        showLogoutButton: false,
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.getByBrightness(brightness).withValues(alpha: 0.08),
                    AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.03),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Hero(
                      tag: 'auth_profile_logo',
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
                              : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: controller.profileImage.value == null 
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
                    'انضم إلينا',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textBody.getByBrightness(brightness),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ بتنظيم مناسباتك بشكل أسهل واحترافي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 48),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: controller.nameController,
                          onChanged: (val) => controller.name.value = val,
                          decoration: const InputDecoration(
                            labelText: 'الاسم الكامل',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: controller.emailController,
                        
                          onChanged: (val) => controller.email.value = val,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'example@mail.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: controller.phoneController,
                          textDirection: TextDirection.ltr,
                          onChanged: (val) => controller.phone.value = val,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'رقم الهاتف',
                            suffixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: Text(textDirection: TextDirection.ltr, "+967" , style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => TextField(
                            controller: controller.passwordController,
                            onChanged: (val) => controller.password.value = val,
                            obscureText: !controller.isPasswordVisible.value,
                            decoration: AppFormWidgets.passwordFieldDecoration(
                              label: 'كلمة المرور',
                              hintText: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              isVisible: controller.isPasswordVisible.value,
                              onToggle: () => controller.isPasswordVisible.toggle(),
                              context: context,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => DropdownButtonFormField<String>(
                            initialValue: controller.selectedRole.value,
                            decoration: const InputDecoration(
                              labelText: 'نوع الحساب',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'coordinator',
                                child: Text('منسق حفلات'),
                              ),
                              DropdownMenuItem(
                                value: 'supplier',
                                child: Text('مزود خدمات'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) controller.selectedRole.value = value;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => Row(
                            children: [
                              Checkbox(
                                value: controller.agreedToTerms.value,
                                activeColor: AppColors.primary.getByBrightness(brightness),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) => controller.agreedToTerms.value = val ?? false,
                              ),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    Text(
                                      'أوافق على ',
                                      style: TextStyle(
                                        color: AppColors.textBody.getByBrightness(brightness),
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Get.toNamed(AppRoutes.termsConditions),
                                      child: Text(
                                        'الشروط والأحكام',
                                        style: TextStyle(
                                          color: AppColors.primary.getByBrightness(brightness),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' الخاصة بالتطبيق',
                                      style: TextStyle(
                                        color: AppColors.textBody.getByBrightness(brightness),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => GradientButton(
                            text: controller.selectedRole.value == 'supplier' ? 'التالي' : 'إنشاء حساب',
                            isLoading: controller.isLoading.value,
                            onPressed: () {
                              if (controller.selectedRole.value == 'supplier') {
                                var contactMsg = MyPValidator.cocatMsg([
                                  // MyPValidator.name(controller.nameController.text),
                                  // MyPValidator.email(controller.emailController.text),
                                  // MyPValidator.phone(controller.phoneController.text),
                                  // MyPValidator.password(controller.passwordController.text, 6),
                                  MyPValidator.name(controller.name),
                                  MyPValidator.email(controller.email),
                                  MyPValidator.phone(controller.phone),
                                  MyPValidator.password(controller.password, 6),
                                  
                                ]); 
                                if(contactMsg != null)
                                {
                                  return MyPUtils.showSnackbar('خطأ', contactMsg, isError: true);
                                }
                                if (!controller.agreedToTerms.value) {
                                  return MyPUtils.showSnackbar('تنبيه', 'يجب الموافقة على الشروط والأحكام للمتابعة', isError: true);
                                }
                                Get.toNamed(AppRoutes.supplierServiceSelection);
                              } else {
                                controller.register();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: RichText(
                      text: TextSpan(
                        text: 'لديك حساب بالفعل؟ ',
                        style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontFamily: 'Cairo'),
                        children: [
                          TextSpan(
                            text: 'قم بتسجيل الدخول',
                            style: TextStyle(
                              color: AppColors.primary.getByBrightness(brightness),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
