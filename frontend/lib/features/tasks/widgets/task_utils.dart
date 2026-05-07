import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';

void showRejectTaskBottomSheet(BuildContext context, dynamic controller, int taskId, Brightness brightness) {
  final noteController = TextEditingController();
  
  
  Get.bottomSheet(
    Container(
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
            Text('سبب رفض المهمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBody.getByBrightness(brightness))),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظات الرفض (إختياري)...',
                hintStyle: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
                filled: true,
                fillColor: AppColors.background.getByBrightness(brightness),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent.getByBrightness(brightness),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final result = await controller.updateTaskStatus(taskId, 'REJECTED', note: noteController.text);
                            if (result != false) {
                              if (Get.isBottomSheetOpen ?? false) Get.back();
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : const Text('تأكيد الرفض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  )),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
