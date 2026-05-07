import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/admin_controller.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/components/custom_app_bar.dart';
import '../../../core/components/widgets/loading_widget.dart';

class RolesManagementScreen extends GetView<AdminController> {
  const RolesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: const CustomAppBar(title: 'إدارة الأدوار والصلاحيات'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextFormField(
              onChanged: (value) => controller.roleSearchQuery.value = value,
              style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
              decoration: InputDecoration(
                hintText: 'ابحث عن دور أو رتبة...',
                hintStyle: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary.getByBrightness(brightness)),
                filled: true,
                fillColor: AppColors.surface.getByBrightness(brightness),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingRoles.value) {
                return const LoadingWidget();
              }
              if (controller.filteredRoles.isEmpty) {
                return const Center(child: Text('لا يوجد نتائج للبحث'));
              }
              return RefreshIndicator(
                onRefresh: () async => controller.fetchRoles(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.filteredRoles.length,
                  itemBuilder: (context, index) {
                    final role = controller.filteredRoles[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface.getByBrightness(brightness),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_rounded, color: AppColors.purple),
                        ),
                        title: Text(
                          role.roleName.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness)),
                        ),
                        subtitle: null,
                        trailing: const Icon(Icons.edit_note_rounded, color: AppColors.blue),
                        onTap: () {
                          // Logic to edit role permissions would go here
                          // e.g. opening a sheet with a checklist of permissions
                          Get.snackbar('ملاحظة', 'سيكون بإمكانك تفعيل وإلغاء صلاحيات هذا الدور قريباً في تحديث لاحق.');
                        },
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
