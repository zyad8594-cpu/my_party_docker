import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/date_formatter.dart' show DateFormatter;
import '../../data/models/task.dart';
import '../../controller/task_controller.dart';
import '../../../../core/components/widgets/app_detail_widgets.dart';
import '../../../../core/utils/utils.dart' show MyPUtils;

class TaskEvaluationSection extends GetView<TaskController> {
  final Task task;
  final String role;

  TaskEvaluationSection({
    super.key,
    required this.task,
    required this.role,
  }) {
    _rating.value = task.rating ?? 0.0;
    if (task.ratingComment != null) {
      _commentController.text = task.ratingComment!;
    }
  }

  final _rating = 0.0.obs;
  final _commentController = TextEditingController();
  final _isEditing = false.obs;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isCoordinator = role.toLowerCase() == 'coordinator';
    
    return Obx(() {
      final hasEvaluated = task.rating != null && task.rating! > 0;
      
      if (!isCoordinator && !hasEvaluated) {
        return const SizedBox.shrink();
      }

      if (hasEvaluated && !_isEditing.value) {
        return _buildEvaluatedReadonlyCard(context, brightness, isCoordinator);
      }

      return AppDetailWidgets.buildInfoCard(
        context,
        title: 'تقييم الإنجاز',
        icon: Icons.star_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.background.getByBrightness(brightness).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Obx(() => GestureDetector(
                        onTap: () => _rating.value = index + 1.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < _rating.value ? Icons.star_rounded : Icons.star_border_rounded,
                            color: index < _rating.value ? AppColors.amber : AppColors.grey.shade400,
                            size: 40,
                          ),
                        ),
                      ));
                }),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'أضف انطباعك عن أداء المورد (إختياري)...',
                hintStyle: TextStyle(color: AppColors.textBody.getByBrightness(brightness).withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.background.getByBrightness(brightness).withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.primary.getByBrightness(brightness)),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_rating.value == 0) {
                     MyPUtils.showSnackbar('تنبيه', 'يرجى اختيار عدد النجوم للتقييم', position: SnackPosition.BOTTOM);
                     return;
                  }
                  controller.rateTask(
                    task.id,
                    _rating.toInt(),
                    _commentController.text,
                  ).then((_) => _isEditing.value = false);
                },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('اعتماد التقييم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.getByBrightness(brightness),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),

            if (_isEditing.value) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _isEditing.value = false,
                child: const Text('إلغاء التعديل', style: TextStyle(color: AppColors.red)),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildEvaluatedReadonlyCard(BuildContext context, Brightness brightness, bool isCoordinator) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface.getByBrightness(brightness),
            AppColors.background.getByBrightness(brightness),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: AppColors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),

                  Text(
                    'التقييم المعتمد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBasec.getByBrightness(brightness),
                    ),
                  ),
                ],
              ),

              if (isCoordinator) IconButton(
                onPressed: () => _isEditing.value = true,
                icon: Icon(Icons.edit_note_rounded, color: AppColors.primary.getByBrightness(brightness)),
                tooltip: 'تعديل التقييم',
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'مُكتمل',
                  style: TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < (task.rating ?? 0) ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.amber,
                size: 28,
              );
            }),
          ),

          if (task.ratingComment != null && task.ratingComment!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task.ratingComment!,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textBody.getByBrightness(brightness),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

          if (task.ratedAt != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'تاريخ التقييم: ${DateFormatter.format(task.ratedAt)}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSubtitle.getByBrightness(brightness),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
