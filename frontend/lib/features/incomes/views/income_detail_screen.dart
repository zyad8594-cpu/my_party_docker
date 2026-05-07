import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/app_image.dart';
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/glass_card.dart' show GlassCard;
import '../controller/income_controller.dart' show IncomeController;
import '../data/models/income.dart' show Income;

class IncomeDetailScreen extends GetView<IncomeController> {
  const IncomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final Income income = Get.arguments as Income;
final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'تفاصيل التقرير المالي',
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchIncomes,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(context, Icons.event_rounded, 'المناسبة', income.eventName ?? 'غير محدد'),
                    const Divider(height: 32),
                    _buildDetailRow(context, Icons.attach_money_rounded, 'المبلغ', '${income.amount.toStringAsFixed(2)} ر.ي', isHighlight: true),
                    const Divider(height: 32),
                    _buildDetailRow(context, Icons.payments_rounded, 'طريقة الدفع', income.paymentMethod ?? 'غير محدد'),
                    const Divider(height: 32),
                    _buildDetailRow(
                      context,
                      Icons.calendar_today_rounded,
                      'التاريخ',
                      DateFormat('yyyy/MM/dd', 'ar').format(DateTime.tryParse(income.paymentDate) ?? DateTime.now()),
                    ),
                    if (income.description != null && income.description!.isNotEmpty) ...[
                      const Divider(height: 32),
                      _buildDetailRow(context, Icons.description_rounded, 'ملاحظات', income.description!),
                    ],
                  ],
                ),
              ),
              if (income.urlImage != null && income.urlImage!.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  'صورة الإيصال / السند',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBody.getByBrightness(brightness),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppImage.network(
                    income.urlImage!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    viewerTitle: 'إيصال: ${income.eventName}',
                    fallbackWidget: Container(
                      height: 200,
                      width: double.infinity,
                      color: AppColors.surface.getByBrightness(brightness),
                      child: Center(
                        child: Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textSubtitle.getByBrightness(brightness)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {bool isHighlight = false}) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isHighlight ? AppColors.success : AppColors.primary).getByBrightness(brightness).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: (isHighlight ? AppColors.success : AppColors.primary).getByBrightness(brightness),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSubtitle.getByBrightness(brightness),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isHighlight ? AppColors.success.getByBrightness(brightness) : AppColors.textBody.getByBrightness(brightness),
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
