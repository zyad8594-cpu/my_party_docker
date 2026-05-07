import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../data/models/supplier.dart' show Supplier;
import '../controller/supplier_controller.dart' show SupplierController;
import '../../../core/themes/app_colors.dart';
// import '../../../core/utils/utils.dart';
import '../../shared/widgets/user_card_widget.dart';
import '../../shared/widgets/generic_user_list_view.dart';

class SupplierListScreen extends GetView<SupplierController> 
{
  SupplierListScreen({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return GenericUserListView<Supplier>(
      isLoading: controller.isLoading,
      filters: () => controller.filteredSuppliers,
      searchQuery: controller.searchQuery,
      searchHint: 'ابحث عن مورد بالاسم أو البريد أو الهاتف...',
      scrollController: controller.scrollController,
      onRefresh: () => controller.fetchAll(force: true),
      emptyMessage: 'لا يوجد نتائج للبحث',
      emptyIcon: Icons.store_mall_directory_outlined,
      itemBuilder: (context, index, supplier) => UserCardWidget<SupplierController>(
       user: supplier,
        fallbackIcon: Icons.storefront_rounded,
        onTap: () => Get.toNamed(AppRoutes.supplierDetail, arguments: supplier),
        popupItems: [
          {
            'value': 'status', 
            'icon': supplier.isActive ? Icons.block_rounded : Icons.check_circle_outline_rounded, 
            'text': supplier.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب', 
            'color': supplier.isActive ? AppColors.accent.getByBrightness(brightness) : AppColors.green,
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
          // }
        ],
      ),
    );
  }
}
