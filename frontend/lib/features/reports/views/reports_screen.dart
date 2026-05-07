import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../controller/reports_controller.dart' show ReportsController;
import '../../../core/themes/app_colors.dart' show AppColors;

import 'tabs/events_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/suppliers_tab.dart';
import 'tabs/financial_tab.dart';

class ReportsScreen extends GetView<ReportsController> {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background.getByBrightness(brightness),
        appBar: CustomAppBar(
          title: 'التقارير والتحليلات',
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary.getByBrightness(brightness),
            labelColor: AppColors.primary.getByBrightness(brightness),
            unselectedLabelColor: AppColors.grey,
            tabs: const [
              Tab(text: 'المناسبات', icon: Icon(Icons.event_note)),
              Tab(text: 'المهام', icon: Icon(Icons.task_alt)),
              Tab(text: 'الموردين', icon: Icon(Icons.people_outline)),
              Tab(text: 'المالية', icon: Icon(Icons.account_balance_wallet_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(onRefresh: controller.refreshStatistics, child: const EventsTab()),
            RefreshIndicator(onRefresh: controller.refreshStatistics, child: const TasksTab()),
            RefreshIndicator(onRefresh: controller.refreshStatistics, child: const SuppliersTab()),
            RefreshIndicator(onRefresh: controller.refreshStatistics, child: const FinancialTab()),
          ],
        ),
      ),
    );
  }
}
