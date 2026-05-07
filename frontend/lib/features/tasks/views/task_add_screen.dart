import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../services/data/models/service.dart' show Service;
import '../../suppliers/data/models/supplier.dart' show Supplier;
import '../controller/task_controller.dart' show TaskController;
import '../../events/controller/event_controller.dart' show EventController;
import '../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../../coordinators/controller/coordinator_controller.dart' show CoordinatorController;
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../../services/controller/service_controller.dart' show ServiceController;
import 'service_suppliers_screen.dart' show ServiceSuppliersScreen;
import '../data/models/task.dart' show Task;
import '../../events/data/models/event.dart' show Event;
import '../widgets/task_form_widgets.dart' show TaskDatePicker, EventTaskInfoTile;
import '../../../core/components/gradient_button.dart' show GradientButton;
import '../../../core/components/widgets/app_form_widgets.dart' show AppFormWidgets;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;

class TaskAddScreen extends StatefulWidget {
  const TaskAddScreen({super.key});

  @override
  State<TaskAddScreen> createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  late final TaskController controller;
  late final EventController eventCtrl;
  late final SupplierController supplierCtrl;
  late final CoordinatorController coordCtrl;
  late final AuthController authCtrl;
  late final ServiceController serviceCtrl;

  late final Task? task;
  late final Event? preSelectedEvent;
  late final bool isEditing;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TaskController>();
    eventCtrl = Get.find<EventController>();
    supplierCtrl = Get.find<SupplierController>();
    coordCtrl = Get.find<CoordinatorController>();
    authCtrl = Get.find<AuthController>();
    serviceCtrl = Get.find<ServiceController>();

    final arg = Get.arguments;
    task = arg is Task ? arg : null;
    preSelectedEvent = arg is Event ? arg : null;
    isEditing = task != null;

