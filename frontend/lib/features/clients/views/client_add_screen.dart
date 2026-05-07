import 'package:get/get.dart';
import 'package:flutter/material.dart';
  
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../controller/client_controller.dart' show ClientController;
import '../data/models/client.dart' show Client;

class ClientAddScreen extends StatelessWidget 
{
  ClientAddScreen({super.key});

  final ClientController clientController = Get.find<ClientController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final Client? client = Get.arguments;
    final isEditing = client != null;

    if (isEditing) {
      clientController.populateFields(client);
    } else {
      clientController.clearFields();
    }

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        // authController: authController,
        showBackButton: true,
        title: isEditing ? 'تعديل بيانات العميل' : 'إضافة عميل جديد',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'تحديث المعلومات' : 'البيانات الشخصية للعميل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: clientController.pickImage,
                      child: Obx(
                        () => Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            image: clientController.profileImage.value != null
                                ? DecorationImage(
                                    image: FileImage(clientController.profileImage.value!),
                                    fit: BoxFit.cover,
                                  )
                                : (isEditing && client.imgUrl != null && client.imgUrl!.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(client.imgUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                            border: Border.all(
                              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: (clientController.profileImage.value == null &&
                                  !(isEditing && client.imgUrl != null && client.imgUrl!.isNotEmpty))
                              ? Icon(
                                  Icons.add_a_photo_rounded,
                                  color: AppColors.primary.getByBrightness(brightness),
                                  size: 32,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    initialValue: isEditing ? client.name : null,
                    onChanged: (val) => clientController.nameRx.value = val,
                    decoration: AppFormWidgets.fieldDecoration('الاسم الكامل', Icons.person_outline_rounded, context),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: isEditing ? client.phoneNumber : null,
                    onChanged: (val) => clientController.phoneRx.value = val,
                    keyboardType: TextInputType.phone,
                    decoration: AppFormWidgets.fieldDecoration('رقم الهاتف', Icons.phone_rounded, context),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: isEditing ? client.email : null,
                    onChanged: (val) => clientController.emailRx.value = val,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppFormWidgets.fieldDecoration('البريد الإلكتروني', Icons.email_rounded, context),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: isEditing ? client.address : null,
                    onChanged: (val) => clientController.addressRx.value = val,
                    decoration: AppFormWidgets.fieldDecoration('العنوان', Icons.location_on_rounded, context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Obx(
              () => GradientButton(
                text: isEditing ? 'حفظ التعديلات' : 'إضافة العميل',
                isLoading: clientController.isLoading.value,
                onPressed: () async {
                  
                  if (isEditing) {
                    await clientController.updateClient(client.id);
                  } else {
                    await clientController.createClient();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
