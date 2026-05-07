import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/logout_dialog.dart' show logoutDialog;
import '../controller/auth_controller.dart' show AuthController;
import '../../../core/themes/app_colors.dart' show AppColors;
// import '../sections/profile/extra_details_section.dart' show ExtraDetailsSection;
import '../sections/profile/personal_information_section.dart' show PersonalInformationSection;
import '../sections/profile/security_and_account_section.dart' show SecurityAndAccountSection;
import '../sections/profile/system_settings_section.dart' show SystemSettingsSection;
import '../widgets/profile/edit_profile_button_widget.dart' show EditProfileButtonWidget;
import '../widgets/profile/sliver_appar_widget.dart' show SliverApparWidget;
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_system_ringtones/flutter_system_ringtones.dart';

class ProfileScreen extends GetView<AuthController> {
  const ProfileScreen({super.key});

  // static const _basicFields = {
  //   'id', 'user_id', 'full_name', 'email', 'phone_number', 
  //   'role_name', 'img_url', 'phone', 'is_active', 'is_deleted', 
  //   'created_at', 'updated_at', 'token', 'role', 'password'
  // };

  // Map<String, dynamic> _getExtraDetails() {
  //   return Map.fromEntries(
  //     controller.user.entries.where((e) => !_basicFields.contains(e.key) && e.value != null)
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      body: Obx(() {
        // ignore: unused_local_variable
        final isLoading = controller.isLoading.value;
        return RefreshIndicator(
          onRefresh: controller.loadUserData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverApparWidget(),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PersonalInformationSection(), const SizedBox(height: 24),
                      const EditProfileButtonWidget(), const SizedBox(height: 48),
                      const SystemSettingsSection(), const SizedBox(height: 32),
                      const SecurityAndAccountSection(), const SizedBox(height: 48),
                      _buildLogoutButton(context), const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  
  
  
  
  
  
  
  Widget _buildLogoutButton(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: logoutDialog,
        icon: Icon(Icons.logout_rounded, color: AppColors.accent.getByBrightness(brightness)),
        label: Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: AppColors.accent.getByBrightness(brightness),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: AppColors.accent.getByBrightness(brightness).withValues(alpha: 0.5), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }


  
  /*
  void _showSoundPicker(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
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
            Text(
              'اختر صوت الإشعارات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 20),
            _buildPickerOption(
              context,
              icon: Icons.phonelink_ring_rounded,
              title: 'أصوات الهاتف الافتراضية',
              onTap: () {
                Get.back();
                _pickSystemSound(context);
              },
              brightness: brightness,
            ),
            const SizedBox(height: 12),
            _buildPickerOption(
              context,
              icon: Icons.audio_file_rounded,
              title: 'إضافة صوت من ملفاتك',
              onTap: () {
                Get.back();
                _pickCustomSound();
              },
              brightness: brightness,
            ),
            const SizedBox(height: 12),
            _buildPickerOption(
              context,
              icon: Icons.restore_rounded,
              title: 'استعادة الافتراضي',
              onTap: () {
                Get.back();
                Get.find<ConfigService>().setNotificationSound('', 'Default', 'default');
              },
              brightness: brightness,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Brightness brightness,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.background.getByBrightness(brightness),
        ),
        child: Row(
          children: [
            _buildIconContainer(context, icon, AppColors.primary.getByBrightness(brightness)),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickCustomSound() async {
    try {
      final dynamic picker = (FilePicker as dynamic).platform;
      final result = await picker.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final String path = result.files.single.path!;
        final String name = result.files.single.name;
        Get.find<ConfigService>().setNotificationSound(path, name, 'custom');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في اختيار الملف الصوتي');
    }
  }

  Future<void> _pickSystemSound(BuildContext context) async {
    final brightness = Theme.of(context).brightness;
    try {
      final dynamic ringtones = await (FlutterSystemRingtones as dynamic).getRingtones();
      if (ringtones.isEmpty) {
        Get.snackbar('تنبيه', 'لا توجد أصوات هاتف مكتشفة');
        return;
      }

      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(24),
          height: Get.height * 0.6,
          decoration: BoxDecoration(
            color: AppColors.surface.getByBrightness(brightness),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
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
              Text(
                'أصوات الهاتف',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBody.getByBrightness(brightness),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: ringtones.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1),
                  ),
                  itemBuilder: (context, index) {
                    final dynamic ringtone = ringtones[index];
                    return ListTile(
                      leading: _buildIconContainer(context, Icons.music_note_rounded, AppColors.info.getByBrightness(brightness)),
                      title: Text(
                        ringtone.title,
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textBody.getByBrightness(brightness)),
                      ),
                      onTap: () {
                        Get.back();
                        Get.find<ConfigService>().setNotificationSound(ringtone.uri, ringtone.title, 'system');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب أصوات الهاتف');
    }
  }
  */


}
