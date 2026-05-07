import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../../core/api/auth_service.dart';
import '../../../core/utils/date_formatter.dart' show DateFormatter;
import '../../auth/controller/auth_controller.dart' show AuthController;
import '../data/models/notification.dart' show NotificationModel;
import '../controller/notification_controller.dart' show NotificationController;
import '../views/notification_detail_screen.dart' show NotificationDetailScreen;
import '../../../core/components/widgets/loading_widget.dart' show LoadingWidget;
import '../../../core/components/empty_state_widget.dart' show EmptyStateWidget;
import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/components/myp_scrollbar.dart';
import '../../shared/widgets/scroll_to_top_fab.dart';
import '../../../core/themes/app_colors.dart' show AppColors;


class NotificationListScreen extends GetView<NotificationController> 
{
  NotificationListScreen({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) 
  {
    controller.fetchNotifications();
    final brightness = Theme.of(context).brightness;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final bool handled = controller.cancelSelectionMode();
        if (!handled) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background.getByBrightness(brightness),
      appBar: CustomAppBar(
        title: 'الإشعارات',
        showLogoutButton: false,
        showBackButton: true,
        afterActions: [
          
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppColors.primary.getByBrightness(brightness)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppColors.surface.getByBrightness(brightness),
            onSelected: (value)=> switch(value) {
              'mark_all_read' => controller.startSelectionMode('mark_read', controller.filteredNotifications.map((n) => n.id).toList()),
              'delete_all'=> controller.startSelectionMode('delete', controller.filteredNotifications.map((n) => n.id).toList()),
              'logout' => authController.logout(),
              _=> null
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever_rounded, color: AppColors.accent.getByBrightness(brightness), size: 20),
                    const SizedBox(width: 12),
                    Text('حذف الكل', style: TextStyle(color: AppColors.textBody.getByBrightness(brightness))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, color: AppColors.primary.getByBrightness(brightness), size: 20),
                    const SizedBox(width: 12),
                    Text('تمييز الكل كمقروءة', style: TextStyle(color: AppColors.textBody.getByBrightness(brightness))),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.accent.getByBrightness(brightness), size: 20),
                    const SizedBox(width: 12),
                    Text('تسجيل الخروج', style: TextStyle(color: AppColors.textBody.getByBrightness(brightness))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (!controller.isSelectionMode.value || controller.selectedNotificationIds.isEmpty) {
          return const SizedBox.shrink();
        }
        final bool isDelete = controller.selectionModeAction.value == 'delete';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.getByBrightness(brightness),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => isDelete ? _showBulkDeleteConfirm(brightness) : _showBulkMarkReadConfirm(brightness),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDelete ? AppColors.accent.getByBrightness(brightness) : AppColors.primary.getByBrightness(brightness),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isDelete 
                  ? 'حذف المحدد (${controller.selectedNotificationIds.length})'
                  : 'تمييز كمقروءة (${controller.selectedNotificationIds.length})',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: ScrollToTopFab(
        showScrollToTop: controller.showScrollToTop,
        onPressed: controller.scrollToTop,
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.fetchNotifications(force: true),
        child: Obx(() {
          final notifications = controller.filteredNotifications;
        
          return MyPScrollbar(
            controller: controller.scrollController,
            child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // 1. Search & Date Header (Animated Hiding)
                    SliverToBoxAdapter(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: controller.showHeader.value
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: controller.searchController,
                                      onChanged: (value) => controller.searchQuery.value = value,
                                      decoration: InputDecoration(
                                        hintText: 'بحث في الإشعارات...',
                                        prefixIcon: const Icon(Icons.search_rounded),
                                        filled: true,
                                        fillColor: AppColors.surface.getByBrightness(brightness),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                      ),
                                    ),
                                    /*
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDatePickerField(
                                            context,
                                            'من:',
                                            controller.startDate.value,
                                            (date) => controller.startDate.value = date,
                                            brightness,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildDatePickerField(
                                            context,
                                            'إلى:',
                                            controller.endDate.value,
                                            (date) => controller.endDate.value = date,
                                            brightness,
                                            firstDate: controller.startDate.value,
                                          ),
                                        ),
                                        if (controller.startDate.value != null || controller.endDate.value != null)
                                          IconButton(
                                            icon: const Icon(Icons.clear_all_rounded, color: AppColors.red),
                                            onPressed: () {
                                              controller.startDate.value = null;
                                              controller.endDate.value = null;
                                            },
                                            tooltip: 'مسح التواريخ',
                                          ),
                                      ],
                                    ),
                                    */
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
        
                    // 2. Sticky Status Tabs & Select All
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyHeaderDelegate(
                        minHeight: 100, // Increased to accommodate select all
                        maxHeight: 100,
                        child: Container(
                          color: AppColors.background.getByBrightness(brightness),
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                child: Row(
                                  children: [
                                    _buildFilterTab('الكل', 'all', controller.filterStatus.value == 'all'),
                                    const SizedBox(width: 8),
                                    _buildFilterTab('غير مقروء', 'unread', controller.filterStatus.value == 'unread'),
                                    const SizedBox(width: 8),
                                    _buildFilterTab('مقروء', 'read', controller.filterStatus.value == 'read'),
                                  ],
                                ),
                              ),
                              if (controller.isSelectionMode.value)
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: controller.selectedNotificationIds.length == notifications.length && notifications.isNotEmpty,
                                        onChanged: (val) => controller.toggleSelectAll(notifications.map((n) => n.id).toList()),
                                        activeColor: AppColors.primary.getByBrightness(brightness),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                      const Text(
                                        'تحديد الكل',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${controller.selectedNotificationIds.length} مختار',
                                        style: TextStyle(
                                          color: AppColors.primary.getByBrightness(brightness),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
        
                    // 3. Notifications List or Empty State
                    if (controller.isLoading.value)
                      const SliverFillRemaining(
                        child: LoadingWidget(),
                      )
                    else if (notifications.isEmpty)
                      SliverFillRemaining(
                        child: EmptyStateWidget(
                          message: 'لا توجد إشعارات',
                          icon: Icons.notifications_off_rounded,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final notification = notifications[index];
                              return _buildNotificationCard(context, notification);
                            },
                            childCount: notifications.length,
                          ),
                        ),
                      ),
                  ],
                ),
              );
        }),
      ),
    ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) 
  {
    final brightness = Theme.of(context).brightness;
    final bool isUnread = !notification.isRead;
    final iconData = _getNotificationIcon(notification.type);
    final statusColor = _getNotificationColor(notification.type, brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.getByBrightness(brightness),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1), width: 1),
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (controller.isSelectionMode.value) {
              controller.toggleNotificationSelection(notification.id);
            } else {
              controller.markAsRead(notification.id);
              Get.to(() => NotificationDetailScreen(notification: notification));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.isSelectionMode.value)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Checkbox(
                      value: controller.selectedNotificationIds.contains(notification.id),
                      onChanged: (val) => controller.toggleNotificationSelection(notification.id),
                      activeColor: AppColors.primary.getByBrightness(brightness),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: statusColor, size: 22),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBody.getByBrightness(brightness),
                              ),
                            ),
                          ),

                          if (isUnread) Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),

                          if (!controller.isSelectionMode.value)
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, color: AppColors.textSubtitle.getByBrightness(brightness), size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: AppColors.surface.getByBrightness(brightness),
                              onSelected: (value) {
                                if (value == 'mark_read') {
                                  controller.markAsRead(notification.id);
                                } else if (value == 'delete') {
                                  _showSingleDeleteConfirm(notification.id, brightness);
                                }
                              },
                              itemBuilder: (context) => [
                                if (isUnread)
                                  PopupMenuItem(
                                    value: 'mark_read',
                                    child: Row(
                                      children: [
                                        Icon(Icons.mark_email_read_rounded, color: AppColors.primary.getByBrightness(brightness), size: 20),
                                        const SizedBox(width: 12),
                                        Text('تمييز كمقروءة', style: TextStyle(color: AppColors.textBody.getByBrightness(brightness))),
                                      ],
                                    ),
                                  ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, color: AppColors.accent.getByBrightness(brightness), size: 20),
                                      const SizedBox(width: 12),
                                      Text('حذف', style: TextStyle(color: AppColors.textBody.getByBrightness(brightness))),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      Text(
                        notification.message,

                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSubtitle.getByBrightness(brightness),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textSubtitle.getByBrightness(brightness).withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSubtitle.getByBrightness(brightness).withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    return switch (type?.toLowerCase()) {
      'task'=> Icons.assignment_rounded,
      'event'=> Icons.event_rounded,
      'payment'=> Icons.payments_rounded,
      'alert'=> Icons.warning_amber_rounded,
      _=> Icons.notifications_rounded,
    };
  }

  Color _getNotificationColor(String? type, Brightness brightness) {
    return switch (type?.toLowerCase()) {
      'task'=> AppColors.primary.getByBrightness(brightness),
      'event'=> AppColors.info.getByBrightness(brightness),
      'payment'=> AppColors.success.getByBrightness(brightness),
      'alert'=> AppColors.accent.getByBrightness(brightness),
      _=> AppColors.primary.getByBrightness(brightness),
    };
  }

  String _formatDate(String dateStr) {
    return DateFormatter.formatDateTime(dateStr, fallback: dateStr);
  }





  void _showSingleDeleteConfirm(int id, Brightness brightness) {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      titleStyle: TextStyle(
        color: AppColors.primary.getByBrightness(brightness),
        fontWeight: FontWeight.bold,
      ),
      middleText: 'هل أنت متأكد من حذف هذا الإشعار؟',
      middleTextStyle: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
      backgroundColor: AppColors.surface.getByBrightness(brightness),
      radius: 24,
      contentPadding: const EdgeInsets.all(20),
      confirm: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        child: ElevatedButton(
          onPressed: () {
            Get.back();
            controller.deleteNotification(id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent.getByBrightness(brightness),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'نعم، احذف',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          'إلغاء',
          style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
        ),
      ),
    );
  }

  void _showBulkDeleteConfirm(Brightness brightness) {
    Get.defaultDialog(
      title: 'تأكيد الحذف',
      titleStyle: TextStyle(
        color: AppColors.primary.getByBrightness(brightness),
        fontWeight: FontWeight.bold,
      ),
      middleText: 'هل أنت متأكد من حذف الإشعارات (${controller.selectedNotificationIds.length}) المختارة؟',
      middleTextStyle: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
      backgroundColor: AppColors.surface.getByBrightness(brightness),
      radius: 24,
      contentPadding: const EdgeInsets.all(20),
      confirm: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        child: ElevatedButton(
          onPressed: () {
            Get.back();
            controller.deleteSelectedNotifications();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent.getByBrightness(brightness),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'نعم، احذف المحدد',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          'إلغاء',
          style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
        ),
      ),
    );
  }

  void _showBulkMarkReadConfirm(Brightness brightness) {
    Get.defaultDialog(
      title: 'تأكيد التمييز',
      titleStyle: TextStyle(
        color: AppColors.primary.getByBrightness(brightness),
        fontWeight: FontWeight.bold,
      ),
      middleText: 'هل أنت متأكد من تمييز الإشعارات (${controller.selectedNotificationIds.length}) كمقروءة؟',
      middleTextStyle: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
      backgroundColor: AppColors.surface.getByBrightness(brightness),
      radius: 24,
      contentPadding: const EdgeInsets.all(20),
      confirm: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        child: ElevatedButton(
          onPressed: () {
            Get.back();
            controller.markSelectedAsRead();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary.getByBrightness(brightness),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'نعم، ميزها',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          'إلغاء',
          style: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String value, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => controller.filterStatus.value = value,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.light.withValues(alpha: 0.1) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary.light 
                  : AppColors.grey.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? AppColors.primary.light 
                  : AppColors.textSubtitle.light,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildDatePickerField(
  //   BuildContext context, 
  //   String label, 
  //   DateTime? selectedDate, 
  //   Function(DateTime?) onSelected,
  //   Brightness brightness,
  //   {DateTime? firstDate}
  // ) {
  //   return InkWell(
  //     onTap: () async {
  //       final DateTime? pickedDate = await showDatePicker(
  //         context: context,
  //         initialDate: (selectedDate != null && firstDate != null && selectedDate.isBefore(firstDate))
  //             ? firstDate
  //             : (selectedDate ?? DateTime.now()),
  //         firstDate: firstDate ?? DateTime(2020),
  //         lastDate: DateTime(2030),
  //         locale: const Locale('ar', 'SA'),
  //         builder: (context, child) {
  //           return Theme(
  //             data: Theme.of(context).copyWith(
  //               colorScheme: ColorScheme.fromSeed(
  //                 seedColor: AppColors.primary.getByBrightness(brightness),
  //                 brightness: brightness,
  //               ),
  //             ),
  //             child: child!,
  //           );
  //         },
  //       );
        
  //       if (pickedDate != null) {
  //         if (context.mounted) {
  //           final TimeOfDay? pickedTime = await showTimePicker(
  //             context: context,
  //             initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
  //             builder: (context, child) {
  //               return Theme(
  //                 data: Theme.of(context).copyWith(
  //                   colorScheme: ColorScheme.fromSeed(
  //                     seedColor: AppColors.primary.getByBrightness(brightness),
  //                     brightness: brightness,
  //                   ),
  //                 ),
  //                 child: child!,
  //               );
  //             },
  //           );

  //           if (pickedTime != null) {
  //             final combined = DateTime(
  //               pickedDate.year,
  //               pickedDate.month,
  //               pickedDate.day,
  //               pickedTime.hour,
  //               pickedTime.minute,
  //             );
  //             onSelected(combined);
  //           }
  //         }
  //       }
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: AppColors.surface.getByBrightness(brightness),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color: selectedDate != null 
  //               ? AppColors.primary.getByBrightness(brightness) 
  //               : AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1),
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(
  //             Icons.access_time_filled_rounded, 
  //             size: 16, 
  //             color: selectedDate != null 
  //                 ? AppColors.primary.getByBrightness(brightness) 
  //                 : AppColors.textSubtitle.getByBrightness(brightness)
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Text(
  //               selectedDate != null 
  //                   ? DateFormat('yyyy/MM/dd hh:mm a', 'ar').format(selectedDate) 
  //                   : label,
  //               style: TextStyle(
  //                 fontSize: 10,
  //                 color: selectedDate != null 
  //                     ? AppColors.textBody.getByBrightness(brightness) 
  //                     : AppColors.textSubtitle.getByBrightness(brightness),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.maxHeight,
    required this.minHeight,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
