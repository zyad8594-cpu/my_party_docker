
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';

// import '../../../../core/api/auth_service.dart' show AuthService;
import '../../../../core/api/auth_service.dart' show AuthService;
import '../../../../core/components/glass_card.dart' show GlassCard;
import '../../../../core/controllers/auth_controller.dart' show AuthController;
import '../../../../core/themes/app_colors.dart' show AppColors;
import '../../widgets/profile/sections_widgets.dart' show ProfileSectionsWidgets;

class SecurityAndAccountSection extends GetView<AuthController> {
  const SecurityAndAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionsWidgets.title(context, 'الأمان والحساب'),
        const SizedBox(height: 12),
        _buildSecurityAndAccountSection(context),
      ],
    );
  }

  Widget _buildSecurityAndAccountSection(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GlassCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            onTap: () => _showChangePasswordBottomSheet(context, controller),
            leading: ProfileSectionsWidgets.iconContainer(context, Icons.lock_reset_rounded, AppColors.accent.getByBrightness(brightness)),
            title: Text('تغيير كلمة المرور', style: ProfileSectionsWidgets.settingTextStyle(context)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSubtitle.getByBrightness(brightness)),
          ),
          ProfileSectionsWidgets.divider(context),
          ListTile(
            onTap: () => _showSwitchAccountBottomSheet(context),
            leading: ProfileSectionsWidgets.iconContainer(context, Icons.switch_account_rounded, AppColors.success.getByBrightness(brightness)),
            title: Text('تبديل الحسابات', style: ProfileSectionsWidgets.settingTextStyle(context)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSubtitle.getByBrightness(brightness)),
          ),
          ProfileSectionsWidgets.divider(context),
          ListTile(
            onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
            leading: ProfileSectionsWidgets.iconContainer(context, Icons.privacy_tip_rounded, AppColors.primary.getByBrightness(brightness)),
            title: Text('سياسة الخصوصية', style: ProfileSectionsWidgets.settingTextStyle(context)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSubtitle.getByBrightness(brightness)),
          ),
          ProfileSectionsWidgets.divider(context),
          ListTile(
            onTap: () => Get.toNamed(AppRoutes.termsConditions),
            leading: ProfileSectionsWidgets.iconContainer(context, Icons.gavel_rounded, AppColors.primary.getByBrightness(brightness)),
            title: Text('الشروط والأحكام', style: ProfileSectionsWidgets.settingTextStyle(context)),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSubtitle.getByBrightness(brightness)),
          ),
        ],
      ),
    );
  }
  

  void _showChangePasswordBottomSheet(BuildContext context, AuthController controller) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final brightness = Theme.of(context).brightness;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24.0, right: 24.0, top: 24.0, 
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.0
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.getByBrightness(brightness),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Form(
          key: formKey,
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
                Text('تغيير كلمة المرور', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))
                ),
                const SizedBox(height: 24),
                ProfileSectionsWidgets.textInputField(
                  oldPasswordController, 'كلمة المرور الحالية', Icons.lock_outline_rounded, brightness, 
                  obscureText: true.obs,
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                ProfileSectionsWidgets.textInputField(
                  newPasswordController, 'كلمة المرور الجديدة', Icons.lock_rounded, brightness, 
                  obscureText: true.obs,
                  validator: (v) => v!.length < 6 ? 'يجب أن تكون 6 أحرف على الأقل' : null,
                ),
                const SizedBox(height: 16),
                ProfileSectionsWidgets.textInputField(
                  confirmPasswordController, 'تأكيد كلمة المرور الجديدة', Icons.lock_clock_rounded, brightness, 
                  obscureText: true.obs,
                  validator: (v) => v != newPasswordController.text ? 'كلمات المرور غير متطابقة' : null,
                ),
                const SizedBox(height: 32),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent.getByBrightness(brightness),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: controller.isLoading.value ? null : () async {
                      if (formKey.currentState!.validate()) {
                        await controller.changePassword(
                          oldPasswordController.text,
                          newPasswordController.text,
                        );
                        if (Get.isBottomSheetOpen == true) Get.back();
                      }
                    },
                    child: controller.isLoading.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                      : const Text('تغيير كلمة المرور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
  
  void _showSwitchAccountBottomSheet(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.surface.getByBrightness(brightness),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
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
            Text('تبديل الحسابات', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: AuthService.getSavedAccounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final accounts = snapshot.data ?? [];
                return Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: accounts.length,
                    separatorBuilder: (c, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final acc = accounts[index];
                      final isActive = acc['id'] == controller.user.value.id;
                      return ListTile(
                        onTap: () {
                          if (!isActive) {
                            Get.back();
                            AuthService.switchAccount(acc['token']);
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isActive 
                              ? BorderSide(color: AppColors.primary.getByBrightness(brightness), width: 2)
                              : BorderSide.none,
                        ),
                        tileColor: isActive 
                            ? AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1)
                            : AppColors.background.getByBrightness(brightness),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2),
                          backgroundImage: acc['img_url'] != null ? NetworkImage('${acc['img_url']}?v=${AuthService.profileImgVersion.value}') : null,
                          child: acc['img_url'] == null 
                              ? Icon(Icons.person_rounded, color: AppColors.primary.getByBrightness(brightness))
                              : null,
                        ),
                        title: Text(acc['full_name'] ?? 'مستخدم', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))),
                        subtitle: Text(
                          "${['SUPPLIER', 'supplier'].contains(acc['role_name']) ? 'مزود خدمة' : (acc['role_name'] == 'COORDINATOR' ? 'منسق' : 'مدير')} • ${acc['email'] ?? ''}", 
                          style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 12)
                        ),
                        trailing: isActive 
                            ? Icon(Icons.check_circle_rounded, color: AppColors.primary.getByBrightness(brightness))
                            : IconButton(
                                icon: Icon(Icons.logout_rounded, color: AppColors.accent.getByBrightness(brightness), size: 20),
                                onPressed: () {
                                  AuthService.removeSavedAccount(acc['id']).then((_) {
                                    if (Get.isBottomSheetOpen ?? false) {
                                      Get.back();
                                      // optionally show again to refresh
                                    }
                                  });
                                },
                              ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  controller.addNewAccount();
                },
                icon: Icon(Icons.add_rounded, color: AppColors.primary.getByBrightness(brightness)),
                label: Text('إضافة حساب آخر', style: TextStyle(color: AppColors.primary.getByBrightness(brightness), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary.getByBrightness(brightness), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  
}