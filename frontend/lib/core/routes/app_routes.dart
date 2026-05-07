abstract class AppRoutes 
{
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const forgotPassword = '/forgot-password';
  static const coordinators = '/coordinators';
  static const coordinatorAdd = '/coordinators/add';
  static const coordinatorDetail = '/coordinators/detail';
  static const suppliers = '/suppliers';
  static const supplierAdd = '/suppliers/add';
  static const supplierDetail = '/suppliers/detail';
  static const supplierServices = '/supplier-services';
  static const services = '/services';
  static const serviceAdd = '/services/add';
  static const clients = '/clients';
  static const clientAdd = '/clients/add';
  static const events = '/events';
  static const eventAdd = '/events/add';
  static const eventClientSelection = '/events/client-selection';
  static const eventDetail = '/events/detail';
  static const tasks = '/tasks';
  static const taskAdd = '/tasks/add';
  static const taskDetail = '/tasks/detail';
  static const incomes = '/incomes';
  static const incomeAdd = '/incomes/add';
  static const incomeDetail = '/incomes/detail';
  static const notifications = '/notifications';
  static const supplierHome = '/supplier-home';
  static const reports = '/reports';
  static const supplierReports = '/reports/supplier';
  static const clientDetail = '/clients/detail';
  static const profile = '/profile';
  static const roles = '/admin/roles';
  static const systemUsers = '/admin/users';
  
  // شاشات الأخطاء
  static const networkError = '/error/network';
  static const serverError = '/error/server';
  static const notFound = '/error/not-found';
  static const supplierServiceSelection = '/auth/supplier-services';
  static const apiSettings = '/settings/api';
  static const privacyPolicy = '/legal/privacy';
  static const termsConditions = '/legal/terms';

  static bool requireAuth(String route) => switch(route)
  {
    AppRoutes.splash => false,
    AppRoutes.login => false,
    AppRoutes.register => false, 
    AppRoutes.forgotPassword   => false,

    AppRoutes.serverError => false,
    AppRoutes.notFound => false,
    AppRoutes.supplierServiceSelection => false,
    AppRoutes.apiSettings => false,
    AppRoutes.privacyPolicy => false,
    AppRoutes.termsConditions => false,
    _ => true,
  };
}
