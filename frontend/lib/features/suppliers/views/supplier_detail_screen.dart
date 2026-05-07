import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/auth_service.dart';
import '../data/models/supplier.dart' show Supplier;
import '../controller/supplier_controller.dart' show SupplierController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/app_image.dart';
import '../../../core/components/widgets/app_detail_widgets.dart' show AppDetailWidgets;
// import 'package:url_launcher/url_launcher.dart';
// import '../../../core/utils/utils.dart' show MyPUtils;

class SupplierDetailScreen extends GetView<SupplierController> 
{
  const SupplierDetailScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    final dynamic args = Get.arguments;

    Supplier supplierArg;
    if (args is Map) {
      supplierArg = Supplier(
        id: args['id'],
        name: args['name'] ?? '',
        email: args['email'] ?? '',
        password: '',
        isActive: args['is_active'] ?? false,
      );
    } else {
      supplierArg = args;
    }

    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: true, 
        title: supplierArg.name
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColors.background.getByBrightness(brightness)),
        child: Obx(() {
          // Find the latest version
          final supplier = controller.suppliers.firstWhere(
            (s) => s.id == supplierArg.id, 
            orElse: () => supplierArg
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(supplier, brightness),
                const SizedBox(height: 32),
                _buildInfoSection(context, supplier),
                const SizedBox(height: 40),
                _buildActions(context, supplier, brightness),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(Supplier supplier, Brightness brightness) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient.getByBrightness(brightness),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: supplier.imgUrl != null
                    ? ClipOval(
                        child: AppImage.network(
                          supplier.imgUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          viewerTitle: supplier.name,
                          fallbackWidget: const Icon(
                            Icons.store_mall_directory_outlined,
                            size: 64,
                            color: AppColors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.store_mall_directory_outlined,
                        size: 64,
                        color: AppColors.white,
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: supplier.isActive ? AppColors.green : AppColors.red,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surface.getByBrightness(brightness), width: 2),
                ),
                child: Text(
                  supplier.isActive ? 'نشط' : 'معطل',
                  style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          supplier.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textBody.getByBrightness(brightness),
          ),
        ),
        Text(
          'مزود خدمات معتمد',
          style: TextStyle(color: AppColors.primary.getByBrightness(brightness), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Supplier supplier) {
    return Column(
      children: [
        AppDetailWidgets.buildGlassInfoRow(
          Icons.email_outlined,
          'البريد الإلكتروني',
          supplier.email,
          context,
        ),
        const SizedBox(height: 16),
        AppDetailWidgets.buildGlassInfoRow(Icons.phone_outlined, 'رقم الهاتف', supplier.phoneNumber??'', context),
        const SizedBox(height: 16),
        AppDetailWidgets.buildGlassInfoRow(
          Icons.notes_outlined,
          'ملاحظات',
          supplier.notes ?? 'لا توجد ملاحظات',
          context,
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Supplier supplier, Brightness brightness) {
    final isAdmin = AuthService.userIsAdmin;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/suppliers/add', arguments: supplier),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('تعديل البيانات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface.getByBrightness(brightness),
                  foregroundColor: AppColors.primary.getByBrightness(brightness),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // const SizedBox(width: 16),
            // Expanded(
            //   child: ElevatedButton.icon(
            //     onPressed: () async {
            //       if (supplier.phoneNumber != null && supplier.phoneNumber!.isNotEmpty) {
            //         final Uri whatsappUri = Uri.parse("https://wa.me/${supplier.phoneNumber}");
            //         if (await canLaunchUrl(whatsappUri)) {
            //           await launchUrl(whatsappUri);
            //         } else {
            //           MyPUtils.showSnackbar('خطأ', 'لا يمكن فتح الواتساب');
            //         }
            //       } else {
            //         MyPUtils.showSnackbar('تنبيه', 'رقم الهاتف غير متوفر');
            //       }
            //     },
            //     icon: const Icon(Icons.message_outlined, size: 18),
            //     label: const Text('مراسلة المورد'),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primary.getByBrightness(brightness),
            //       foregroundColor: AppColors.white,
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //     ),
            //   ),
            // ),
          ],
        ),
        if (isAdmin) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.toggleStatus(supplier.id, !supplier.isActive),
                  icon: Icon(
                    supplier.isActive ? Icons.block_flipped : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(supplier.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: supplier.isActive ? AppColors.red.withValues(alpha: 0.1) : AppColors.green.withValues(alpha: 0.1),
                    foregroundColor: supplier.isActive ? AppColors.red : AppColors.green,
                    elevation: 0,
                    side: BorderSide(color: supplier.isActive ? AppColors.red : AppColors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: ElevatedButton.icon(
              //     onPressed: () => _delete(supplier.id, context),
              //     icon: const Icon(Icons.delete_rounded, size: 18),
              //     label: const Text('حذف الحساب'),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.accent.getByBrightness(brightness).withValues(alpha: 0.1),
              //       foregroundColor: AppColors.accent.getByBrightness(brightness),
              //       elevation: 0,
              //       padding: const EdgeInsets.symmetric(vertical: 12),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ],
    );
  }

  // void _delete(int id, BuildContext context) {
  //   MyPUtils.showConfirmDialog(
  //     context: context,
  //     title: 'حذف المورد',
  //     message: 'هل أنت متأكد من حذف هذا المورد نهائياً؟',
  //     confirmLabel: 'حذف',
  //     isDanger: true,
  //     onConfirm: () {
  //       controller.delete(id);
  //       Get.back(); // Return to list
  //     },
  //   );
  // }
}
