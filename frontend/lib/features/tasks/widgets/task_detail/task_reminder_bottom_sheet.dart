import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../data/models/task.dart';
import '../../controller/task_controller.dart';

import '../../../../core/utils/utils.dart' show MyPUtils;

void showTaskReminderBottomSheet(BuildContext context, Task task, TaskController controller) {
  final brightness = Theme.of(context).brightness;

  final allowedTypes = ['BEFORE_DUE', 'INTERVAL', 'none'];
  final allowedUnits = ['MINUTE', 'HOUR', 'DAY', 'WEEK'];

  String selectedType = allowedTypes.contains(task.reminderType) ? task.reminderType! : 'none';
  TextEditingController valueController = TextEditingController(text: task.reminderValue?.toString());
  String selectedUnit = allowedUnits.contains(task.reminderUnit) ? task.reminderUnit! : 'DAY';

  Get.bottomSheet(
    StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Container(
        padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: BoxDecoration(
          color: AppColors.surface.getByBrightness(brightness),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.notifications_active_rounded, size: 48, color: AppColors.primary.getByBrightness(brightness)),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('إعداد تذكير للمهمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))),
              ),
              const SizedBox(height: 24),
              Text('نوع التذكير', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background.getByBrightness(brightness),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: AppColors.surface.getByBrightness(brightness),
                    value: selectedType,
                    isExpanded: true,
                    style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue ?? 'none';
                      });
                    },
                    items: allowedTypes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(switch (value) {
                          'BEFORE_DUE' => 'قبل تاريخ التسليم',
                          'INTERVAL' => 'تذكير متكرر',
                          _ => 'بدون تذكير',
                        }),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('القيمة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))),
                        const SizedBox(height: 8),
                        TextField(
                          controller: valueController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
                          decoration: InputDecoration(
                            hintText: 'مثال: 15',
                            hintStyle: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
                            filled: true,
                            fillColor: AppColors.background.getByBrightness(brightness),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الوحدة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background.getByBrightness(brightness),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: AppColors.surface.getByBrightness(brightness),
                              value: selectedUnit,
                              isExpanded: true,
                              style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedUnit = newValue ?? 'DAY';
                                });
                              },
                              items: allowedUnits.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(switch (value) {
                                    'MINUTE' => 'دقيقة',
                                    'HOUR' => 'ساعة',
                                    'DAY' => 'يوم',
                                    _ => 'أسبوع'
                                  }),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.getByBrightness(brightness),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final val = int.tryParse(valueController.text);
                    if (selectedType != 'none' && (val == null || val <= 0)) {
                      MyPUtils.showSnackbar('تنبيه', 'يرجى إدخال قيمة صحيحة للاستمرار أو اختيار بدون تذكير', position: SnackPosition.BOTTOM);
                      return;
                    }
                    
                    if (task.reminderType != null && task.reminderType != 'none') {
                      await controller.updateTaskReminder(task.id, selectedType, val ?? 0, selectedUnit);
                    } else {
                      await controller.addTaskReminder(task.id, selectedType, val ?? 0, selectedUnit);
                    }
                    if (Get.isBottomSheetOpen ?? false) Get.back();
                  },
                  child: Obx(() => controller.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                      : Text((task.reminderType != null && task.reminderType != 'none') ? 'تحديث التذكير' : 'إنشاء التذكير', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ),
              ),
            ],
          ),
        ),
      );
    }),
    isScrollControlled: true,
  );
}

void confirmDeleteReminder(BuildContext context, Task task, TaskController controller) {
  Get.defaultDialog(
    title: 'تأكيد الحذف',
    middleText: 'هل أنت متأكد من رغبتك في حذف هذا التذكير؟',
    textConfirm: 'نعم، حذف',
    textCancel: 'تراجع',
    confirmTextColor: AppColors.white,
    onConfirm: () {
      Get.back();
      controller.deleteTaskReminder(task.id);
    },
  );
}