    if (isEditing) {
      controller.populateFields(task!);
    } else {
      controller.clearFields();
      if (preSelectedEvent != null) {
        controller.eventIdRx.value = preSelectedEvent!.id;
      } else if (eventCtrl.events.isNotEmpty) {
        controller.eventIdRx.value = eventCtrl.events.first.id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        showBackButton: true,
        title: isEditing ? 'تعديل المهمة' : 'إضافة مهمة جديدة',
      ),
      body: SelectionArea(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (preSelectedEvent != null) ...[
                        EventTaskInfoTile(eventName: preSelectedEvent!.eventName),
                        const SizedBox(height: 24),
                      ],
                      _buildSectionTitle(context, 'المعلومات الأساسية', Icons.info_outline_rounded),
                      const SizedBox(height: 12),
                      _buildGeneralInfoCard(context, preSelectedEvent, isEditing),
                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'إسناد المهمة', Icons.assignment_ind_outlined),
                      const SizedBox(height: 12),
                      _buildAssignmentCard(context, isEditing),
                      Obx(() {
                        final bool isMyself = controller.assignmentTypeRx.value == 'COORDINATOR';
                        final bool hasSupplier = controller.assigneeIdRx.value != null;
                        final bool showRest = isMyself || hasSupplier;

                        return AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutBack,
                          child: showRest
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 32),

                                    _buildSectionTitle(context, 'الجدولة والتكلفة', Icons.date_range_outlined),
                                    const SizedBox(height: 12),
                                    _buildScheduleAndCostCard(context, isEditing),
                                    const SizedBox(height: 32),

                                    _buildSectionTitle(context, 'إعداد التذكير', Icons.notifications_active_outlined),
                                    const SizedBox(height: 12),
                                    _buildReminderCard(context, isEditing),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, brightness, isEditing, task),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final brightness = Theme.of(context).brightness;
    final primary = AppColors.primary.getByBrightness(brightness);
    final textTheme = AppColors.textBody.getByBrightness(brightness);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textTheme,
          ),
        ),
      ],
    );
  }

  Widget _buildCardWrapper({required Widget child, required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppFormWidgets.cardDecoration(context),
      child: child,
    );
  }

  Widget _buildGeneralInfoCard(BuildContext context, Event? preSelectedEvent, bool isEditing) 
  {
    return _buildCardWrapper(
      context: context,
      child: Column(
        children: [
          if (preSelectedEvent == null) ...[
            Obx(
              () => DropdownButtonFormField<int>(
                initialValue: controller.eventIdRx.value == 0 ? null : controller.eventIdRx.value,
                decoration: AppFormWidgets.fieldDecoration('المناسبة', Icons.event_rounded, context),
                items: eventCtrl.events.map((e) => DropdownMenuItem(value: e.id, child: Text(e.eventName))).toList(),
                onChanged: isEditing ? null : (val) => controller.eventIdRx.value = val ?? 0,
              ),
            ),
            const SizedBox(height: 20),
          ],
          TextFormField(
            controller: controller.typeController,
            readOnly: isEditing,
            decoration: AppFormWidgets.fieldDecoration('عنوان المهمة', Icons.title_rounded, context),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.descriptionController,
            readOnly: isEditing,
            maxLines: 3,
            decoration: AppFormWidgets.fieldDecoration('الوصف التفصيلي', Icons.notes_rounded, context),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, bool isEditing)
  {
    return _buildCardWrapper(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final flow = controller.assignmentTypeRx.value;
            return DropdownButtonFormField<String>(
              initialValue: (flow.isEmpty || !['COORDINATOR', 'SUPPLIER'].contains(flow)) ? 'COORDINATOR' : flow,
              decoration: AppFormWidgets.fieldDecoration('إضافة مهمة ل', Icons.assignment_ind_rounded, context),
              items: const [
                DropdownMenuItem(value: 'COORDINATOR', child: Text('نفسي')),
                DropdownMenuItem(value: 'SUPPLIER', child: Text('مورد حسب الخدمات')),
              ],
              onChanged: isEditing ? null : (val) {
                controller.assignmentTypeRx.value = val ?? 'COORDINATOR';
                
                if (controller.assignmentTypeRx.value == 'COORDINATOR') 
                {
                  controller.assigneeIdRx.value = AuthService.user.value.id;
                  controller.selectedSupplierForNewTaskRx.value = null;
                } 
                else if (controller.assignmentTypeRx.value == 'SUPPLIER') 
                {
                  controller.assigneeIdRx.value = null;
                  controller.selectedSupplierForNewTaskRx.value = null;
                }
              },
            );
          }),
          Obx(() {
            return (controller.assignmentTypeRx.value == 'SUPPLIER') ?
              _showServices(context, isEditing) : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _showServices(BuildContext context, bool isEditing)
  {
    final brightness = Theme.of(context).brightness;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),

          if (controller.selectedSupplierForNewTaskRx.value == null) ...[
            Text(
              'اختر نوع الخدمة لتحديد المورد:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSubtitle.getByBrightness(brightness),
              ),
            ),
            const SizedBox(height: 16),

            if (serviceCtrl.services.isEmpty) Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'لا توجد خدمات متاحة حالياً',
                    style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: serviceCtrl.services.map((service) {
                  return _buildServiceChip(context, service, isEditing);
                }).toList(),
              ),
          ] else ...[
            // Selected Supplier View
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.store_rounded, color: AppColors.primary.getByBrightness(brightness)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المورد المحدد',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary.getByBrightness(brightness),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${controller.selectedSupplierForNewTaskRx.value!.name} (${serviceCtrl.services.firstWhereOrNull((s) => s.id == controller.serviceIdRx.value)?.serviceName ?? "خدمة غير معروفة"})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textBody.getByBrightness(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    color: AppColors.primary.getByBrightness(brightness),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.background.getByBrightness(brightness),
                    ),
                    onPressed: isEditing ? null : () {
                      controller.selectedSupplierForNewTaskRx.value = null;
                      controller.assigneeIdRx.value = null;
                      controller.serviceIdRx.value = null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceChip(BuildContext context, Service service, bool isEditing) {
    final brightness = Theme.of(context).brightness;
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: isEditing ? null : () async {
          serviceCtrl.selectedService.value = service;
          
          // 1. Start fetching suppliers for this specific service in the background.
          // This will set serviceCtrl.isLoading to true.
          serviceCtrl.fetchSuppliersForService(service.id);

          // 2. Navigate immediately. ServiceSuppliersScreen will use Obx to show 
          // either the loading widget or the list when data arrives.
          final result = await Get.to<Supplier>(() => const ServiceSuppliersScreen());
          
          if (result != null) {
            controller.selectedSupplierForNewTaskRx.value = result;
            controller.assignmentTypeRx.value = 'SUPPLIER';
            controller.assigneeIdRx.value = result.id;
            controller.serviceIdRx.value = service.id;
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background.getByBrightness(brightness),
            border: Border.all(
              color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.miscellaneous_services_rounded,
                color: AppColors.textSubtitle.getByBrightness(brightness),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                service.serviceName,
                style: TextStyle(
                  color: AppColors.textBody.getByBrightness(brightness),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleAndCostCard(BuildContext context, bool isEditing) {
    final event = eventCtrl.events.firstWhereOrNull((e) => e.id == controller.eventIdRx.value);
    DateTime? eventStart;
    DateTime? eventEnd;

    if (event != null) {
      eventStart = DateTime.tryParse(event.eventDate) ?? DateTime.now();
      
      final dur = event.eventDuration;
      final unit = event.eventDurationUnit.toUpperCase();
      eventEnd = switch(unit){
        'WEEK' => eventStart.add(Duration(days: dur * 7 -1)),
        'MONTH' => DateTime(eventStart.year, eventStart.month + dur, eventStart.day),
        _ => eventStart.add(Duration(days: dur -1)),
      };
    }

    return _buildCardWrapper(
      context: context,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TaskDatePicker(
                  label: 'تاريخ البدء', 
                  date: controller.startDateRx,
                  firstDate: eventStart?.isBefore(DateTime.now()) == true? DateTime.now() : eventStart,
                  lastDate: eventEnd,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(()=>
                  TaskDatePicker(
                    label: 'تاريخ التسليم', 
                    date: controller.dueDateRx,
                    firstDate: controller.startDateRx.value,
                    lastDate: eventEnd,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.costController,
            readOnly: isEditing,
            keyboardType: TextInputType.number,
            decoration: AppFormWidgets.fieldDecoration('التكلفة الإجمالية', Icons.monetization_on_rounded, context),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, bool isEditing) 
  {
    return _buildCardWrapper(
      context: context,
      child: Column(
        children: [
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: (controller.reminderTypeRx.value.isEmpty || !['none', 'BEFORE_DUE', 'INTERVAL'].contains(controller.reminderTypeRx.value)) ? 'none' : controller.reminderTypeRx.value,
              decoration: AppFormWidgets.fieldDecoration('نوع التذكير', Icons.notifications_outlined, context),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('بدون تذكير')),
                DropdownMenuItem(value: 'BEFORE_DUE', child: Text('قبل تاريخ التسليم')),
                DropdownMenuItem(value: 'INTERVAL', child: Text('تذكير متكرر')),
              ],
              onChanged: (val) => controller.reminderTypeRx.value = val ?? 'none',
            ),
          ),
          Obx(() {
            if (controller.reminderTypeRx.value == 'none') {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: controller.reminderValueController,
                        keyboardType: TextInputType.number,
                        decoration: AppFormWidgets.fieldDecoration('القيمة', Icons.numbers_rounded, context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: (controller.reminderUnitRx.value.isEmpty || !['HOUR', 'DAY', 'WEEK'].contains(controller.reminderUnitRx.value)) ? 'DAY' : controller.reminderUnitRx.value,
                        decoration: AppFormWidgets.fieldDecoration('الوحدة', Icons.access_time_rounded, context),
                        items: const [
                          DropdownMenuItem(value: 'HOUR', child: Text('ساعات')),
                          DropdownMenuItem(value: 'DAY', child: Text('أيام')),
                          DropdownMenuItem(value: 'WEEK', child: Text('أسابيع')),
                        ],
                        onChanged: (val) => controller.reminderUnitRx.value = val ?? 'days',
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Brightness brightness, bool isEditing, Task? task) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        final bool showConfirm = controller.assignmentTypeRx.value == 'COORDINATOR' || controller.assigneeIdRx.value != null;
        return AnimatedOpacity(
          opacity: showConfirm ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: GradientButton(
            text: isEditing ? 'حفـظ التـعـديـلات' : 'إضـافة المهـمة',
            isLoading: controller.isLoading.value,
            onPressed: () {
              if (isEditing) {
                controller.updateTask(task!.id, currentStatus: task.status);
              } else {
                controller.createTask();
              }
            },
          ),
        );
      }),
    );
  }
}
