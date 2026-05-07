import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;

class TaskFormWidgets {
  static InputDecoration fieldDecoration(String label, IconData icon, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary.getByBrightness(brightness), size: 20),
      // Theme handles the rest (rounded corners, fill color, etc.)
    );
  }
}

class AssignmentTypeToggle extends StatelessWidget {
  final String title;
  final String type;
  final RxString groupValue;

  const AssignmentTypeToggle({
    super.key,
    required this.title,
    required this.type,
    required this.groupValue,
  });

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return Expanded(
      child: GestureDetector(
        onTap: () => groupValue.value = type,
        child: Obx(() {
          final isSelected = groupValue.value == type;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.getByBrightness(brightness): AppColors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? AppColors.primary.getByBrightness(brightness) : AppColors.textSubtitle.getByBrightness(brightness),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TaskDatePicker extends StatelessWidget {
  final String label;
  final Rx<DateTime> date;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const TaskDatePicker({
    super.key, 
    required this.label, 
    required this.date,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: Get.context!,
          initialDate: (date.value.isAfter(firstDate ?? DateTime(2000)) && date.value.isBefore(lastDate ?? DateTime(2100))) 
              ? date.value 
              : (firstDate ?? DateTime.now()),
          firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365)),
          lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (d != null) date.value = d;
      },
      child: Obx(
        () => Container(
          padding: const EdgeInsets.all(16),
          decoration: AppFormWidgets.dateDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSubtitle.getByBrightness(brightness),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('yyyy/MM/dd').format(date.value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class EventTaskInfoTile extends StatelessWidget {
  final String eventName;

  const EventTaskInfoTile({super.key, required this.eventName});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary.getByBrightness(brightness)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إضافة مهمة لـ:',
                style: TextStyle(fontSize: 12, color: AppColors.textSubtitle.getByBrightness(brightness)),
              ),
              Text(
                eventName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary.getByBrightness(brightness),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
