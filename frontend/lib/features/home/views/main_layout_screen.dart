import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/controllers/main_layout_controller.dart';
import 'home_screen.dart';
import 'admin_dashboard_screen.dart';
import '../../clients/views/client_list_screen.dart';
import '../../events/views/event_list_screen.dart';
import '../../reports/views/reports_screen.dart';
// import '../../reports/views/supplier_report_screen.dart';
// import '../../notifications/views/notification_list_screen.dart';
import '../../suppliers/views/supplier_home_screen.dart';
import '../../suppliers/views/supplier_services_screen.dart';
import '../../tasks/views/role_based_task_list_screen.dart';
import '../../coordinators/views/coordinator_list_screen.dart';
import '../../suppliers/views/supplier_list_screen.dart';
import '../../services/views/service_list_screen.dart';
// import '../../admin/views/system_users_screen.dart';
// import '../../admin/views/roles_management_screen.dart';

class MainLayoutScreen extends GetView<MainLayoutController> {
  const MainLayoutScreen({super.key});
  
@override
  Widget build(BuildContext context) 
  {
    final brightness = Theme.of(context).brightness;
    
    final role = AuthService.user.value.role;
    final isAdmin = role.toString().toUpperCase() == 'ADMIN';
    final isSupplier = role.toString().toUpperCase() == 'SUPPLIER';

    final List<Widget> supplierPages = [
      SupplierDashboardScreen(),
      const SupplierServicesScreen(),
      const RoleBasedTaskListScreen(),
      // const SupplierReportScreen(),
    ];

    final List<Widget> adminPages = [
      AdminDashboardScreen(),
      CoordinatorListScreen(),
      SupplierListScreen(),
      const ServiceListScreen(),
      // ReportsScreen(),
    ];

    final List<Widget> coordinatorPages = [
      HomeScreen(),
      ClientListScreen(),
      EventListScreen(),
      ReportsScreen(),
      // NotificationListScreen(),
    ];

    final pages = isAdmin ? adminPages : (isSupplier ? supplierPages : coordinatorPages);

    final List<BottomNavigationBarItem> supplierItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_rounded),
        label: 'لوحة التحكم',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.design_services_rounded),
        label: 'الخدمات',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_rounded),
        label: 'مهامي',
      ),
      // BottomNavigationBarItem(
      //   icon: Icon(Icons.bar_chart_rounded),
      //   label: 'التقارير',
      // ),
    ];


    final List<BottomNavigationBarItem> coordinatorItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_rounded),
        label: 'الرئيسية',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_alt_rounded),
        label: 'العملاء',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_rounded),
        label: 'المناسبات',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart_rounded),
        label: 'التقارير',
      ),
      // BottomNavigationBarItem(
      //   icon: Icon(Icons.notifications_rounded),
      //   label: 'الإشعارات',
      // ),
    ];

    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, dynamic result) {
          controller.handleBackPress(didPop);
        },
        child: SelectionArea(
          child: Scaffold(
            body: IndexedStack(
              index: controller.currentIndex.value,
              children: pages,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.getByBrightness(brightness),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: isAdmin 
                  ? _buildAdminBar(context, brightness)
                  : BottomNavigationBar(
                      currentIndex: controller.currentIndex.value,
                      onTap: controller.changePage,
                      selectedItemColor: AppColors.primary.getByBrightness(brightness),
                      unselectedItemColor: AppColors.textSubtitle.getByBrightness(brightness),
                      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                      showUnselectedLabels: true,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: AppColors.transparent,
                      elevation: 0,
                      items: isSupplier ? supplierItems : coordinatorItems,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBar(BuildContext context, Brightness brightness) {
    final List<Map<String, dynamic>> items = [
      {'label': 'الرئيسية', 'icon': Icons.dashboard_rounded},
      {'label': 'المنسقين', 'icon': Icons.people_alt_rounded},
      {'label': 'الموردين', 'icon': Icons.storefront_rounded},
      {'label': 'الخدمات', 'icon': Icons.category_rounded},
      // {'label': 'التقارير', 'icon': Icons.bar_chart_rounded},
    ];

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          return Obx(() {
            final isSelected = controller.currentIndex.value == index;
            return InkWell(
              onTap: () => controller.changePage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.1) 
                    : AppColors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index]['icon'],
                      color: isSelected 
                        ? AppColors.primary.getByBrightness(brightness) 
                        : AppColors.textSubtitle.getByBrightness(brightness),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                          ? AppColors.primary.getByBrightness(brightness) 
                          : AppColors.textSubtitle.getByBrightness(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }),
      ),
    );
  }
}
