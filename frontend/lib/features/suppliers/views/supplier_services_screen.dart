import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart';

import '../../../core/api/auth_service.dart';
import '../../../core/components/empty_state_widget.dart' show EmptyStateWidget;
import '../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../core/components/widgets/myp_list_view_widget.dart' show MyPListView;
import '../../../core/components/widgets/search_box_widget.dart' show SearchBox;
import '../../../core/themes/app_colors.dart';
import '../../../core/components/custom_app_bar.dart';
// import '../../services/data/models/service.dart' show Service;
import '../../services/data/models/service_request.dart' show ServiceRequest;
import '../controller/supplier_controller.dart';

class SupplierServicesScreen extends GetView<SupplierController> {
  const SupplierServicesScreen({super.key});

  void _showProposeServiceDialog(BuildContext context) {
    String serviceName = '';
    String description = '';
    final brightness = Theme.of(context).brightness;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24, left: 24, right: 24
        ),
        decoration: BoxDecoration(
          color: AppColors.background.getByBrightness(brightness),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اقتراح خدمة جديدة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBody.getByBrightness(brightness),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'اسم الخدمة المقترحة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.design_services_outlined)
                ),
                onChanged: (val) => serviceName = val,
              ),
              const SizedBox(height: 16),

              TextField(
                decoration: InputDecoration(
                  labelText: 'تفاصيل الخدمة وكيفية تسعيرها...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_outlined)
                ),
                maxLines: 4,
                onChanged: (val) => description = val,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.getByBrightness(brightness),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (serviceName.trim().isNotEmpty) {
                      controller.proposeService(serviceName, description);
                    } else {
                      Get.snackbar('تنبيه', 'الرجاء إدخال اسم الخدمة', backgroundColor: AppColors.red[100], colorText: AppColors.red[900]);
                    }
                  },
                  child: const Text('إرسال الاقتراح للإدارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
       controller.fetch(AuthService.user.value.id);
       controller.fetchMyProposals();
       controller.fetchMyServices();
    });

    final brightness = Theme.of(context).brightness;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background.getByBrightness(brightness),
        appBar: CustomAppBar(
          title: 'الخدمات', 
          showBackButton: false,
          bottom: TabBar(
            tabs: [
              Tab(text: 'خدماتي', 
                icon: Icon(Icons.star_rounded, color: AppColors.primary.getByBrightness(brightness))
              ),
              Tab(text: 'اقتراحاتي', 
                icon: Icon(Icons.inbox_outlined, color: AppColors.primary.getByBrightness(brightness))),
            ],
            indicatorColor: AppColors.primary.getByBrightness(brightness),
            labelColor: AppColors.primary.getByBrightness(brightness),
            unselectedLabelColor: AppColors.primary.getByBrightness(brightness),
          ),
        ),
        
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showProposeServiceDialog(context),
          backgroundColor: AppColors.primary.getByBrightness(brightness),
          icon: const Icon(Icons.add_circle_outline, color: AppColors.white),
          label: const Text(
            'اقتراح خدمة جديدة', 
            style: TextStyle(
              color: AppColors.white, 
              fontWeight: FontWeight.bold
            )
          ),
        ),
        body: TabBarView(
          children: [
 
            _buuldTab(context, 
              isService: true, 
              itemBuilder: (context, index, item) {
                final svc = controller.myServices.value[index];
                final hasService = svc['supplier_has_service'] == 1;
                // final serviceId = svc['service_id'];
                
                return _buildSharedContainer(context,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    trailing: IconButton(
                      onPressed: ()async=> await _showAddServiceOrProposalDialog(
                        svc['service_id'],
                        supplierId:  AuthService.user.value.id,  
                        hasService: hasService
                      ),
                      icon: Icon(
                        hasService? Icons.remove_circle_outline : Icons.add_circle_outline,
                        color: hasService? AppColors.red : AppColors.primary.getByBrightness(brightness),
                        size: 28,
                      ),
                    ),
                    title: Text(
                      svc['service_name'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness)),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        svc['service_description'] ?? 'لا يوجد وصف متاح لهذه الخدمة.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSubtitle.getByBrightness(brightness)),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            _buuldTab(context, 
              isService: false, 
              itemBuilder: (context, index, item) {
                  String serviceName = _setOrDef('لا يوجد اسم للخدمة', () => item.serviceName,
                    () => (item as ServiceRequest).serviceName,
                  );

                  Status status = _setOrDef<String>('REJECTED', ()=> item.status,
                    () => (item as ServiceRequest).status,
                  ).status('REJECTED');

                  String description = _setOrDef('لا يوجد تفاصيل إضافية', ()=> item.description,
                    () => (item as ServiceRequest).description!,
                  );
                  
                  int id = _setOrDef(0, ()=> item.id,
                    () => (item as ServiceRequest).id,
                  );

                  return _buildSharedContainer(context,
                    padding: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.new_releases_rounded, color: AppColors.secondary.getByBrightness(brightness)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                serviceName,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: status.tryColor(brightness).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status.tryText('مرفوض'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: status.tryColor(brightness),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 13),
                        ),
                        if (status == Status.PENDING) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red.withValues(alpha: 0.1),
                                foregroundColor: AppColors.red,
                                elevation: 0,
                              ),
                              onPressed: ()=> _showAddServiceOrProposalDialog(id, isService: false),
                              icon: const Icon(Icons.outbox_rounded, size: 18),
                              label: const Text('التراجع عن الاقتراح'),
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                }
            ),

            
           
          ],
        ),
      ),
    );
  }

  // Color _getStatusColor(Brightness brightness, String status)
  // {
  //   return status.status('REJECTED').tryColor(brightness);
  //   // return switch(){
  //   //   'PENDING' => AppColors.orange,
  //   //   'APPROVED' => AppColors.green,
  //   //   _ => AppColors.red,
  //   // };
  // }

  T _setOrDef<T>(T defaultValue, T Function() value, [T? Function()? val])
  {
    
    try{ 
      if(val == null ) throw Exception();
      final ret = val();
      if((ret is String && ret.isNotEmpty) || (ret is num && ret != 0) || ret != null) return ret!;
      throw Exception();
    }
    catch(e){ 
      try{ 
        final ret = value();
        if((ret is String && ret.isEmpty) || (ret is num && ret == 0)) throw Exception();
        return ret;
      }
      catch(e1){ return defaultValue; }
     }
  }
  
  Future<T?> _showAddServiceOrProposalDialog<T>(int serviceId, {int supplierId = 0, bool hasService = false, bool isService = true}) async {
    return await switch(isService){
      true => Get.defaultDialog(
        title: hasService ? 'إزالة الخدمة' : 'إضافة الخدمة',
        middleText: hasService
            ? 'هل أنت متأكد من إزالة هذه الخدمة من قائمة خدماتك؟'
            : 'هل تريد إضافة هذه الخدمة إلى خدماتك؟',
        textConfirm: 'نعم',
        textCancel: 'إلغاء',
        confirmTextColor: AppColors.white,
        onConfirm: () async {
          Get.back();
          await switch(hasService){
            true => controller.removeService(supplierId, serviceId),
            false => controller.assignService(supplierId, serviceId),
          };
          // if (hasService) {
          //   await controller.removeService(supplierId, serviceId);
          // } else {
          //   await controller.assignService(supplierId, serviceId);
          // }
          controller.fetchMyServices();
        },
      ),
      
      false => Get.defaultDialog(
        title: 'سحب الاقتراح',
        middleText: 'هل ترغب في التراجع عن هذا الاقتراح؟',
        textConfirm: 'سحب والتراجع',
        textCancel: 'إلغاء',
        confirmTextColor: AppColors.white,
        onConfirm: () {
          Get.back();
          controller.withdrawProposal(serviceId);
        },
      )
    };
                      
  }
  
  Widget _buildSharedContainer(BuildContext context, {Widget? child, double padding = 0})
  {
    final brightness = Theme.of(context).brightness;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
  
  Widget _buuldTab(
    BuildContext context,{
    required Widget Function(BuildContext, int, dynamic) itemBuilder, 
    bool isService = true,
  }) {
    return MyPListView.builder<dynamic>(
      context,
      isLoading: isService? controller.isMyServicesLoading : controller.isProposalsLoading, 
      onRefresh: () async=> isService? await controller.fetchMyServices() : await controller.fetchMyProposals(),
      loadingWidget: () => const LoadingWidget(),
      emptyWidget: () => EmptyStateWidget(
        message: isService?
                (controller.searchQuery.value.isEmpty ? 'لا يوجد خدمات متاحة حالياً' : 'لا توجد نتائج بحث مطابقة')
                : (controller.proposalSearchQuery.value.isEmpty ? 'لم تقم باقتراح أي خدمة بعد' : 'لا توجد نتائج بحث مطابقة'), 
        icon: isService? Icons.inventory_2_outlined : Icons.inbox_outlined,
      ),
      filters: () => isService? controller.myServices.value : controller.filteredProposals,
      scrollController: controller.scrollController,
      padding: const EdgeInsets.all(20),
      header: SearchBox.withNotLayout(context, 
        isService? 'بحث في الخدمات المتاحة...' : 'بحث في اقتراحاتي...',
        searchOnChanged: (val) => isService? (controller.searchQuery.value = val) : (controller.proposalSearchQuery.value = val)
      ),
      itemBuilder: itemBuilder,
    );
  }


}
