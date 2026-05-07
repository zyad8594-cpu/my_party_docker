import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../events/data/models/event.dart' show Event;
import '../controller/income_controller.dart' show IncomeController;
import '../../events/controller/event_controller.dart' show EventController;
import '../data/models/income.dart' show Income;

class IncomeAddScreen extends GetView<IncomeController> 
{
  IncomeAddScreen({super.key});
final EventController eventCtrl = Get.find<EventController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    eventCtrl.fetchAll();
    final Income? income = (Get.arguments is Income)?
        Get.arguments 
        : (Get.arguments is Map<String, dynamic>? 
          (Get.arguments['income'] as Income?) : null);
          
    final Event? event = (Get.arguments is Event)?
        Get.arguments 
        : (Get.arguments is Map<String, dynamic>? 
          (Get.arguments['event'] as Event?) : null);
    if(event != null)
    {
      controller.eventIdRx.value = event.id;
    }
    final isEditing = income != null;

    if (isEditing) 
    {
      controller.populateFields(income);
    } 
    else 
    {
      controller.clearFields();
    }

    return Scaffold
    (
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        // authController: authController,
        showBackButton: true,
        title: isEditing ? 'تعديل بيانات الدفعة' : 'تسجيل دفعة جديدة',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'تحديث العملية' : 'تفاصيل العملية المالية',
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
                   // قائمة إختيار المناسبة
                  Obx(
                    // قائمة إختيار المناسبة
                    (){
                      if(event != null)
                      {
                        controller.eventIdRx.value = event.id;
                      //   return TextFormField(
                      //     readOnly: true,
                      //     initialValue: event.nameEvent,                          
                      //   );
                      }
                      return DropdownButtonFormField<int>(
                        initialValue: event != null? event.id : (controller.eventIdRx.value == 0? null : controller.eventIdRx.value),
                        decoration: AppFormWidgets.fieldDecoration('المناسبة المرتبطة', Icons.event_rounded, context),
                        items: eventCtrl.events.where((e) => (event!= null && e.id == event.id) || (event == null && true))
                            .map((e) => DropdownMenuItem(
                                  value: event!= null? event.id : e.id,
                                  child: Text(event!= null? event.eventName : e.eventName),
                                ))
                            .toList(),
                        onChanged: (val) =>  controller.eventIdRx.value = (event != null? event.id : (val ?? 0)),
                      );
                    }
                  ),
                  const SizedBox(height: 20),
                  
                   // حقل المبلغ
                  TextFormField(
                    initialValue: isEditing ? income.amount.toString() : null,
                    onChanged: (val) => controller.amountRx.value = double.tryParse(val) ?? 0.0,
                    keyboardType: TextInputType.number,
                    decoration: AppFormWidgets.fieldDecoration('المبلغ (ر.ي)', Icons.attach_money_rounded, context),
                  ),
                  const SizedBox(height: 20),

                  // قائمة إختيار طريقة الدفع
                  _buildPaymentMethodDropdown(context, income),
                  const SizedBox(height: 20),

                  // حقل التاريخ
                  _buildDatePicker(context),
                  const SizedBox(height: 20),

                  // حقل الملاحظات
                  TextFormField(
                    initialValue: isEditing ? income.description : null,
                    onChanged: (val) => controller.descriptionRx.value = val,
                    maxLines: 2,
                    decoration: AppFormWidgets.fieldDecoration('ملاحظات / وصف', Icons.description_rounded, context),
                  ),
                  const SizedBox(height: 20),
                  
                  Obx(
                    () => controller.incomeImage.value == null && controller.urlImageRx.value.isEmpty
                        ? SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.pickImage,
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text('إرفاق صورة الإيصال'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          )
                        : Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.getByBrightness(brightness)),
                              image: DecorationImage(
                                image: controller.incomeImage.value != null
                                    ? FileImage(controller.incomeImage.value!) as ImageProvider
                                    : NetworkImage(controller.urlImageRx.value),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 28),
                                style: IconButton.styleFrom(backgroundColor: AppColors.black54),
                                onPressed: () {
                                  controller.incomeImage.value = null;
                                  controller.urlImageRx.value = '';
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Obx(
              () => GradientButton(
                text: isEditing ? 'حفظ التغييرات' : 'تسجيل العملية',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (controller.amountRx.value <= 0) {
                     Get.snackbar(
                      'تنبيه',
                      'يرجى إدخال مبلغ صحيح أكبر من الصفر',
                      backgroundColor: AppColors.accent.getByBrightness(brightness).withValues(alpha: 0.1),
                      colorText: AppColors.accent.getByBrightness(brightness),
                      icon: Icon(Icons.warning_amber_rounded, color: AppColors.accent.getByBrightness(brightness)),
                    );
                    return;
                  }
                  if (isEditing) {
                    controller.updateIncome(income.id);
                  } else {
                    controller.createIncome();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodDropdown(BuildContext context, Income? income) {
    return Obx((){
      // ignore: unused_local_variable
      final isLoading = controller.isLoading.value;
      return DropdownButtonFormField<String>(
        initialValue: income != null ? (income.paymentMethod ?? 'نقداً') : 
         ( controller.paymentMethodRx.value.isNotEmpty ? controller.paymentMethodRx.value : 'نقداً'),
        decoration: AppFormWidgets.fieldDecoration('طريقة الدفع', Icons.payments_rounded, context),
        items: ['نقداً', 'تحويل بنكي', 'بطاقة مدى', 'أخرى']
            .map((method) => DropdownMenuItem(value: method, child: Text(method)))
            .toList(),
        onChanged: (val) => controller.paymentMethodRx.value = val ?? 'نقداً',
      );
    });
  }

  Widget _buildDatePicker(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: controller.paymentDateRx.value,
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          controller.paymentDateRx.value = date;
        }
      },
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: AppFormWidgets.dateDecoration(context),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary.getByBrightness(brightness),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تاريخ الدفع',
                    style: TextStyle(
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd', 'ar').format(controller.paymentDateRx.value),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textBody.getByBrightness(brightness),
                    ),
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
