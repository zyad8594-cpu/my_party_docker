import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../../core/api/auth_service.dart' show AuthService;
import '../../../../../core/utils/status.dart';
import '../../../../../core/utils/string_toolse.dart' show StrTools;
import '../../../../tasks/controller/task_controller.dart';
import '../../../../tasks/data/models/task.dart';
import '../../../../../core/themes/app_colors.dart' show AppColors;
import '../../../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../data/models/event.dart';
import '../detail_widgets.dart' show buildStatusBadge;
import '../../../../../core/components/empty_state_widget.dart' show EmptyStateWidget;
import '../../../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../../../../services/controller/service_controller.dart' show ServiceController;
import '../../../../../core/components/app_image.dart';
import '../../../../../core/components/widgets/myp_list_view_widget.dart' show MyPListView;
import '../../../../../core/components/widgets/loading_widget.dart' show LoadingWidget;

class EventTasksTab extends StatelessWidget {
  final Event event;

  const EventTasksTab({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final taskController = Get.find<TaskController>();
    final event = Get.arguments as Event;

    return MyPListView.builder<dynamic>(
      context,
      isLoading: taskController.isLoading,
      loadingWidget: () => const LoadingWidget(),
      emptyWidget: () => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(Get.height > 750) const SizedBox(height: 40),
            const EmptyStateWidget(message: 'لا توجد مهام مطابقة للبحث', icon: Icons.search_off_rounded),
            if(Get.height > 750) const SizedBox(height: 20),
            
            if([Status.IN_PROGRESS, Status.PENDING].contains(event.status)) ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.taskAdd,
                  arguments: event),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('إضافة مهمة جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary.getByBrightness(brightness),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      filters: () => taskController.filteredTasks
                .where((t) => t.eventId == event.id)
                .toList(),
      onRefresh: () => taskController.fetchTasks(force: true),
      scrollController: taskController.scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      header: _buildFilters(context, brightness),
      itemBuilder: (context, index, task) {
        return _buildTaskItem(context, task, brightness);
      },
    );
  }

  /// بناء شريط البحث والفلترة
  Widget _buildFilters(BuildContext context, Brightness brightness) {
    final controller = Get.find<TaskController>();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          /// مربع البحث
          TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'بحث عن مهمة...',
              prefixIcon: Icon(Icons.search,
                  color: AppColors.textSubtitle.getByBrightness(brightness)),
              fillColor: AppColors.surface.getByBrightness(brightness),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),

          /// شريط تبويبات المهام
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabChip('كل المهام', brightness),
                const SizedBox(width: 8),
                _buildTabChip('مهامي', brightness),
                const SizedBox(width: 8),
                _buildTabChip('مهام الموردين', brightness),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// قائمة منسدلة لفلترة المهام وزر إضافة مهمة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// قائمة منسدلة لفلترة المهام
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface.getByBrightness(brightness),
                  borderRadius: BorderRadius.circular(12),
                ),

