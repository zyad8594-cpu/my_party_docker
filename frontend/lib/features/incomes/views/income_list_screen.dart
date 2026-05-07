import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../controller/income_controller.dart' show IncomeController;
import '../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../widgets/income_list_widgets.dart' show IncomeEmptyState, IncomeFinancialOverview, IncomeTotalBalanceHeader, IncomeTransactionItem, IncomeTransactionsHeader;

class IncomeListScreen extends GetView<IncomeController> 
{
  IncomeListScreen({super.key});
final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        // authController: authController,
        title: 'إدارة الدخل',
        beforeActions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.filter_list_rounded,
              color: AppColors.textSubtitle.getByBrightness(brightness),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchIncomes(force: true),
        child: Obx(() {
          if (controller.isLoading.value && controller.incomes.isEmpty) {
            return const LoadingWidget();
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const IncomeTotalBalanceHeader(),
              const SizedBox(height: 24),
              const IncomeFinancialOverview(),
              const SizedBox(height: 32),
              const IncomeTransactionsHeader(),
              const SizedBox(height: 16),
              if (controller.incomes.isEmpty)
                const IncomeEmptyState()
              else
                ...controller.incomes.map(
                  (income) => IncomeTransactionItem(income: income),
                ),
              const SizedBox(height: 100),
            ],
          );
        }),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient.getByBrightness(brightness),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'add_income',
          onPressed: () => Get.toNamed(AppRoutes.incomeAdd),
          backgroundColor: AppColors.transparent,
          elevation: 0,
          child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.white, size: 30),
        ),
      ),
    );
  }
}
