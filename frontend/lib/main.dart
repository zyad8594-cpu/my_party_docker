import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routes/app_pages.dart' show AppPages;
import 'core/routes/app_routes.dart' show AppRoutes;
import 'core/api/api_service.dart' show ApiService;
import 'core/api/auth_service.dart' show AuthService;
import 'core/themes/app_theme.dart' show AppTheme;
import 'features/auth/provider/auth_provider.dart' show AuthProvider;
import 'features/auth/data/repository/auth_repository.dart' show AuthRepository;
import 'core/themes/theme_service.dart' show ThemeService;
import 'core/services/config_service.dart' show ConfigService;
import 'core/services/global_monitor_service.dart' show GlobalMonitorService;
import 'core/services/socket_service.dart' show SocketService;
import 'features/notifications/controller/notification_controller.dart';
import 'core/controllers/network_controller.dart';
import 'features/notifications/data/repository/notification_repository.dart';
import 'features/notifications/provider/notification_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/fcm_service.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  final themeService = await ThemeService().init();
  Get.put(themeService);
  final configService = await ConfigService().init();
  Get.put(configService);
  await initServices();
  runApp(MyApp(themeService: themeService));
}

Future<void> initServices() async {
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => ApiService().init());
  await Get.putAsync(() => GlobalMonitorService().init());
  Get.put(SocketService(), permanent: true);
  await Get.putAsync(() => FCMService().init());
  
  // Global Auth Services
  Get.put(AuthProvider(), permanent: true);
  Get.put(AuthRepository(), permanent: true);
  
  Get.put(NotificationProvider(), permanent: true);
  Get.put(NotificationRepository(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  Get.put(NetworkController(), permanent: true);
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام إدارة المناسبات',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.theme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      locale: const Locale('ar', 'AE'),
      fallbackLocale: const Locale('ar', 'AE'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'AE')],
    );
  }
}
