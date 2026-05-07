import 'package:get/get.dart';
import 'app_routes.dart' show AppRoutes;


import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/auth/views/profile_screen.dart';
import '../../features/auth/views/supplier_service_selection_screen.dart';

import '../../features/clients/bindings/client_binding.dart';
import '../../features/clients/views/client_list_screen.dart';
import '../../features/clients/views/client_add_screen.dart';
import '../../features/clients/views/client_detail_screen.dart';

import '../../features/home/bindings/main_layout_binding.dart';
import '../../features/home/views/main_layout_screen.dart';

import '../../features/reports/bindings/report_binding.dart';
import '../../features/reports/views/reports_screen.dart';
import '../../features/reports/views/supplier_report_screen.dart';

import '../../features/services/bindings/service_binding.dart';
import '../../features/services/views/service_list_screen.dart';
import '../../features/services/views/service_add_screen.dart';

import '../../features/events/bindings/event_binding.dart';
import '../../features/events/views/event_screens.dart' show 
  EventListScreen, EventAddScreen, EventClientSelectionScreen, EventDetailScreen;

import '../../features/incomes/bindings/income_binding.dart';
import '../../features/incomes/views/income_list_screen.dart';
import '../../features/incomes/views/income_add_screen.dart';
import '../../features/incomes/views/income_detail_screen.dart';

import '../../features/notifications/bindings/notification_binding.dart';
import '../../features/notifications/views/notification_list_screen.dart';

import '../../features/tasks/bindings/task_binding.dart';
import '../../features/tasks/views/task_add_screen.dart';
import '../../features/tasks/views/task_detail_screen.dart';
import '../../features/tasks/views/role_based_task_list_screen.dart';

import '../../features/coordinators/bindings/coordinator_binding.dart';
import '../../features/coordinators/views/coordinator_list_screen.dart';
import '../../features/coordinators/views/coordinator_add_screen.dart';
import '../../features/coordinators/views/coordinator_detail_screen.dart';

import '../../features/suppliers/bindings/supplier_binding.dart';
import '../../features/suppliers/views/supplier_list_screen.dart';
import '../../features/suppliers/views/supplier_add_screen.dart';
import '../../features/suppliers/views/supplier_detail_screen.dart';

import '../screens/error/network_error_screen.dart';
import '../screens/error/server_error_screen.dart';
import '../screens/error/not_found_screen.dart';
import '../screens/settings/api_settings_screen.dart';
import '../../features/suppliers/views/supplier_services_screen.dart';

import '../../features/admin/bindings/admin_binding.dart';
import '../../features/admin/views/roles_management_screen.dart';
import '../../features/admin/views/system_users_screen.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_view.dart';
import '../screens/legal/legal_screen.dart';
import '../screens/legal/legal_constants.dart';


class AppPages 
{
  // We need to check if there is a CoordinatorBinding in the pages or not. Wait, the original pages never had CoordinatorListScreen registered?
  // Let's add CoordinatorAddScreen binding from where it's used or not needed if global.
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(name: AppRoutes.coordinatorAdd, page: () => CoordinatorAddScreen()),
    GetPage(
      name: AppRoutes.home,
      page: () => MainLayoutScreen(),
      binding: MainLayoutBinding(),
    ),
    GetPage(
      name: AppRoutes.services,
      page: () => ServiceListScreen(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: AppRoutes.serviceAdd,
      page: () => ServiceAddScreen(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: AppRoutes.events,
      page: () => EventListScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.eventDetail,
      page: () => EventDetailScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.eventAdd,
      page: () => EventAddScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.eventClientSelection,
      page: () => EventClientSelectionScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: AppRoutes.tasks,
      page: () => const RoleBasedTaskListScreen(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: AppRoutes.taskAdd,
      page: () => TaskAddScreen(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: AppRoutes.taskDetail,
      page: () => TaskDetailScreen(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: AppRoutes.incomes,
      page: () => IncomeListScreen(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.incomeAdd,
      page: () => IncomeAddScreen(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.incomeDetail,
      page: () => const IncomeDetailScreen(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => NotificationListScreen(),
      binding: Get.isRegistered<NotificationBinding>()? 
        Get.find<NotificationBinding>() : 
        NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.clients,
      page: () => ClientListScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: AppRoutes.clientAdd,
      page: () => ClientAddScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: AppRoutes.supplierHome,
      page: () => MainLayoutScreen(),
      binding: MainLayoutBinding(),
    ),
    GetPage(
      name: AppRoutes.suppliers, 
      page: () => SupplierListScreen(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: AppRoutes.supplierDetail, 
      page: () => SupplierDetailScreen(),
      binding: SupplierBinding(),
    ),
    GetPage(name: AppRoutes.supplierAdd, page: () => SupplierAddScreen()),
    GetPage(
      name: AppRoutes.supplierServices, 
      page: () => const SupplierServicesScreen(),
    ),
    GetPage(
      name: AppRoutes.coordinators, 
      page: () => CoordinatorListScreen(),
      binding: CoordinatorBinding(),
    ),
    GetPage(
      name: AppRoutes.coordinatorDetail, 
      page: () => CoordinatorDetailScreen(),
      binding: CoordinatorBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => ReportsScreen(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.supplierReports,
      page: () => const SupplierReportScreen(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.roles,
      page: () => const RolesManagementScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.systemUsers,
      page: () => const SystemUsersScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.clientDetail,
      page: () => const ClientDetailScreen(),
      binding: ClientBinding(),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.networkError,
      page: () => const NetworkErrorScreen(),
    ),
    GetPage(
      name: AppRoutes.serverError,
      page: () => const ServerErrorScreen(),
    ),
    GetPage(
      name: AppRoutes.notFound,
      page: () => const NotFoundScreen(),
    ),
    GetPage(
      name: AppRoutes.supplierServiceSelection,
      page: () => SupplierServiceSelectionScreen(),
      bindings: [
        AuthBinding(),
        ServiceBinding(),
      ],
    ),
    GetPage(
      name: AppRoutes.apiSettings,
      page: () => const ApiSettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const LegalScreen(
        title: LegalConstants.privacyPolicyTitle,
        content: LegalConstants.privacyPolicyContent,
      ),
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const LegalScreen(
        title: LegalConstants.termsConditionsTitle,
        content: LegalConstants.termsConditionsContent,
      ),
    ),
  ];
}
