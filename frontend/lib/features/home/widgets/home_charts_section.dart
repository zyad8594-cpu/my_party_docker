import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart' show PieChart, PieChartData, PieChartSectionData;
import '../../../core/utils/status.dart' show StringStatusExtension, StatusExtension;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../controller/home_controller.dart' show HomeController;

class HomeChartsSection extends GetView<HomeController> 
{
  final String title;
  final bool isTasks;
  final List<Map<String, dynamic>> sections;
  const HomeChartsSection(this.title, {super.key, this.sections = const [], required this.isTasks});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDesktop = Get.width > 900;

    if (!isDesktop) {
      return Column(
        children: [
          // TweenAnimationBuilder<double>(
          //   tween: Tween<double>(begin: 0.0, end: 1.0),
          //   duration: const Duration(milliseconds: 900),
          //   curve: Curves.easeOutCubic,
          //   builder: (context, val, child) => Opacity(
          //     opacity: val,
          //     child: Transform.translate(
          //         offset: Offset(0, 30 * (1 - val)), child: child),
          //   ),
          //   child: _buildBarChart(brightness),
          // ),
          // const SizedBox(height: 24),
          
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) => Opacity(
              opacity: val,
              child: Transform.translate(
                  offset: Offset(0, 30 * (1 - val)), child: child),
            ),
            child: _buildPieChart(brightness),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expanded(
        //   flex: 2,
        //   child: TweenAnimationBuilder<double>(
        //     tween: Tween<double>(begin: 0.0, end: 1.0),
        //     duration: const Duration(milliseconds: 900),
        //     curve: Curves.easeOutCubic,
        //     builder: (context, val, child) => Opacity(
        //       opacity: val,
        //       child: Transform.translate(
        //           offset: Offset(0, 30 * (1 - val)), child: child),
        //     ),
        //     child: _buildBarChart(brightness),
        //   ),
        // ),
        // const SizedBox(width: 24),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) => Opacity(
              opacity: val,
              child: Transform.translate(
                  offset: Offset(0, 30 * (1 - val)), child: child),
            ),
            child: _buildPieChart(brightness),
          ),
        ),
      ],
    );
  }

  // Widget _buildBarChart(Brightness brightness) {
  //   return Container(
  //     height: 350,
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: AppColors.surface.getByBrightness(brightness),
  //       borderRadius: BorderRadius.circular(32),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'الدخل الشهري',
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //         ),
  //         const SizedBox(height: 32),
  //         Expanded(
  //           child: BarChart(
  //             BarChartData(
  //               borderData: FlBorderData(show: false),
  //               gridData: const FlGridData(show: false),
  //               titlesData: FlTitlesData(
  //                 bottomTitles: AxisTitles(
  //                   sideTitles: SideTitles(
  //                     showTitles: true,
  //                     getTitlesWidget: (value, meta) {
  //                       const months = [
  //                         'Jan',
  //                         'Feb',
  //                         'Mar',
  //                         'Apr',
  //                         'May',
  //                         'Jun',
  //                       ];
  //                       if (value.toInt() < months.length) {
  //                         return Padding(
  //                           padding: const EdgeInsets.only(top: 8.0),
  //                           child: Text(
  //                             months[value.toInt()],
  //                             style: const TextStyle(fontSize: 10),
  //                           ),
  //                         );
  //                       }
  //                       return const Text('');
  //                     },
  //                   ),
  //                 ),
  //                 leftTitles: const AxisTitles(
  //                   sideTitles: SideTitles(showTitles: false),
  //                 ),
  //                 topTitles: const AxisTitles(
  //                   sideTitles: SideTitles(showTitles: false),
  //                 ),
  //                 rightTitles: const AxisTitles(
  //                   sideTitles: SideTitles(showTitles: false),
  //                 ),
  //               ),
  //               barGroups: [
  //                 _makeGroupData(0, 15, brightness),
  //                 _makeGroupData(1, 28, brightness),
  //                 _makeGroupData(2, 22, brightness),
  //                 _makeGroupData(3, 35, brightness),
  //                 _makeGroupData(4, 42, brightness),
  //                 _makeGroupData(5, 30, brightness),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // BarChartGroupData _makeGroupData(int x, double y, Brightness brightness) {
  //   return BarChartGroupData(
  //     x: x,
  //     barRods: [
  //       BarChartRodData(
  //         toY: y,
  //         gradient: AppColors.primaryGradient.getByBrightness(brightness),
  //         width: 16,
  //         borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
  //       ),
  //     ],
  //   );
  // }
  List<List<T>> _split<T>(List<T> list, int count)
  {
    List<List<T>> result = [];
    for (int i = 0; i < list.length; i += count) {
      result.add(list.sublist(i, (i + count).clamp(0, list.length)));
    }
    return result;
  }
  Widget _buildPieChart(Brightness brightness) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Obx((){
              // ignore: unused_local_variable
              final v = controller.isLoading.value;
              return PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: sections.map((se)=> PieChartSectionData(
                    color: se['color'],
                    value: controller.getPercentage(se['title'], isTasks: isTasks),
                    title: "${controller.getPercentage(se['title'], isTasks: isTasks).toStringAsFixed(2)}%",
                    radius: 50,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                  )).toList(),
                ),
              );
            }),
          ),
          ..._split(sections, 2).map((se)=> Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: se.map((it) => _buildLegendItem("${it['title']}".toUpperCase().status().tryText(), it['color'], brightness)).toList()
          )),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     _buildLegendItem('قيد المراجعة', AppColors.warning.getByBrightness(brightness), brightness),
          //     _buildLegendItem('قيد التنفيذ', AppColors.info.getByBrightness(brightness), brightness),
          //   ],
          // ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     _buildLegendItem('ملغية', AppColors.accent.getByBrightness(brightness), brightness),
          //     _buildLegendItem('مرفوضة', AppColors.accent.getByBrightness(brightness), brightness),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSubtitle.getByBrightness(brightness)),
          ),
        ],
      ),
    );
  }
}
