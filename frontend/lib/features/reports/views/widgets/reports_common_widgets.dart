import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/themes/app_colors.dart' show AppColors;

class ReportsCommonWidgets {
  static Widget buildSearchAndFilter(BuildContext context, RxString searchQuery, VoidCallback onExport, VoidCallback onCollapse) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'بحث...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface.getByBrightness(brightness),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.unfold_less_rounded),
            onPressed: onCollapse,
            color: AppColors.grey,
            tooltip: 'إغلاق الكل',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: onExport,
            color: AppColors.red,
            tooltip: 'تصدير PDF',
          ),
        ],
      ),
    );
  }

  static Widget buildStatHeader(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: children.map((w) => SizedBox(width: Get.width * 0.44, child: w)).toList(),
      ),
    );
  }

  static Widget buildSmallInfo(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
      ],
    );
  }

  static Widget buildDetailedRow(String label, String count, String cost, {Color? color, bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
      decoration: BoxDecoration(
        color: isHeader ? AppColors.primary.dark : null,
        borderRadius: isHeader ? const BorderRadius.vertical(top: Radius.circular(12)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 3, child: Text(label, style: TextStyle(color: color, fontWeight: isHeader || color != null ? FontWeight.bold : FontWeight.normal, fontSize: isHeader ? 13 : 12))),
          Expanded(flex: 2, child: Center(child: Text(isHeader ? count : '$count مهام', style: TextStyle(fontSize: 12, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)))),
          Expanded(flex: 3, child: Align(alignment: Alignment.centerLeft, child: Text(cost, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
        ],
      ),
    );
  }

  static Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: AppColors.blue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
