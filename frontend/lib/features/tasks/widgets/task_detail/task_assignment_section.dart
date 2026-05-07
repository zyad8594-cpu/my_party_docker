import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/status.dart';
import '../../data/models/task.dart';
import '../../../../core/components/app_image.dart';
import '../../../../core/components/widgets/app_detail_widgets.dart';

class TaskAssignmentSection extends StatelessWidget {
  final Task task;
  final String? assignedName;
  final String? assignedPhone;
  final String? assignedEmail;
  final String? assignedImageUrl;
  final String? assignedRoleTitle;

  const TaskAssignmentSection({
    super.key,
    required this.task,
    this.assignedName,
    this.assignedPhone,
    this.assignedEmail,
    this.assignedImageUrl,
    this.assignedRoleTitle,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final statusColor = task.status.color(brightness);

    return AppDetailWidgets.buildInfoCard(
      context,
      title: 'تفاصيل المهمة والمسؤول',
      icon: Icons.assignment_ind_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.design_services_rounded,
                  color: AppColors.primary.getByBrightness(brightness),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.typeTask ?? 'مهمة عامة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBody.getByBrightness(brightness),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(task.status.tryText(), statusColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildCompactDetail(
                  context,
                  Icons.attach_money_rounded,
                  'التكلفة الكلية',
                  '${task.totalCost} ر.ي',
                ),
              ),
            ],
          ),
          if (task.adjustmentType != 'NONE') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  task.adjustmentType == 'INCREASE' ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 14,
                  color: (task.adjustmentType == 'INCREASE' ? AppColors.success : AppColors.accent).getByBrightness(brightness),
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.adjustmentType == 'INCREASE' ? '+' : '-'} ${task.adjustmentAmount} ر.ي ${task.adjustmentType == 'INCREASE' ? '(زيادة)' : '(نقصان)'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: (task.adjustmentType == 'INCREASE' ? AppColors.success : AppColors.accent).getByBrightness(brightness),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildCompactDetail(
                  context,
                  Icons.calendar_today_rounded,
                  'البداية',
                  DateFormatter.format(task.dateStart),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCompactDetail(
            context,
            Icons.calendar_month_rounded,
            'موعد الاستحقاق النهائي',
            DateFormatter.format(task.dateDue),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),

          Text(
            'الوصف',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary.getByBrightness(brightness),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            task.description ?? 'لا يوجد وصف متاح.',
            style: TextStyle(
              color: AppColors.textBody.getByBrightness(brightness),
              fontSize: 14,
              height: 1.5,
            ),
          ),
         
          if (assignedName != null) ...[
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            Text(
              'المسؤول عن التنفيذ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: AppImage.network(
                      assignedImageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      viewerTitle: assignedName,
                      fallbackWidget: Icon(Icons.person, color: AppColors.primary.getByBrightness(brightness), size: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignedName!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBody.getByBrightness(brightness),
                        ),
                      ),
                      Text(
                        assignedRoleTitle ?? 'جهة اتصال',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (assignedPhone != null && assignedPhone!.isNotEmpty)
              _buildContactRow(context, Icons.phone_android_rounded, 'الهاتف', assignedPhone!),
            if (assignedEmail != null && assignedEmail!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildContactRow(context, Icons.email_outlined, 'البريد الإلكتروني', assignedEmail!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompactDetail(BuildContext context, IconData icon, String label, String value) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSubtitle.getByBrightness(brightness)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSubtitle.getByBrightness(brightness),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textBody.getByBrightness(brightness),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String label, String value) {
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary.getByBrightness(brightness)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSubtitle.getByBrightness(brightness),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textBody.getByBrightness(brightness),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
