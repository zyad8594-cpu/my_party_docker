import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/data/models/service.dart' show Service;
import '../controller/auth_controller.dart' show AuthController;
import '../../services/controller/service_controller.dart' show ServiceController;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../core/components/widgets/myp_list_view_widget.dart' show MyPListView;

class SupplierServiceSelectionScreen extends GetView<AuthController> {
  const SupplierServiceSelectionScreen({super.key});

  // ServiceController remains injected manually since GetView strictly wraps one generic boundary.
  ServiceController get serviceController => Get.find<ServiceController>();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    // Fetch services if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      serviceController.fetchAll();
    });

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        showBackButton: true,
        title: 'إنشاء حساب',
        showLogoutButton: false,
        showNotificationButton: false,
        bottom: PreferredSize(preferredSize: Size(Get.width, 20), child: Text('اختيار الخدمات')),
        
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ما هي الخدمات التي تقدمها؟',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textBody.getByBrightness(brightness),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'يمكنك اختيار أكثر من خدمة أو التخطي وإضافتها لاحقاً',
                style: TextStyle(
                  color: AppColors.textSubtitle.getByBrightness(brightness),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: MyPListView.builder<Service>(
                  context,
                  isLoading: serviceController.isLoading,
                  loadingWidget: () => const LoadingWidget(),
                  emptyWidget: () => Center(
                    child: Text(
                      'لا توجد خدمات متاحة حالياً',
                      style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
                    ),
                  ),
                  filters: () => serviceController.services,
                  scrollController: serviceController.scrollController,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index, service) {
                    return Obx(() {
                      final isSelected = controller.selectedServiceIds.contains(service.id);
                      return InkWell(
                        onTap: () {
                          if (isSelected) {
                            controller.selectedServiceIds.remove(service.id);
                          } else {
                            controller.selectedServiceIds.add(service.id);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1)
                              : AppColors.surface.getByBrightness(brightness),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                ? AppColors.primary.getByBrightness(brightness)
                                : AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: isSelected 
                                  ? AppColors.primary.getByBrightness(brightness)
                                  : AppColors.textSubtitle.getByBrightness(brightness),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  service.serviceName,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: AppColors.textBody.getByBrightness(brightness),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.selectedServiceIds.clear();
                        controller.register();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
                      ),
                      child: Text(
                        'تخطي',
                        style: TextStyle(color: AppColors.primary.getByBrightness(brightness)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Obx(() => GradientButton(
                      text: 'إنشاء الحساب',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.register,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
