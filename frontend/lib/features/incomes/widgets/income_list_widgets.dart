import 'package:flutter/material.dart';
import '../data/models/income.dart' show Income;
import '../../../core/themes/app_colors.dart' show AppColors;

class IncomeListWidgets 
{
  static Widget balanceChangeInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.white, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.white, fontSize: 11)),
      ],
    );
  }

  static Widget overviewCard(
    String title,
    String value,
    Color color,
    Color bg,
    IconData icon,
    BuildContext context,
  ) {
    final brightness = Theme.of(context).brightness;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textBody.getByBrightness(brightness),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class IncomeTotalBalanceHeader extends StatelessWidget {
  const IncomeTotalBalanceHeader({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجمالي الرصيد',
            style: TextStyle(
              color: AppColors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '45,000.00 ر.س',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IncomeListWidgets.balanceChangeInfo(
                Icons.arrow_upward_rounded,
                '12% + زيادة من الشهر الماضي',
              ),
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.white30,
                size: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IncomeFinancialOverview extends StatelessWidget {
  const IncomeFinancialOverview({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    return Row(
      children: [
        Expanded(
          child: IncomeListWidgets.overviewCard(
            'مدخلات',
            '25,000 ر.س',
            AppColors.success.getByBrightness(brightness),
            AppColors.successStatusBg.getByBrightness(brightness),
            Icons.trending_up_rounded,
            context,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: IncomeListWidgets.overviewCard(
            'مدفوعات',
            '10,500 ر.س',
            AppColors.accent.getByBrightness(brightness),
            AppColors.dangerStatusBg.getByBrightness(brightness),
            Icons.trending_down_rounded,
            context,
          ),
        ),
      ],
    );
  }
}

class IncomeTransactionsHeader extends StatelessWidget {
  const IncomeTransactionsHeader({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'آخر المعاملات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textBody.getByBrightness(brightness),
          ),
        ),
        Text(
          'عرض الكل',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primary.getByBrightness(brightness),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class IncomeTransactionItem extends StatelessWidget {
  final Income income;

  const IncomeTransactionItem({super.key, required this.income});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    final bool isPositive = income.amount >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.successStatusBg.getByBrightness(brightness)
                  : AppColors.dangerStatusBg.getByBrightness(brightness),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.add_rounded : Icons.remove_rounded,
              color: isPositive ? AppColors.success.getByBrightness(brightness) : AppColors.accent.getByBrightness(brightness),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.description ?? income.eventName ?? 'معاملة مالية',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBody.getByBrightness(brightness),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  income.paymentDate,
                  style: TextStyle(
                    color: AppColors.textSubtitle.getByBrightness(brightness),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? "+" : ""}${income.amount} ر.س',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.success.getByBrightness(brightness) : AppColors.accent.getByBrightness(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class IncomeEmptyState extends StatelessWidget {
  const IncomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد معاملات بعد',
              style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
