import 'package:flutter/material.dart';
  
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../core/components/app_image.dart' show AppImage;
// import '../../../core/utils/utils.dart' show MyPUtils;
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../clients/data/models/client.dart' show Client;
import '../controller/event_controller.dart' show EventController;
import '../data/models/event.dart' show Event;
// import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import 'event_client/event_client_selection_screen.dart' show EventClientSelectionScreen;

class EventAddScreen extends GetView<EventController> 
{
  EventAddScreen({super.key});
final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    Event? event = Get.arguments as Event?;
    Client? client = (event != null? Client(
      id: event.clientId, 
      coordinatorId: event.coordinatorId,
      name: event.clientName, 
      phoneNumber: event.clientPhone, 
      email: event.clientEmail,
      imgUrl: event.clientImg
    ): null);
    // final Client? client = Get.arguments?['client'] as Client?;
    final isEditing = event != null;

    if (isEditing) {
      controller.populateFields(event);
    } else {
      controller.clearFields();
    }

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        // authController: authController,
        showBackButton: true,
        title: isEditing ? 'تعديل المناسبة' : 'إضافة مناسبة جديدة',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'تحديث تفاصيل المناسبة' : 'بيانات المناسبة الأساسية',
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
                      onTap: controller.pickImage,
                      child: Obx(
                        () => Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            image: controller.eventImage.value != null
                                ? DecorationImage(
                                    image: FileImage(controller.eventImage.value!),
                                    fit: BoxFit.cover,
                                  )
                                : (isEditing && (event?.imgUrl ?? '').isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage((event?.imgUrl ?? '')),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                            border: Border.all(
                              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: (controller.eventImage.value == null && 
                                  !(isEditing && (event?.imgUrl ?? '').isNotEmpty))
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      color: AppColors.primary.getByBrightness(brightness),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'صورة المناسبة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary.getByBrightness(brightness),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    initialValue: controller.eventNameRx.value,
                    onChanged: (val) => controller.eventNameRx.value = val,
                    decoration: AppFormWidgets.fieldDecoration('اسم المناسبة', Icons.celebration_rounded, context),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildDatePicker(context),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: controller.durationRx.value.toString(),
                          onChanged: (val) => controller.durationRx.value = int.tryParse(val) ?? 1,
                          keyboardType: TextInputType.number,
                          decoration: AppFormWidgets.fieldDecoration('المدة', Icons.timer_rounded, context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Obx(() => DropdownButtonFormField<String>(
                          initialValue: controller.durationUnitRx.value,
                          items: const [
                             DropdownMenuItem(value: 'DAY', child: Text('يوم')),
                             DropdownMenuItem(value: 'WEEK', child: Text('أسبوع')),
                             DropdownMenuItem(value: 'MONTH', child: Text('شهر')),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.durationUnitRx.value = val;
                          },
                          decoration: AppFormWidgets.fieldDecoration('الوحدة', Icons.more_time_rounded, context),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    initialValue: controller.locationRx.value,
                    onChanged: (val) => controller.locationRx.value = val,
                    decoration: AppFormWidgets.fieldDecoration('الموقع', Icons.location_on_rounded, context),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    initialValue: controller.budgetRx.value.toString(),
                    onChanged: (val) => controller.budgetRx.value = double.tryParse(val) ?? 0,
                    keyboardType: TextInputType.number,
                    decoration: AppFormWidgets.fieldDecoration('الميزانية المقترحة', Icons.account_balance_wallet_rounded, context),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    initialValue: controller.descriptionRx.value,
                    onChanged: (val) => controller.descriptionRx.value = val,
                    maxLines: 4,
                    decoration: AppFormWidgets.fieldDecoration('وصف تفصيلي للمناسبة', Icons.description_rounded, context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Obx(() {
                   
                    // ignore: unused_local_variable
                    final isSslected = controller.clientIdRx.value > 0;
                    
                    // final _client = controller.clientRx.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color:AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.getByBrightness(brightness),
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        // onTap: () => controller.clientIdRx.value = client.id,
                        onTap: () async {
                          final res = (await Get.to<Client>(()=>EventClientSelectionScreen(), arguments: controller.clientIdRx.value));
                          if(res != null) {
                            controller.clientIdRx.value = res.id;
                            client = res;
                            event = event?.copyWith(
                              clientId: res.id,
                              coordinatorId: res.coordinatorId,
                              clientName: res.name,
                              clientPhone: res.phoneNumber,
                              clientEmail: res.email,
                              clientImg: res.imgUrl,
                            );
                          }
                        },
                        leading: ClipOval(
                          child: AppImage.network(
                            client?.imgUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            viewerTitle: client?.name,
                            fallbackWidget: Container(
                              width: 40,
                              height: 40,
                              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.primary.getByBrightness(brightness),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          client?.name ?? 'يرجى إختيار عميل',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(client?.phoneNumber ?? '', style: const TextStyle(fontSize: 13)),
                            if (client != null && client!.email != null && client!.email!.isNotEmpty)
                              Text(client!.email!, style: TextStyle(fontSize: 12, color: AppColors.grey[600])),
                          ],
                        ),
                        trailing: client != null ? Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary.getByBrightness(brightness),
                              ) : null,
                      ),
                    );
                  }),
            const SizedBox(height: 40),

            Obx(
              () => GradientButton(
                isLoading: controller.isLoading.value,
                text: isEditing ? 'حفظ التعديلات' :  'إنشاء',
                onPressed: () async {
                  if (isEditing) {
                    controller.updateEvent(event!.id);
                  } else {
                   
                      controller.create();
                    
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: controller.dateRx.value,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primary.getByBrightness(brightness),
                  onPrimary: AppColors.white,
                  surface: AppColors.surface.getByBrightness(brightness),
                  onSurface: AppColors.textBody.getByBrightness(brightness),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          controller.dateRx.value = date;
        }
      },
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: AppFormWidgets.dateDecoration(context),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary.getByBrightness(brightness),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ المناسبة',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy/MM/dd').format(controller.dateRx.value),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBody.getByBrightness(brightness),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.edit_calendar_rounded,
                color: AppColors.textSubtitle.getByBrightness(brightness),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
