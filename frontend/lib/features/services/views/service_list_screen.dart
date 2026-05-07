import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/service.dart' show Service;
import '../data/models/service_request.dart' show ServiceRequest;
import '../controller/service_controller.dart' show ServiceController;
import '../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../core/components/empty_state_widget.dart' show EmptyStateWidget;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/api/auth_service.dart' show AuthService;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../../core/utils/status.dart' show StatusTools, StatusExtension;
import '../../../core/components/widgets/myp_list_view_widget.dart' show MyPListView;
import '../../../core/components/widgets/myp_actions.dart' show MyPActions;
import '../../../core/components/app_image.dart' show AppImage;

class ServiceListScreen extends GetView<ServiceController> {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String role = AuthService.user.value.role.isNotEmpty? AuthService.user.value.role.toLowerCase() : 'user';
    final bool isSupplier = role == 'supplier';
    
    // Automatically fetch on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isSupplier) {
        controller.fetchMyServiceRequests();
      } else {
        controller.fetchServiceRequests();
      }
    });
    
    final brightness = Theme.of(context).brightness;

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (controller.currentTabIndex.value != tabController.index) {
              controller.currentTabIndex.value = tabController.index;
            }
          });

          return Scaffold(
            appBar: CustomAppBar(
              title: 'قائمة الخدمات',
              bottom: TabBar(
                tabs: [
                  Tab(text: 'الخدمات الحالية', icon: Icon(Icons.list_alt_rounded, color: AppColors.primary.getByBrightness(brightness))),
                  Tab(text: 'الخدمات المقترحة', icon: Icon(Icons.new_releases_outlined, color: AppColors.primary.getByBrightness(brightness))),
                ],
                indicatorColor: AppColors.primary.getByBrightness(brightness),
                labelColor: AppColors.primary.getByBrightness(brightness),
                unselectedLabelColor: AppColors.textSubtitle.getByBrightness(brightness),
              ),
            ),
            floatingActionButton: Obx(() => controller.currentTabIndex.value == 0 
              ? MyPActions.floatButton(
                  context,
                  icon: Icons.add_rounded,
                  heroTag: 'add_service',
                  onPressed: () { 
                    controller.clearFields();
                    Get.toNamed(AppRoutes.serviceAdd); 
                  },
                )
              : const SizedBox.shrink()),
            body: Container(
              decoration: BoxDecoration(color: AppColors.background.getByBrightness(brightness)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextFormField(
                      onChanged: (value) => controller.searchQuery.value = value,
                      style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
                      decoration: InputDecoration(
                        hintText: 'ابحث في الخدمات المعروضة والمقترحة...',
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
                    child: TabBarView(
                      children: [
                        // Tab 1: Current Services
                        MyPListView.builder<Service>(
                          context,
                          isLoading: controller.isLoading,
                          onRefresh: () async => controller.fetchAll(force: true),
                          loadingWidget: () => const LoadingWidget(),
                          emptyWidget: () => const EmptyStateWidget(message: 'لا يوجد نتائج للبحث', icon: Icons.category_outlined),
                          filters: () => controller.filteredServices,
                          scrollController: controller.scrollController,
                          itemBuilder: (context, index, service) => _buildServiceCard(service, context),
                        ),
                        // Tab 2: Proposed Services
                        Column(
                          children: [
                            Obx(() => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: ['الكل', 'قيد الإنتظار', 'معتمدة', 'مرفوضة'].map((filter) {
                                  final isSelected = controller.selectedRequestFilter.value == filter;
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: FilterChip(
                                      label: Text(
                                        filter, 
                                        style: TextStyle(
                                          color: isSelected ? AppColors.white : AppColors.textSubtitle.getByBrightness(brightness)
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (_) => controller.selectedRequestFilter.value = filter,
                                      selectedColor: AppColors.primary.getByBrightness(brightness),
                                      backgroundColor: AppColors.background.getByBrightness(brightness),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2))),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )),
                            Expanded(
                              child: MyPListView.builder<dynamic>(
                                context,
                                isLoading: controller.isRequestsLoading,
                                onRefresh: () async {
                                    if (isSupplier) {
                                      await controller.fetchMyServiceRequests();
                                    } else {
                                      await controller.fetchServiceRequests();
                                    }
                                  },
                                loadingWidget: () => const LoadingWidget(),
                                emptyWidget: () => const EmptyStateWidget(message: 'لا يوجد نتائج للبحث في المقترحات', icon: Icons.inbox_outlined),
                                filters: () => controller.displayedServiceRequests,
                                itemBuilder: (context, index, request) => _buildProposedServiceCard(request, context, brightness),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProposedServiceCard(dynamic request, BuildContext context, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => _showProposedServiceDetailsSheet(request, context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: AppFormWidgets.cardDecoration(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.new_releases_rounded, color: AppColors.secondary.getByBrightness(brightness)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.serviceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary.getByBrightness(brightness),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: StatusTools.tryParse(request.status).tryColor(brightness).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(StatusTools.tryParse(request.status).tryText(), style: TextStyle(color: StatusTools.tryParse(request.status).tryColor(brightness), fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  request.description ?? 'لا يوجد تفاصيل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.storefront_outlined, size: 16, color: AppColors.textSubtitle.getByBrightness(brightness)),
                    const SizedBox(width: 4),
                    Text('المورد: ${request.supplierName}', style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 12)),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProposedServiceDetailsSheet(dynamic request, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // Cast dynamic to model if possible to get helper types
    final ServiceRequest req = request is ServiceRequest ? request : ServiceRequest.fromJson(request);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface.getByBrightness(brightness),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                  color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Hero(
                  tag: 'supplier_img_${req.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: AppImage.network(
                      req.supplierImg ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      fallbackWidget: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.getByBrightness(brightness).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.secondary.getByBrightness(brightness),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.serviceName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary.getByBrightness(brightness),
                        ),
                      ),
                      Text(
                        'عرض مقترح من: ${req.supplierName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: StatusTools.tryParse(req.status).tryColor(brightness).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    StatusTools.tryParse(req.status).tryText(),
                    style: TextStyle(
                      color: StatusTools.tryParse(req.status).tryColor(brightness),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Supplier Details Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.getByBrightness(brightness).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.phone_outlined, 'الهاتف:', req.supplierPhone ?? 'غير متوفر', brightness),
                  const Divider(height: 24, thickness: 0.5),
                  _buildDetailRow(Icons.email_outlined, 'البريد:', req.supplierEmail ?? 'غير متوفر', brightness),
                  const Divider(height: 24, thickness: 0.5),
                  _buildDetailRow(Icons.location_on_outlined, 'العنوان:', req.supplierAddress ?? 'غير متوفر', brightness),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'الوصف المقترح:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 8),

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: context.height * 0.2,
              ),
              child: SingleChildScrollView(
                child: Text(
                  req.description ?? 'لا يوجد وصف متاح لهذا الاقتراح.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textBody.getByBrightness(brightness),
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            if ((AuthService.user.value.role.toLowerCase() == 'admin' || AuthService.user.value.role.toLowerCase() == 'coordinator') && req.status == 'PENDING')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.defaultDialog(
                          title: 'رفض الاقتراح',
                          middleText: 'هل أنت متأكد من رفض هذه الخدمة المقترحة؟',
                          textConfirm: 'نعم',
                          textCancel: 'تراجع',
                          confirmTextColor: AppColors.white,
                          onConfirm: () {
                            Get.back();
                            controller.updateRequestStatus(req.id, 'REJECTED');
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red.withValues(alpha: 0.1),
                        foregroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('رفض الاقتراح', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Get.defaultDialog(
                          title: 'اعتماد الخدمة',
                          middleText: 'هل تريد اعتماد هذه الخدمة لتصبح خدمة نشطة في النظام؟\nسيتم نقلك لشاشة الإضافة مع تعبئة البيانات تلقائياً.',
                          textConfirm: 'متابعة',
                          textCancel: 'إلغاء',
                          confirmTextColor: AppColors.white,
                          onConfirm: () async{
                            Get.back();
                            controller.pendingApprovalRequestId = req.id;
                            controller.serviceNameRx.value = req.serviceName;
                            controller.descriptionRx.value = req.description ?? '';
                            controller.nameController.text = req.serviceName;
                            controller.descriptionController.text = req.description ?? '';
                            await Get.toNamed(AppRoutes.serviceAdd);
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green.withValues(alpha: 0.1),
                        foregroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('اعتماد وإضافة', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else if (req.status == 'PENDING' && AuthService.user.value.role.toLowerCase() == 'supplier')
               SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.defaultDialog(
                      title: 'سحب الطلب',
                      middleText: 'هل أنت متأكد من رغبتك في سحب هذا الاقتراح؟',
                      textConfirm: 'نعم',
                      textCancel: 'إلغاء',
                      confirmTextColor: AppColors.white,
                      onConfirm: () {
                        Get.back();
                        controller.withdrawRequest(req.id);
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent.getByBrightness(brightness).withValues(alpha: 0.1),
                    foregroundColor: AppColors.accent.getByBrightness(brightness),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('سحب الاقتراح', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            SizedBox(height: context.mediaQueryPadding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Brightness brightness) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary.getByBrightness(brightness)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSubtitle.getByBrightness(brightness),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.getByBrightness(brightness),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Service service, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => _showServiceDetailsSheet(service, context, brightness),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: AppFormWidgets.cardDecoration(context),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.getByBrightness(brightness).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: AppColors.secondary.getByBrightness(brightness),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.serviceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary.getByBrightness(brightness),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description ?? 'لا يوجد وصف',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showServiceDetailsSheet(Service service, BuildContext context, Brightness brightness) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface.getByBrightness(brightness),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                  color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.getByBrightness(brightness).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: AppColors.secondary.getByBrightness(brightness),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    service.serviceName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary.getByBrightness(brightness),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'الوصف:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: context.height * 0.3,
              ),
              child: SingleChildScrollView(
                child: Text(
                  service.description ?? 'لا يوجد وصف متاح لهذه الخدمة.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textBody.getByBrightness(brightness),
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showDeleteDialog(service.id, brightness);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent.getByBrightness(brightness).withValues(alpha: 0.1),
                      foregroundColor: AppColors.accent.getByBrightness(brightness),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('حذف الخدمة', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.populateFields(service);
                      Get.toNamed(AppRoutes.serviceAdd, arguments: service);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.getByBrightness(brightness),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('تعديل البيانات', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.mediaQueryPadding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showDeleteDialog(int id, Brightness brightness) async {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      titleStyle: TextStyle(color: AppColors.primary.getByBrightness(brightness)),
      middleText: 'هل أنت متأكد من حذف هذه الخدمة؟',
      middleTextStyle: TextStyle(color: AppColors.textPrimary.getByBrightness(brightness)),
      backgroundColor: AppColors.surface.getByBrightness(brightness),
      textConfirm: 'نعم',
      textCancel: 'لا',
      confirmTextColor: AppColors.black,
      cancelTextColor: AppColors.primary.getByBrightness(brightness),
      onConfirm: () {
        Get.back();
        controller.deleteService(id);
      },
    );
  }
}
