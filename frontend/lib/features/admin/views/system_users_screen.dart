import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/admin_controller.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/components/custom_app_bar.dart';
import '../../../core/components/widgets/loading_widget.dart';
import '../../../../core/routes/app_routes.dart' show AppRoutes;

class SystemUsersScreen extends GetView<AdminController> {
  const SystemUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: const CustomAppBar(title: 'إدارة المستخدمين الشاملة'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextFormField(
              onChanged: (value) => controller.userSearchQuery.value = value,
              style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
              decoration: InputDecoration(
                hintText: 'البحث المتقدم (اسم أو بريد)...',
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
              if (controller.isLoadingUsers.value) {
                return const LoadingWidget();
              }
              if (controller.filteredUsers.isEmpty) {
                return const Center(child: Text('لا يوجد نتائج للبحث'));
              }
              return RefreshIndicator(
                onRefresh: () async => controller.fetchSystemUsers(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
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
                        onTap: () {
                          if (user.role == 'COORDINATOR') {
                            Get.toNamed(AppRoutes.coordinatorDetail, arguments: {
                              'id': user.userId,
                              'name': user.fullName,
                              'email': user.email,
                              'is_active': user.isActive,
                            });
                          } else if (user.role == 'SUPPLIER') {
                            Get.toNamed(AppRoutes.supplierDetail, arguments: {
                              'id': user.userId,
                              'name': user.fullName,
                              'email': user.email,
                              'is_active': user.isActive,
                            });
                          }
                        },
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: user.isActive ? AppColors.green.withValues(alpha: 0.1) : AppColors.red.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            color: user.isActive ? AppColors.green : AppColors.red,
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness)),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(user.email, style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(user.role, style: const TextStyle(fontSize: 12, color: AppColors.blue)),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: AppColors.textSubtitle.getByBrightness(brightness)),
                          onSelected: (value) {
                            if (value == 'status') {
                              _confirmStatusToggle(context, user.userId, user.isActive);
                            } else if (value == 'role') {
                              _showRoleChangeModal(context, user.userId, user.role);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'status',
                              child: Text(user.isActive ? 'إيقاف الحساب' : 'تنشيط الحساب'),
                            ),
                            const PopupMenuItem(
                              value: 'role',
                              child: Text('تغيير نظام الدور/الرتبة'),
                            ),
                          ],
                        ),
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

  void _confirmStatusToggle(BuildContext context, int userId, bool isActive) {
    Get.defaultDialog(
      title: 'تأكيد العملية',
      middleText: isActive ? 'هل أنت متأكد من إيقاف هذا الحساب عن العمل؟' : 'هل أنت متأكد من تنشيط هذا الحساب مجدداً؟',
      textConfirm: 'تأكيد',
      textCancel: 'إلغاء',
      confirmTextColor: AppColors.white,
      onConfirm: () {
        controller.toggleUserStatus(userId, isActive);
        Get.back();
      },
    );
  }

  void _showRoleChangeModal(BuildContext context, int userId, String currentRole) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تغيير رتبة المستخدم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...controller.rolesList.map((role) {
              return ListTile(
                title: Text(role.roleName),
                trailing: currentRole == role.roleName ? const Icon(Icons.check, color: AppColors.green) : null,
                onTap: () {
                  controller.changeUserRole(userId, role.id);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
