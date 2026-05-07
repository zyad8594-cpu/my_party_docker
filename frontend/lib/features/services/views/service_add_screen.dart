import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../controller/service_controller.dart' show ServiceController;
import '../data/models/service.dart' show Service;

class ServiceAddScreen extends GetView<ServiceController> 
{
  ServiceAddScreen({super.key});
final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    final Service? service = Get.arguments as Service?;
    final isEditing = service != null;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        // authController: authController,
        showBackButton: true,
        title: isEditing ? 'تعديل الخدمة' : 'إضافة خدمة جديدة',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller.nameController,
                decoration: AppFormWidgets.fieldDecoration('اسم الخدمة', Icons.category_outlined, context),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: AppFormWidgets.fieldDecoration('الوصف', Icons.description_outlined, context),
              ),
              const SizedBox(height: 32),
              Obx(
                () => GradientButton(
                  text: isEditing ? 'حفظ التعديلات' : 'إضافة',
                  isLoading: controller.isLoading.value,
                  onPressed: () async{
                    if (isEditing) {
                      await controller.updateService(service.id);
                    } 
                    else 
                    {
                      await controller.createService();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
