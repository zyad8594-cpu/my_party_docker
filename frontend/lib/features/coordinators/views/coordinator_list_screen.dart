import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../data/models/coordinator.dart' show Coordinator;
import '../controller/coordinator_controller.dart' show CoordinatorController;
import '../../../core/themes/app_colors.dart';
// import '../../../core/utils/utils.dart';
import '../../shared/widgets/user_card_widget.dart';
import '../../shared/widgets/generic_user_list_view.dart';

class CoordinatorListScreen extends GetView<CoordinatorController> {
  CoordinatorListScreen({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return GenericUserListView<Coordinator>(
      isLoading: controller.isLoading,
      filters: () => controller.filteredCoordinators,
      searchQuery: controller.searchQuery,
      searchHint: 'ابحث عن منسق بالاسم أو البريد...',
      scrollController: controller.scrollController,
      onRefresh: () => controller.fetchAll(force: true),
      emptyMessage: 'لا يوجد نتائج للبحث',
      emptyIcon: Icons.person_off_outlined,
      itemBuilder: (context, index, coordinator) => UserCardWidget<CoordinatorController>(
        user: coordinator,
        onTap: () => Get.toNamed(AppRoutes.coordinatorDetail, arguments: coordinator),
        popupItems: [
          {
            'value': 'status', 
            'icon': coordinator.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded, 
            'text': coordinator.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب',
            'color': coordinator.isActive ? AppColors.accent.getByBrightness(brightness) : AppColors.green,
          },
          {
            'value': 'edit', 
            'icon': Icons.edit_rounded, 
            'text': 'تعديل', 
            'color': AppColors.orange,
          },
          // {
          //   'value': 'delete', 
          //   'icon': Icons.delete_rounded, 
          //   'text': 'حذف', 
          //   'color': AppColors.accent.getByBrightness(brightness),
          // },
        ],
      ),
    );
  }

  // void _delete(int id, {required BuildContext arguments}) {
  //   MyPUtils.showConfirmDialog(
  //     context: arguments,
  //     title: 'حذف المنسق',
  //     message: 'هل أنت متأكد من حذف هذا المنسق نهائياً؟',
  //     confirmLabel: 'حذف',
  //     isDanger: true,
  //     onConfirm: () {
  //       controller.delete(id);
  //     },
  //   );
  // }
}
