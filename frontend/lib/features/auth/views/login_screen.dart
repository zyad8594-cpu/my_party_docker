import 'package:flutter/material.dart';
  
import 'package:get/get.dart';
import '../../../core/config/config.dart' show Assets, Config;
import '../../../core/controllers/validtor.dart' show MyPValidator;
import '../controller/auth_controller.dart' show AuthController;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;

class LoginScreen extends GetView<AuthController> 
{
  const LoginScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                    AppColors.secondary.getByBrightness(brightness).withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    GestureDetector(
                      onDoubleTap: () => Get.toNamed(AppRoutes.apiSettings),
                      child: Hero(
                        tag: 'auth_app_logo',
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface.getByBrightness(brightness),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            Assets.appIcon2009x1961,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.celebration_rounded,
                                size: 64,
                                color: AppColors.primary.getByBrightness(brightness),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // titel
                    Text(
                      Config.APP_NAME_AR,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textBody.getByBrightness(brightness),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // sub titel
                    Text(
                      Config.APP_DESCRIPTION_AR,
                      style: TextStyle(
                        color: AppColors.textSubtitle.getByBrightness(brightness),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // نموذج تسجيل الدخول
                    Form(
                      key: controller.formAuthKey,
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // عنوان تسجيل الدخول
                            Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBody.getByBrightness(brightness),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // حقل البريد الإلكتروني
                            TextFormField(
                              controller: controller.emailController,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                hintText: 'example@mail.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              // initialValue: controller.email.value,
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (val) => controller.email.value = val ?? controller.email.value,
                              onChanged: (val) => controller.email.value = val,
                              validator: (val)=> MyPValidator.email(controller.email.value),
                            ),
                            const SizedBox(height: 20),

                            // حقل كلمة المرور
                            Obx(() => TextFormField(
                              controller: controller.passwordController,
                              // key: controller.formAuthKey,
                              decoration: AppFormWidgets.passwordFieldDecoration(
                                label: 'كلمة المرور',
                                hintText: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                isVisible: controller.isPasswordVisible.value,
                                onToggle: controller.isPasswordVisible.toggle,
                                context: context,
                              ),
                              obscureText: !controller.isPasswordVisible.value,
                              // initialValue: controller.password.value,
                              onSaved: (val) => controller.password.value = val ?? controller.password.value,
                              onChanged: (val) => controller.password.value = val,
                              validator: (val)=> MyPValidator.password(controller.password.value, 6),
                            ),),
                            
                            // زر تذكرني ونسيت كلمة المرور
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // زر تذكرني
                                Obx(() => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // زر تذكرني
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: controller.rememberMe.value,
                                        onChanged: (val) => controller.rememberMe.value = val ?? false,
                                        activeColor: AppColors.primary.getByBrightness(brightness),
                                        checkColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                      
                                    // نص تذكرني
                                    GestureDetector(
                                      onTap: () => controller.rememberMe.toggle(),
                                      child: Text(
                                        'تذكرني',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSubtitle.getByBrightness(brightness),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),),
                                
                                // زر نسيت كلمة المرور
                                TextButton(
                                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary.getByBrightness(brightness),
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                      
                      
                            // زر تسجيل الدخول
                            Obx(() => GradientButton(
                              text: 'تسجيل الدخول',
                              isLoading: controller.isLoading.value,
                              onPressed: controller.login,
                            ),),
                            
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // register button
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: RichText(
                        text: TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style: TextStyle(
                            color: AppColors.textSubtitle.getByBrightness(brightness),
                            fontFamily: 'Cairo',
                          ),
                          children: [
                            TextSpan(
                              text: 'سجل الآن',
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

                    // const SizedBox(height: 40),
                    
                    // // Quick Demo Login
                    // Text(
                    //   '-- دخول سريع للتجربة --',
                    //   style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.5), fontSize: 12),
                    // ),
                    // const SizedBox(height: 12),
                    
                        // _buildDemoButton(context, 'admin@myparty.com', 'مدير'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'ahmed@myparty.com', 'منسق'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'sadalh@myparty.com', 'منسق'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'mona@myparty.com', 'منسق'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'nidal@myparty.com', 'منسق'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'rana@myparty.com', 'منسق'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'bassem@myparty.com', 'منسق'),
                        // const SizedBox(height: 20),
                        // _buildDemoButton(context, 'sami@myparty.com', 'مورد'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'khaled@myparty.com', 'مورد'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'gram@myparty.com', 'مورد'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'akram@myparty.com', 'مورد'),
                        // const SizedBox(height: 12),
                        // _buildDemoButton(context, 'nawal@myparty.com', 'مورد'),
                        
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildDemoButton(BuildContext context, String email, String label, {String password = '123456'})
  // {
  //   final brightness = Theme.of(context).brightness;
  //   return OutlinedButton.icon(
  //                         onPressed: () {
  //                           controller.emailController.text = email;
  //                           controller.passwordController.text = password.isNotEmpty? password:'123456';
  //                           controller.login();
  //                         },
  //                         icon: Icon(label == 'منسق' ? Icons.person_rounded : label == 'مدير' ? Icons.admin_panel_settings_rounded : Icons.store_rounded, size: 16),
  //                         label: Text('$email  $label'),
  //                         style: OutlinedButton.styleFrom(
  //                           foregroundColor: AppColors.textSubtitle.getByBrightness(brightness),
  //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //                         ),
  //                       );
  // }
    
}
