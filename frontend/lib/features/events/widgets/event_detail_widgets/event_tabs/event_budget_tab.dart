import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/utils/status.dart';
import '../../../../../core/components/widgets/search_box_widget.dart';
import '../../../../tasks/controller/task_controller.dart';
import '../../../controller/event_controller.dart';
import '../../../data/models/event.dart' show Event;
import '../../../../incomes/controller/income_controller.dart' show IncomeController;
import '../../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../../../../core/components/glass_card.dart' show GlassCard;
import '../../../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../../../../coordinators/controller/coordinator_controller.dart' show CoordinatorController;
import '../../../../tasks/data/models/task.dart' show Task;
import '../../../../../core/components/app_image.dart';
// import '../../../../../core/components/empty_state_widget.dart' show EmptyStateWidget;
import '../../../../../core/components/image_viewer_screen.dart';
import '../../../../../core/components/widgets/myp_list_view_widget.dart' show MyPListView;
import '../../../../../core/components/widgets/loading_widget.dart' show LoadingWidget;

class EventBudgetTab extends StatelessWidget 
{
  final Event event;

  const EventBudgetTab({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) 
  {
    final incomeController = Get.find<IncomeController>();
    final controller = Get.find<EventController>();
    final taskController = Get.find<TaskController>();
    final brightness = Theme.of(context).brightness;

    return Obx(() {
      final eventIncomes = incomeController.incomes.where((i) => i.eventId == event.id).toList();
      final eventTasks = taskController.tasks.where((t) => t.eventId == event.id).toList();

      final totalPaid = eventIncomes.fold(0.0, (sum, i) => sum + (i.amount));
      final totalExpenses = eventTasks.fold(0.0, (sum, t) => sum + (t.cost));
      final balance = event.budget - totalPaid;

      return MyPListView.builder<dynamic>(
        context,
        isLoading: false.obs, 
        onRefresh: () async{
          await incomeController.fetchIncomes(force: true);
          await taskController.fetchTasks(force: true);
        },
        loadingWidget: () => const LoadingWidget(),
        emptyWidget: () => const SizedBox.shrink(),
        filters: () => controller.selectedFilterBudget.value == 'الدفعات' ? eventIncomes : eventTasks,
        scrollController: controller.scrollController,
        padding: const EdgeInsets.all(20),
        header: Column(
          children: [
            _buildFinancialSummary(event.budget, totalExpenses, totalPaid, balance, context),
            const SizedBox(height: 24),
            SearchBox.filters(
              context, 
              filtersNames: ['الدفعات', 'المصروفات'],
              initSelect: controller.selectedFilterBudget,
              onSelected: (s, value) {
                controller.selectedFilterBudget.value = value;
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل ${controller.selectedFilterBudget.value}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBody.getByBrightness(brightness),
                  ),
                ),
                
                if(controller.selectedFilterBudget.value == 'الدفعات' && [Status.PENDING, Status.IN_PROGRESS].contains(event.status)) TextButton.icon(
                  onPressed: (){
                    Get.toNamed(AppRoutes.incomeAdd, arguments: event);
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('إضافة دفعة'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textBody.getByBrightness(brightness),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
        itemBuilder: (context, index, item) {
          if (item is Task && item.cost <= 0) return const SizedBox.shrink();
          return Column(
            children: [
              _buildItem(item, context),
              const SizedBox(height: 12),
            ],
          );
        },
      );
    });
  }
  
  Widget _buildFinancialSummary(double budget, double totalExpenses, double paid, double balance, BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppFormWidgets.cardDecoration(context),
      child: Column(
        children: [
          _summaryRow('إجمالي الميزانية', budget, AppColors.textBody.getByBrightness(brightness), context),
          _summaryRow('إجمالي المصروفات', totalExpenses, AppColors.textBody.getByBrightness(brightness), context),
          const Divider(height: 32),

          _summaryRow('المبلغ المدفوع', paid, AppColors.success.getByBrightness(brightness), context),
          const SizedBox(height: 16),
          _summaryRow('المتبقي', balance <= 0 ? 0 : balance,
            (balance > 0 ? AppColors.warning : AppColors.success).getByBrightness(brightness),
            context,
          ),
          
          if(balance < 0 ) ...[const SizedBox(height: 16),
            _summaryRow('الزيادة', -balance,
            AppColors.warning.getByBrightness(brightness),
            context,
          )],

          if(budget - totalExpenses < 0)...[const SizedBox(height: 16),
          _summaryRow('العجز', totalExpenses - budget,
            AppColors.warning.getByBrightness(brightness),
            context,
          )],

          
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, Color color, BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSubtitle.getByBrightness(brightness),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ر.ي',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildItem<T extends dynamic>(T item, BuildContext context) 
  {
    final controller = Get.find<EventController>();
    final brightness = Theme.of(context).brightness;

    // final description = (controller.selectedFilterBudget.value == 'الدفعات' ? (item.description ?? 'دفعة مالية') : (item.typeTask ?? 'مهمة')) as String;
    // final amount = (controller.selectedFilterBudget.value == 'الدفعات' ? item.amount : item.cost) as double;
    final description = _getFiledValue<String>(item, 'description', 'دفعة مالية');
    final amount = _getFiledValue<double>(item, 'amount', 0);
    final date = _getFiledValue<String>(item, 'date', '');
    

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (controller.selectedFilterBudget.value == 'الدفعات' ? AppColors.success : AppColors.primary)
                      .getByBrightness(brightness)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  controller.selectedFilterBudget.value == 'الدفعات' ? Icons.payments_rounded : Icons.assignment_rounded,
                  color: (controller.selectedFilterBudget.value == 'الدفعات' ? AppColors.success : AppColors.primary)
                      .getByBrightness(brightness),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Main Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textBody.getByBrightness(brightness),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('yyyy/MM/dd', 'ar').format(DateTime.tryParse(date) ?? DateTime.now()),
                          style: TextStyle(
                            color: AppColors.textSubtitle.getByBrightness(brightness),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: (controller.selectedFilterBudget.value == 'الدفعات' ? AppColors.success : AppColors.primary)
                          .getByBrightness(brightness),
                    ),
                  ),
                  Text(
                    'ر.ي',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Section: Actions or Assignee
              if (controller.selectedFilterBudget.value == 'الدفعات')
                Row(
                  children: [
                    if (item.urlImage != null && (item.urlImage as String).isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Get.to(() => ImageViewerScreen(
                            imageUrl: item.urlImage!,
                            title: 'إيصال دفعة - ${item.amount}',
                          ));
                        },
                        child: Hero(
                          tag: 'payment_receipt_${item.id}',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.image_outlined, size: 16, color: AppColors.primary.getByBrightness(brightness)),
                                const SizedBox(width: 6),
                                Text(
                                  'عرض الإيصال',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary.getByBrightness(brightness),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),

                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: AppColors.blue,
                      onPressed: () => Get.toNamed(
                        AppRoutes.incomeAdd,
                        arguments: {'income': item, 'event': controller.selectedEvent.value},
                      ),
                    ),
                    const SizedBox(width: 8),

                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: AppColors.redAccent,
                      onPressed: () => _showDeleteDialog(context, item.id),
                    ),
                  ],
                )
              else
                _buildAssigneeInfo(item as Task, context),

              // Right Section: Details Link for Incomes
              if (controller.selectedFilterBudget.value == 'الدفعات')
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.incomeDetail, arguments: item),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'التفاصيل',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.getByBrightness(brightness),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary.getByBrightness(brightness)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      middleText: 'هل أنت متأكد من رغبتك في حذف هذه الدفعة؟',
      textConfirm: 'حذف',
      textCancel: 'تراجع',
      confirmTextColor: AppColors.white,
      buttonColor: AppColors.redAccent,
      onConfirm: () {
        final incomeController = Get.find<IncomeController>();
        incomeController.deleteIncome(id);
        Get.back();
      },
    );
  }

  Widget _buildAssigneeInfo(Task task, BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final supplierController = Get.isRegistered<SupplierController>() ? Get.find<SupplierController>() : null;
    final coordinatorController = Get.isRegistered<CoordinatorController>() ? Get.find<CoordinatorController>() : null;

    String? imageUrl;
    String? name = task.assigneName;
    String? email;

    if (task.assignmentType == 'supplier') {
      final supplier = supplierController?.suppliers.firstWhereOrNull((s) => s.id == task.userAssignId);
      if (supplier != null) {
        imageUrl = supplier.imgUrl;
        name = supplier.name;
        email = supplier.email;
      }
    } else if (task.assignmentType == 'coordinator') {
      final coordinator = coordinatorController?.coordinators.firstWhereOrNull((c) => c.id == task.userAssignId);
      if (coordinator != null) {
        imageUrl = coordinator.imgUrl;
        name = coordinator.name;
        email = coordinator.email;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: AppImage.network(
                    imageUrl,
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                    viewerTitle: name ?? 'صورة',
                    fallbackWidget: Icon(
                      task.assignmentType == 'supplier' ? Icons.storefront_rounded : Icons.person_rounded,
                      size: 20,
                      color: AppColors.primary.getByBrightness(brightness),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? 'غير مسند',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (email != null)
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSubtitle.getByBrightness(brightness),
                      ),
                    ),
                ],
              ),
             
            ],
          ),
        ],
      ),
    );
  }

  R _getFiledValue<R>(dynamic item, String filedName, R defaultValue) {
    final controller = Get.find<EventController>();
    try{
      if (controller.selectedFilterBudget.value == 'الدفعات') 
      {
        switch(filedName)
        {
          case 'description': return item.description as R;
          case 'amount': return item.amount as R;
          case 'date': return item.paymentDate  as R; 
        }
      } 
      else 
      {
        switch(filedName)
        {
          case 'description': return item.typeTask as R;
          case 'amount': return item.cost as R;
          case 'date': return item.dateStart  as R; 
        }
      }
    } catch(e){
      // Ignore conversion errors
    }
    return defaultValue;
  }
}
