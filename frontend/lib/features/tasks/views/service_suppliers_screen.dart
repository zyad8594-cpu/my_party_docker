import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../core/components/app_image.dart';
import '../../services/controller/service_controller.dart' show ServiceController;
// import '../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../controller/task_controller.dart' show TaskController;
import '../../../core/components/widgets/myp_list_view_widget.dart' show MyPListView;

class ServiceSuppliersScreen extends StatelessWidget 
{
  // final int serviceId;
  // final String serviceName;

  const ServiceSuppliersScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final serviceCtrl = Get.find<ServiceController>();
    
    final controller = Get.find<TaskController>();
    final brightness = Theme.of(context).brightness;
    final service = serviceCtrl.selectedService.value;
    final serviceName = service?.serviceName ?? '';
    
    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: AppBar(
        title: Text('إضافة مهمة جديدة'),
        backgroundColor: AppColors.appBarBackground.getByBrightness(brightness),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Text(
                  'موردين - $serviceName',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSubtitle.getByBrightness(brightness),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface.getByBrightness(brightness),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: serviceCtrl.supplierSearchController,
                    onChanged: (value) => serviceCtrl.supplierSearchQuery.value = value,
                    style: TextStyle(color: AppColors.textBasec.getByBrightness(brightness)),
                    decoration: InputDecoration(
                      hintText: 'البحث عن مورد...',
                      hintStyle: TextStyle(
                        color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary.getByBrightness(brightness),
                      ),
                      suffixIcon: Obx(() => serviceCtrl.supplierSearchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                serviceCtrl.supplierSearchController.clear();
                                serviceCtrl.supplierSearchQuery.value = '';
                              },
                            )
                          : const SizedBox.shrink()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (serviceCtrl.isLoading.value) {
          return const LoadingWidget();
        }

        final allSuppliers = serviceCtrl.selectedService.value?.suppliers ?? [];
        final query = serviceCtrl.supplierSearchQuery.value.toLowerCase();
        
        final filteredSuppliers = allSuppliers.where((supplier) {
          return supplier.name.toLowerCase().contains(query) ||
              (supplier.phoneNumber?.contains(query) ?? false) ||
              (supplier.email.toLowerCase().contains(query));
        }).toList();

        if (filteredSuppliers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: AppColors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  query.isEmpty ? 'لا يوجد موردين لهذه الخدمة' : 'لا يوجد موردين يطابقون بحثك',
                  style: TextStyle(color: AppColors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return MyPListView.builder<dynamic>(
          context,
          isLoading: serviceCtrl.isLoading,
          loadingWidget: () => const LoadingWidget(),
          emptyWidget: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: AppColors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  query.isEmpty ? 'لا يوجد موردين لهذه الخدمة' : 'لا يوجد موردين يطابقون بحثك',
                  style: TextStyle(color: AppColors.grey.shade600),
                ),
              ],
            ),
          ),
          filters: () => filteredSuppliers,
          scrollController: serviceCtrl.scrollController,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index, supplier) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: AppColors.black.withValues(alpha: 0.1),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: (supplier.imgUrl != null && supplier.imgUrl!.isNotEmpty)
                        ? AppImage.network(
                            supplier.imgUrl!,
                            fit: BoxFit.cover,
                            viewerTitle: supplier.name,
                            fallbackWidget: Icon(
                              Icons.person_rounded,
                              color: AppColors.primary.getByBrightness(brightness),
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: AppColors.primary.getByBrightness(brightness),
                          ),
                  ),
                ),
                title: Text(
                  supplier.name.isEmpty ? 'لا يوجد اسم' : supplier.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBasec.getByBrightness(brightness),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_android_rounded, size: 14, color: AppColors.textSubtitle.getByBrightness(brightness)),
                        const SizedBox(width: 4),
                        Text(
                          (supplier.phoneNumber ?? '').isEmpty ? 'لا يوجد رقم' : supplier.phoneNumber!,
                          style: TextStyle(
                            color: AppColors.textSubtitle.getByBrightness(brightness),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (supplier.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 14, color: AppColors.textSubtitle.getByBrightness(brightness)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              supplier.email,
                              style: TextStyle(
                                color: AppColors.textSubtitle.getByBrightness(brightness),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (supplier.averageRating != null && supplier.averageRating! > 0)
                        ? AppColors.amber.withValues(alpha: 0.15)
                        : AppColors.surface.getByBrightness(brightness),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (supplier.averageRating != null && supplier.averageRating! > 0) ...[
                        const Icon(Icons.star_rounded, color: AppColors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${(supplier.averageRating! / 5.0 * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textBasec.getByBrightness(brightness),
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.star_border_rounded, color: AppColors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'جديد',
                          style: TextStyle(color: AppColors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
                onTap: () {
                  controller.assigneeIdRx.value = supplier.id;
                  Get.back(result: supplier);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
