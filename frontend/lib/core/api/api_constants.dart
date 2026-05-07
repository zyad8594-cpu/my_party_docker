import '../config/config.dart' show Config;

class ApiConstants 
{
  static const urls = [
    'http://192.168.1.5:3000/api',
    'http://localhost:3000/api',
    'http://192.168.1.3:3000/api',
    'http://192.168.43.39:3000/api'
  ];

  static final String baseUrl = urls[2]; // عنوان الـ IP المحلي للوصول من أجهزة أخرى
  
  static const String userAgent = '${Config.APP_NAME}/${Config.APP_VERSION}';
  
}

// Endpoints
class ApiEndpoints
{
  static const  auth = '/auth',
                login = '$auth/login',
                register = '$auth/register';
  static const  users = '/users',
                fcmToken = '$users/fcm-token',
                userChangePassword = '$users/change-password',
                usersByRole = '$users/role',
                notifications = '$users/notifications',
                notificationsReadAll = '$users/notifications-read-all',
                notificationsClear = '$users/notifications-clear';

  static const coordinators = '/coordinators';
  static const  suppliers = '/suppliers',
                suppliersWithCoordinatorRating = '$suppliers/rated-by-coordinator';

  static const  services = '/services',
                serviceRequests = '$services/requests';
  
  static const clients = '/clients';
  static const events = '/events';
  static const tasks = '/tasks';
  static const incomes = '/incomes';
  
  
  static const dashboard = '/dashboard';
  static const systemUsers = '/system_users';

  
}

// SharedPreferences keys
class ApiKeys
{
  static const String tokenKey = 'token';
  static const String userKey = 'user';
}