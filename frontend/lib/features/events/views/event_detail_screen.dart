// ignore_for_file: unused_local_variable, slash_for_doc_comments

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/status.dart';
import '../../../core/components/logout_dialog.dart' show logoutDialog;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/themes/app_colors.dart' show AppColors;
import '../../../core/components/app_image.dart';


import '../../notifications/controller/notification_controller.dart' show NotificationController;
import '../../tasks/controller/task_controller.dart' show TaskController;
import '../../incomes/controller/income_controller.dart' show IncomeController;
import '../../clients/controller/client_controller.dart' show ClientController;


import '../controller/event_controller.dart' show EventController;
import '../data/models/event.dart' show Event;

import '../widgets/even_widgets.dart' show 
  EventInfoTab, EventTasksTab, EventBudgetTab;

class EventDetailScreen extends StatelessWidget 
{
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    final Event event = Get.arguments;
    final EventController eventController = Get.find<EventController>();
    final TaskController taskController = Get.find<TaskController>();
    final IncomeController incomeController = Get.find<IncomeController>();
    final ClientController clientController = Get.find<ClientController>();

    // صفحة تفاصيل المناسبة
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background.getByBrightness(brightness),
        body: Obx(() {
          /**
           * Find the latest event from the controller to ensure reactivity
           * ابحث عن آخر حدث من وحدة التحكم لضمان التفاعلية
           */
          final currentEvent = eventController.events.firstWhere(
            (e) => e.id == event.id,
            orElse: () => event,
          );

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                
                centerTitle: true,
                expandedHeight: 240,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.appBarBackground.getByBrightness(brightness),
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تفاصيل مناسبة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          shadows: [Shadow(color: AppColors.black54, blurRadius: 8)],
                        ),
                      ),
                      Text(
                        currentEvent.eventName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white.withValues(alpha: 0.9),
                          shadows: [Shadow(color: AppColors.black54, blurRadius: 8)],
                        ),
                      ),
                    ],
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Event Cover Image
                      if (currentEvent.imgUrl.isNotEmpty)
                        AppImage.network(
                          currentEvent.imgUrl,
                          fit: BoxFit.cover,
                          viewerTitle: currentEvent.eventName,
                          fallbackWidget: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient.getByBrightness(brightness),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient.getByBrightness(brightness),
                          ),
                        ),
                      
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.transparent,
                              AppColors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),

                      // Client Avatar Overlay
                      Positioned(
                        bottom: 60,
                        right: 20,
                        child: Obx(() {
                          final client = clientController.clients.firstWhereOrNull((c) => c.id == currentEvent.clientId);
                          return Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: AppImage.network(
                                client?.imgUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                viewerTitle: client?.name,
                                fallbackWidget: const Icon(Icons.person_rounded, size: 35, color: AppColors.white),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                  onPressed: () => Get.back(),
                ),
                actions: [
                  IconButton(
                    onPressed: () => Get.toNamed(AppRoutes.notifications),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Obx(() {
                            final count = Get.find<NotificationController>().notiNotReadCount.value;
                            if (count == 0) return const SizedBox.shrink();
                            
                            return Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count > 99 ? '99+' : count.toString(),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: logoutDialog,
                    icon: Icon(Icons.logout_rounded, color: AppColors.accent.getByBrightness(brightness)),
                  )
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventHeader(currentEvent, context),
                      const SizedBox(height: 16),
                      _buildTabBar(context),
                    ],
                  ),
                ),
              ),
            ],

            // تبويبات صفحة تفاصيل المناسبة
            body: TabBarView(
              children: [
                // تبويبة المعلومات في صفحة تفاصيل المناسبة
                EventInfoTab(event: event),

                // تبويبة المهام في صفحة تفاصيل المناسبة
                EventTasksTab(
                  event: event,
                ),

                // تبويبة الميزانية في صفحة تفاصيل المناسبة
                EventBudgetTab(event: event,),
              ],
            ),
          );
        }),

        
      ),
    );
  }


  
  /// رأس صفحة تفاصيل المناسبة تحتوي على
  /// 
  /// id: رقم المناسبة
  /// 
  /// name: اسم المناسبة
  /// 
  /// status: حالة المناسبة
  Widget _buildEventHeader(Event event, BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
                Text(
                  '#EV-${event.id}',
                  
                  style: TextStyle(
                    color: AppColors.textSubtitle.getByBrightness(brightness),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
              ],
            ),
            _buildStatusBadge(event.status.tryText(), event.status.tryColor(brightness))
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  

  /// شريط تبويبات صفحة تفاصيل المناسبة تحتوي على التبويبات التالية
  /// 
  /// المعلومات   -   المهام   -   الميزانية
  Widget _buildTabBar(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    return TabBar(
      labelColor: AppColors.textSubtitle.getByBrightness(brightness),
      unselectedLabelColor: AppColors.primary.getByBrightness(brightness),
      indicatorColor: AppColors.primary.getByBrightness(brightness),
      indicatorWeight: 3,
      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      tabs: [
        Tab(text: 'المعلومات'),
        Tab(text: 'المهام'),
        Tab(text: 'الميزانية'),
      ],
    );
  }
}
