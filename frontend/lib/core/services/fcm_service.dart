import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../api/api_constants.dart';
import '../../data/models/user.dart';
import '../api/auth_service.dart';
import '../api/api_service.dart';
import '../utils/utils.dart' show MyPUtils;

/// دالة لمعالجة الاشعارات في الخلفية
/// 
/// يجب أن تكون هذه الوظيفة من المستوى الأعلى أو ثابتة (كما هو مطلوب من قبل FCM)
/// 
/// المعاملات:
/// 
/// - `RemoteMessage` message: رسالة الاشعارات
/// 
/// الإرجاع:
/// 
/// - `Future<void>`: 
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /// إذا كنت ستستخدم خدمات Firebase أخرى في الخلفية، مثل Firestore,
  /// تأكد من استدعاء `await Firebase.initializeApp()` إذا كان ذلك مطلوبًا من قبل المنصة.
  debugPrint("Handling a background message: ${message.messageId}");
}

/// خدمة لإدارة إشعارات Firebase Cloud Messaging
/// 
/// يتم استخدامها لإدارة إشعارات Firebase Cloud Messaging
class FCMService extends GetxService {
  /// متغير لتخزين إشعارات Firebase Cloud Messaging
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  /// دالة لتهيئة الخدمة
  /// 
  /// المعاملات:
  /// 
  /// لا يوجد
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<FCMService>`: ترجع الخدمة بعد تهيئتها
  Future<FCMService> init() async 
  {
    /// طلب أذونات iOS/Android 13+
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    /// التحقق من حالة الأذونات
    if (settings.authorizationStatus == AuthorizationStatus.authorized) 
    {
      debugPrint('✅ FCMService: إذن الإشعارات ممنوح.');
    } 
    else 
    {
      debugPrint('⚠️ FCMService: إذن الإشعارات مرفوض أو لم يُمنح.');
    }

    /// إظهار إشعار منبثق حتى عندما يكون التطبيق في المقدمة (Android فقط)
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    /// تعيين قناة الإشعارات الافتراضية (يجب أن تتطابق مع AndroidManifest)
    /// 
    /// يضمن هذا ظهور الإشعارات في القناة الصحيحة على Android 8+
    await _fcm.setAutoInitEnabled(true);

    /// معالجة الإشعارات داخل التطبيق (في المقدمة)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) 
    {
      debugPrint('🔔 FCMService: رسالة جديدة وهو مفتوح!');
      if (message.notification != null && AuthService.user.id == message.data['user_id']) 
      {
        MyPUtils.showSnackbar(
          message.notification!.title ?? 'إشعار جديد',
          message.notification!.body ?? '',
          position: SnackPosition.TOP,
        );
      }
    });

    /// معالجة فتح التطبيق عبر الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) 
    {
      debugPrint('📲 FCMService: فتح التطبيق عبر الإشعار: ${message.notification?.title}');
      // Navigate to notifications screen if needed
      // Get.toNamed(AppRoutes.notifications);
    });

    /// تحديث التوكن تلقائياً عند التهيئة إذا كان المستخدم مسجلاً
    if (AuthService.token.isNotEmpty) 
    {
      await updateTokenOnBackend();
    }

    return this;
  }

  /// دالة للحصول على توكن FCM
  /// 
  /// المعاملات:
  /// 
  /// لا يوجد
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<String?>`: توكن FCM
  Future<String?> getToken() async {
    try 
    {
      String? token = await _fcm.getToken();
      debugPrint("توكن FCM: $token");
      return token;
    } 
    catch (e) 
    {
      debugPrint("خطأ في الحصول على توكن FCM: $e");
      return null;
    }
  }

  /// دالة للحصول على نوع الجهاز
  /// 
  /// المعاملات:
  /// 
  /// لا يوجد
  /// 
  /// الإرجاع:
  /// 
  /// - `String`: نوع الجهاز
  String _getDeviceType() {
   if(GetPlatform.isAndroid)return 'android';
   if(GetPlatform.isIOS) return 'ios';
   if(GetPlatform.isWeb) return 'web';
   if(GetPlatform.isLinux) return 'linux';
   if(GetPlatform.isWindows) return 'windows';
   if(GetPlatform.isMacOS) return 'macos';
   if(GetPlatform.isFuchsia) return 'fuchsia';
   if(GetPlatform.isMobile) return 'mobile';
   if(GetPlatform.isDesktop) return 'desktop';
   return 'unknown';
  }

  /// دالة لتحديث توكن FCM في الخادم
  /// 
  /// المعاملات:
  /// 
  /// لا يوجد
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>`: 
  Future<void> updateTokenOnBackend() async 
  {
    if (AuthService.token.isEmpty) return;
    
    String? token = await getToken();
    if (token != null) 
    {
      final apiService = Get.find<ApiService>();
      try {
        final url = '${ApiConstants.baseUrl}${ApiEndpoints.fcmToken}';
        debugPrint("🚀 FCMService: جاري تسجيل التوكن على: $url");
        
        await apiService.post(url, data: {
          'fcm_token': token,
          'device_type': _getDeviceType(),
        });
        debugPrint("✅ FCMService: تم تسجيل توكن FCM في الخادم بنجاح.");
      } 
      catch (e) 
      {
        debugPrint("❌ FCMService: فشل تسجيل التوكن في الخادم: $e");
      }
    }
  }
  /// دالة لمسح توكن FCM من الخادم
  /// 
  /// المعاملات:
  /// 
  /// لا يوجد
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>`: 
  Future<void> clearTokenOnBackend() async {
    if (AuthService.token.isEmpty) return;
    
    String? token = await getToken();
    if (token != null) 
    {
      final apiService = Get.find<ApiService>();
      try {
        /// استخدم بيانات مخصصة للحذف إذا كان ذلك مدعومًا، ولكن عادةً لا يتم استخدام البيانات للحذف.
        /// 
        /// يتوقع النظام الخلفي ذلك في نص الطلب لتبسيط الأمر، لذلك نستخدم طلب POST أو نقوم بتحديث النظام الخلفي لاستخدام المعاملات.
        /// 
        /// في الواقع، مسار النظام الخلفي لدينا هو router.delete('/fcm-token', ... clientController.removeFCMToken);
        /// 
        /// و removeFCMToken يتوقع ذلك في req.body.
        /// 
        /// و Dio delete القياسي يدعم البيانات.
        await apiService.delete('${ApiConstants.baseUrl}${ApiEndpoints.fcmToken}', data: {'fcm_token': token});
        debugPrint("تم حذف توكن FCM من الخادم بنجاح.");
      } 
      catch (e) 
      {
        debugPrint("فشل حذف توكن FCM من الخادم: $e");
      }
    }
  }

}