                /// قائمة منسدلة لفلترة المهام
                child: DropdownButtonHideUnderline(
                  child: Obx(
                    () => DropdownButton<String>(
                        value: controller.selectedStatus.value,
                        items:
                        StatusTools.getAllStatusText(prepend: ['الكل'], remove: ['معتمدة'])
                        //  ['الكل', 'قيد الانتظار', 'قيد التنفيذ', 'مكتملة', 'ملغاة']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, style: const TextStyle(fontSize: 13))
                          )
                        ).toList(),
                        onChanged: (val) 
                        {
                          if (val != null) 
                          {
                            controller.selectedStatus.value = val;
                          }
                        },
                        icon: Icon(
                          Icons.filter_list_rounded,
                          size: 18,
                          color: AppColors.primary.getByBrightness(brightness)
                        ),
                    )
                  ),
                ),
              ),
              
              if([Status.IN_PROGRESS, Status.PENDING].contains(event.status)) TextButton.icon(
                onPressed: () => Get.toNamed(
                  AppRoutes.taskAdd,
                  arguments: Get.arguments,
                ),
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: const Text('إضافة مهمة'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, Brightness brightness) {
    final controller = Get.find<TaskController>();
    return Obx(() {
      final isSelected = controller.selectedFilterTab.value == label;
      return GestureDetector(
        onTap: () => controller.selectedFilterTab.value = label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.getByBrightness(brightness)
                : AppColors.surface.getByBrightness(brightness),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.transparent
                  : AppColors.textSubtitle
                      .getByBrightness(brightness)
                      .withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.white
                  : AppColors.textBody.getByBrightness(brightness),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTaskItem(BuildContext context, Task task, Brightness brightness) {
    final statusColor = task.status.color(brightness);
    final isVendorTask = task.assignmentType.toUpperCase() == 'SUPPLIER';
    final serviceController = Get.find<ServiceController>();
    final service = serviceController.services.firstWhereOrNull((s) => s.id == task.serviceId);
    
    // Assignment type color coding
    final typeColor = isVendorTask 
        ? AppColors.secondary.getByBrightness(brightness) 
        : AppColors.info.getByBrightness(brightness);

    final dateFormat = DateFormat('yyyy-MM-dd');
    final startDateStr = task.dateStart != null && task.dateStart!.isNotEmpty
        ? dateFormat.format(DateTime.parse(task.dateStart!)) 
        : 'N/A';
    final dueDateStr = task.dateDue != null && task.dateDue!.isNotEmpty
        ? dateFormat.format(DateTime.parse(task.dateDue!)) 
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.toNamed(AppRoutes.taskDetail, arguments: task),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isVendorTask) ...[
                      Obx(() {
                        final supplier = Get.find<SupplierController>().suppliers.firstWhereOrNull((s) => s.id == task.userAssignId);
                        return ClipOval(
                          child: AppImage.network(
                            supplier?.imgUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            viewerTitle: supplier?.name,
                            fallbackWidget: Container(
                              width: 40,
                              height: 40,
                              color: typeColor.withValues(alpha: 0.1),
                              child: Icon(Icons.person_rounded, size: 20, color: typeColor),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 12),
                    ] else ...[
                      Obx(() {
                        final coordinator = AuthService.user.value;
                        return ClipOval(
                          child: AppImage.network(
                            coordinator.imgUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            viewerTitle: coordinator.name,
                            fallbackWidget: Container(
                              width: 40,
                              height: 40,
                              color: typeColor.withValues(alpha: 0.1),
                              child: Icon(Icons.person_rounded, size: 20, color: typeColor),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 12),
                    ],
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.typeTask ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textBody.getByBrightness(brightness),
                            ),
                          ),
                          if (service != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              service.serviceName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSubtitle.getByBrightness(brightness),
                              ),
                            ),
                          ],
                          const SizedBox(height: 2),
                          Obx(() {
                            final assignedPerson =  
                                Get.find<SupplierController>().suppliers.firstWhereOrNull((s) => s.id == task.userAssignId);
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isVendorTask
                                      ? 'المورد: ${task.assigneName ?? 'غير محدد'}'
                                      : 'مهمة خاصة بي',
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if(
                                  (isVendorTask && (assignedPerson?.email != null && (assignedPerson?.email.isNotEmpty ?? false))) || 
                                  (!isVendorTask && (AuthService.user.value.email != null && (AuthService.user.value.email?.isNotEmpty ?? false))) 
                                )
                                    Text(
                                      isVendorTask ? assignedPerson!.email : AuthService.user.value.email!,
                                      style: TextStyle(
                                        color: AppColors.textSubtitle.getByBrightness(brightness),
                                        fontSize: 10,
                                    ),
                                  )
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildStatusBadge(
                          task.status.tryText(),
                          statusColor,
                          small: true,
                        ),
                        
                        if(!task.status.isCancelled && !task.status.isRejected && 
                            !event.isDeleted && !event.status.isCancelled && 
                            !task.status.isCompleted) 
                          PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 20, color: AppColors.textSubtitle.getByBrightness(brightness)),
                          onSelected: (value)=> switch(value)
                          {
                            'edit' => Get.toNamed(AppRoutes.taskAdd, arguments: task), 
                            'delete' => Get.defaultDialog(
                                title: 'تأكيد الإلغاء',
                                middleText: 'هل أنت متأكد من إلغاء هذه المهمة؟',
                                textConfirm: 'نعم ألغي',
                                textCancel: 'تراجع',
                                confirmTextColor: AppColors.white,
                                onConfirm: () {
                                  final controller = Get.find<TaskController>();
                                  controller.deleteTask(task.id);
                                  Get.back();
                                },
                                buttonColor: AppColors.red, // Apply AppColors.red here
                                backgroundColor: AppColors.surface.getByBrightness(brightness),
                                radius: 12,
                              ),
                              _ => null
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('تعديل'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.clear, size: 18, color: AppColors.red), // Changed color to AppColors.red
                                   SizedBox(width: 8),
                                  Text('إلغاء', style: TextStyle(color: AppColors.red)), // Changed color to AppColors.red
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                   StrTools.takeLines(task.description, 1, width: 30),
                    style: TextStyle(
                      color: AppColors.textSubtitle.getByBrightness(brightness),
                      fontSize: 12,
                    ),
                  ),
                ],
                
                if((task.status.isPending || task.status.isInProgress) && !isVendorTask) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient.getByBrightness(brightness),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: ()=> Get.defaultDialog(
                                title: task.status.isPending ? 'تأكيد البدء' : 'تأكيد الإكمال',
                                middleText: task.status.isPending ? 'هل أنت متأكد من بدء هذه المهمة؟' : 'هل أنت متأكد من إكمال هذه المهمة؟',
                                textConfirm: 'تأكيد',
                                textCancel: 'تراجع',
                                confirmTextColor: AppColors.white,
                                onConfirm: () {
                                  final controller = Get.find<TaskController>();
                                  controller.updateTaskStatus(task.id, task.status.isPending ? Status.IN_PROGRESS : Status.COMPLETED);
                                  Get.back();
                                },
                                
                              ),
                            
                            icon: Icon(
                              task.status.isPending ? Icons.play_arrow_rounded : Icons.check_circle_rounded,
                              color: AppColors.white,
                            ),
                            label: Text(
                              task.status.isPending ? 'بدء التنفيذ' : 'إكمال المهمة',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.transparent,
                              shadowColor: AppColors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSubtitle.getByBrightness(brightness)),
                        const SizedBox(width: 4),

                        Text(
                          '$startDateStr / $dueDateStr',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSubtitle.getByBrightness(brightness),
                          ),
                        ),
                      ],
                    ),
                    
                    if (isVendorTask && task.status.isCompleted)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          backgroundColor: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.05),
                        ),
                        onPressed: task.rating != null && task.rating != 0 ? null : () {
                          
                          _showRatingDialog(context, task, brightness);
                        },
                        icon: Icon(task.rating == null || task.rating == 0? Icons.star_border_rounded: Icons.star_rounded, size: 16, color: AppColors.amber),
                        label:  Text(
                          task.rating == null || task.rating == 0? 'تقييم' : '${(task.rating! / 5.0 * 100).toStringAsFixed(1)}%', 
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  void _showRatingDialog(BuildContext context, Task task, Brightness brightness) {
    int rating = 5;
    final commentController = TextEditingController();
    final controller = Get.find<TaskController>();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface.getByBrightness(brightness),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تقييم المهمة', textAlign: TextAlign.center),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                  'تقييم تنفيذ المهمة من قبل المورد: ${task.assigneName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.textSubtitle.getByBrightness(brightness)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.amber,
                        size: 32,
                      ),
                      onPressed: () => setState(() => rating = index + 1),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'أضف تعليقك هنا (اختياري)',
                    filled: true,
                    fillColor: AppColors.background.getByBrightness(brightness),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.getByBrightness(brightness),
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              controller.rateTask(task.id, rating, commentController.text);
              Get.back();
            },
            child: const Text('إرسال التقييم'),
          ),
        ],
      ),
    );
  }


  
}
