// socket_service.dart
// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async'; // لاستخدام StreamController و Timer
import 'package:flutter/foundation.dart';
import 'package:get/get.dart'; // لاستخدام GetxService و GetxController
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../api/api_constants.dart' show ApiConstants; // استيراد مكتبة Socket.IO مع اسم مستعار IO
import '../../data/models/notification.dart' show NotificationModel;
import '../api/auth_service.dart' show AuthService;
import '../routes/app_routes.dart' show AppRoutes;

/// خدمة مراقبة شاملة
class SocketService extends GetxService {
  /// 1. تعريف الكائن الأساسي للـ Socket
  /// 
  /// علامة الاستفهام '?' تعني أن هذا المتغير يمكن أن يكون null في البداية
  final _socket = Socket();

  /// 2. StreamController لنشر الإشعارات الواردة إلى أي جزء في التطبيق
  /// 
  /// هذا هو "الأنبوب" الذي ستتدفق من خلاله البيانات.
  final  _notificationController = StreamController<NotificationModel>.broadcast(); // .broadcast() يسمح لمستمعين متعددين بالاشتراك

  /// 3. Getter عام (General Getter) للوصول إلى الـ Stream والاستماع للإشعارات
  /// 
  /// هذا ما ستستخدمه في واجهاتك لاستقبال البيانات فوراً.
  Stream<NotificationModel> get onNotification => _notificationController.stream;

  /// --- دورة حياة الخدمة (Service Lifecycle) ---

  /// 4. تُستدعى هذه الدالة تلقائياً عند بدء تشغيل الخدمة (عند استخدام Get.put)
  /// 
  /// إنها تشبه دالة onInit في GetxController، وهي مثالية لتهيئة الاتصال.
  @override
  void onInit() 
  {
    super.onInit();
    
    /// التفاعل مع تغييرات ال token (Login/Logout)
    ever(AuthService.token, (String token) {
      if (token.isNotEmpty) _connectToSocket();
      else _disconnectSocket();
    });

    // Initial connection attempt if already logged in
    if (AuthService.token.isNotEmpty) _connectToSocket();

    /// انضمام للغرفة الخاصة عند تغيير المستخدم أو عند الاتصال
    ever(AuthService.user, (user) {
      if (user.id != 0 && _socket.connected) {
        emitEvent('join-room', user.id);
      }
    });
  }

  // --- دوال الخدمة الأساسية (Core Service Methods) ---

  /// 5. دالة خاصة (private) مسؤولة عن إنشاء وإعداد الاتصال
  void _connectToSocket() 
  {
    if (AuthService.token.isEmpty) return;
    try { if (_socket.connected) return; } 
    catch (e) 
    {
      /* إذا لم يتم تهيئة المتغير _socket المتأخر، فسيتم طرح خطأ. يمكننا المتابعة لتهيئته. */ 

      // عنوان الخادم الخاص بك. استخدم 10.0.2.2 للمحاكي، أو IP جهازك الحقيقي للاختبار على جهاز حقيقي.

      _socket.assign(
        transports: ['websocket'],
        autoConnect: false, 
        reconnection: true, 
        reconnectionAttempts: 5, 
        reconnectionDelay: 2000, 
        enableForceNewConnection: true, 

      ).
      on(
        connect: (_) {
          debugPrint('✅ SocketService: متصل بالخادم بنجاح. معرف الجلسة: ${_socket.id}');
          if (AuthService.user.value.id != 0) {
            emitEvent('join-room', AuthService.user.value.id);
          }
        },
        disconnect:(_) => debugPrint('⚠️ SocketService: تم قطع الاتصال بالخادم.'),
        connectError:(data) => debugPrint('❌ SocketService: خطأ في الاتصال: $data'),
        reconnect:(attempt) => debugPrint('🔄 SocketService: تمت إعادة الاتصال بعد محاولة رقم $attempt.'),
        newNotification:(data) {
          debugPrint('🔔 SocketService: تم استلام إشعار جديد: $data');

          NotificationModel.addTo(
            // _notificationController, 
            data: data,
            call: (noti){
              _notificationController.add(noti);
              final ty = (noti.type ?? '');
              if(ty.contains('create') || ty.contains('update') || ty.contains('edit'))
              {
               if(
                  [AppRoutes.coordinatorAdd, 
                    AppRoutes.supplierAdd, 
                    AppRoutes.clientAdd, 
                    AppRoutes.eventAdd, 
                    // AppRoutes.taskAdd, 
                    AppRoutes.incomeAdd, 
                    AppRoutes.serviceAdd,
                    AppRoutes.eventClientSelection,
                  ].contains(Get.currentRoute)
                )
                {
                  Get.back();
                  
                }
              }
              
            },
            socketError: (data, e) => debugPrint('⚠️ SocketService: تنسيق بيانات غير متوقع: $data'),
          );
        }
      ).
      // أخيراً، نقوم بتشغيل الاتصال يدوياً
      connect(()=> debugPrint('SocketService: جاري محاولة الاتصال بالخادم...'));

    }
  }


  /// 6. دالة خاصة لقطع الاتصال بشكل نظيف
  void _disconnectSocket() 
  {
    try {
      // بما أن _socket متأخرة، فإن التحقق من حالتها مباشرةً قد يؤدي إلى حدوث خطأ إذا لم يتم تهيئتها مطلقًا
      _socket.disconnect().dispose(
        ()=> debugPrint('SocketService: تم قطع الاتصال وتحرير موارد الـ Socket.')
      );
    } 
    catch (e) { /* تجاهل إذا لم يتم التهيئة */ }

  }

  /// 7. دالة عامة (public) تسمح للواجهات بإرسال رسائل إلى الخادم عند الحاجة
  /// 
  /// على سبيل المثال، قد ترغب في إرسال تأكيد بقراءة الإشعار.
  void emitEvent(String eventName, dynamic data) {
    if (_socket.connected) 
    {
      _socket.emit(eventName, data: data, 
        afterEmit: ()=>debugPrint('SocketService: تم إرسال حدث "$eventName" إلى الخادم.')
      );
    } 
    else {
      debugPrint('⚠️ SocketService: لا يمكن إرسال الحدث، الاتصال غير متاح.');
    }
  }


  /// 8. تُستدعى هذه الدالة تلقائياً عند إتلاف الخدمة (عند إغلاق التطبيق)
  /// 
  /// إنها تشبه دالة onClose، ونستخدمها لتنظيف الاتصالات.
  @override
  void onClose() 
  {
    _disconnectSocket(); 
    _notificationController.close();
    super.onClose();
  }
  
}


class Socket
{
  // 1. تعريف الكائن الأساسي للـ Socket
  // علامة الاستفهام '?' تعني أن هذا المتغير يمكن أن يكون null في البداية
  late IO.Socket _socket;
  bool get connected => _socket.connected;
  String? get id => _socket.id;

  Socket([dynamic opts])
  {
    if(opts is Map<String, dynamic>)
    {
      if(opts.containsKey('uri') && opts['uri'] != null)
      {
        this._socket = IO.io(opts.remove('uri'), opts);
      }
    }
  }

  factory Socket.io(dynamic uri, {
    List<String>? transports, 
    bool? autoConnect, 
    bool? reconnection, 
    int? reconnectionAttempts, 
    int? reconnectionDelay, 
    bool? enableForceNewConnection,
    Map<String, dynamic>? opts,
  })=> Socket({ 
    'uri': uri,
    if(transports != null) 'transports': transports, 
    if(autoConnect != null) 'autoConnect': autoConnect, 
    if(reconnection != null) 'reconnection': reconnection, 
    if(reconnectionAttempts != null) 'reconnectionAttempts': reconnectionAttempts, 
    if(reconnectionDelay != null) 'reconnectionDelay': reconnectionDelay, 
    if(enableForceNewConnection != null) 'enableForceNewConnection': enableForceNewConnection, 
    if(opts != null) ...opts,
  });

  /// تهيئة وإعداد كائن Socket.IO
  /// 
  /// ------------------------------------------------------------------------------
  /// 
  /// transports: ['websocket'] -> يجبر الاتصال على استخدام بروتوكول WebSocket فقط.
  /// هذا هو الخيار الأمثل للأداء العالي على الأجهزة المحمولة.
  /// 
  /// autoConnect: false -> نتحكم يدوياً في الاتصال بعد الإعداد.
  /// 
  /// reconnection: true -> تفعيل إعادة الاتصال التلقائي في حالة فقدان الشبكة.
  /// 
  /// reconnectionAttempts: 5 -> عدد محاولات إعادة الاتصال قبل الاستسلام.
  /// 
  /// reconnectionDelay: 2000 -> الوقت (بالمللي ثانية) بين كل محاولة إعادة اتصال.
  /// 
  /// enableForceNewConnection: true -> تفعيل الاتصال الجديد بالقوة.
  Socket assign({
    
    List<String>? transports, 
    bool? autoConnect, 
    bool? reconnection, 
    int? reconnectionAttempts, 
    int? reconnectionDelay, 
    bool? enableForceNewConnection,
    Map<String, dynamic>? opts,
  }){
    _socket = IO.io(
      ApiConstants.baseUrl.endsWith('/api')? 
            ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 4) : 
            ApiConstants.baseUrl, {
      if(transports != null) 'transports': transports, 
      if(autoConnect != null) 'autoConnect': autoConnect, 
      if(reconnection != null) 'reconnection': reconnection, 
      if(reconnectionAttempts != null) 'reconnectionAttempts': reconnectionAttempts, 
      if(reconnectionDelay != null) 'reconnectionDelay': reconnectionDelay, 
      if(enableForceNewConnection != null) 'enableForceNewConnection': enableForceNewConnection, 
      if(opts != null) ...opts,
    });
    return this;
  }
  
  /// مستمع للاتصال الناجح
  set onConnect(dynamic Function(dynamic) handle) => _socket.on('connect', handle);
  /// مستمع لحدث انقطاع الاتصال
  set onDisconnect(dynamic Function(dynamic) handle) => _socket.on('disconnect', handle);
  /// مستمع لأي خطأ في الاتصال
  set onConnectError(dynamic Function(dynamic) handle) => _socket.on('connect_error', handle);
  
  // set onConnectTimeout(dynamic Function(dynamic) handle) => _socket.on('connect_timeout', handle);
  // set onDisconnecting(dynamic Function(dynamic) handle) => _socket.on('disconnecting', handle);
  // set onDisconnectError(dynamic Function(dynamic) handle) => _socket.on('disconnect_error', handle);
  
  /// مستمع لعملية إعادة الاتصال (عند نجاح المحاولة)
  set onReconnect(dynamic Function(dynamic) handle) => _socket.on('reconnect', handle);
  
  // set onReconnecting(dynamic Function(dynamic) handle) => _socket.on('reconnecting', handle);
  // set onReconnectError(dynamic Function(dynamic) handle) => _socket.on('reconnect_error', handle);
  // set onReconnectFailed(dynamic Function(dynamic) handle) => _socket.on('reconnect_failed', handle);
  
  /// *** المستمع الأهم: هذا هو الذي سيستقبل الإشعارات الجديدة من قاعدة البيانات ***
  /// نفترض أن الخادم يرسل الإشعارات عبر حدث اسمه 'new-notification'
  set onNewNotification(dynamic Function(dynamic) handle) => _socket.on('new-notification', handle);


  /// --- ربط مستمعي الأحداث (Event Listeners) ---
  /// 
  /// هذه هي "المستمعات" التي تنتظر حدوث أحداث معينة من الخادم.
  /// 
  /// ---------------------------------------------------------------
  /// 
  /// connect: مستمع للاتصال الناجح
  /// 
  /// disconnect: مستمع لحدث انقطاع الاتصال
  /// 
  /// connectError: مستمع لأي خطأ في الاتصال
  /// 
  /// reconnect: مستمع لعملية إعادة الاتصال (عند نجاح المحاولة)
  /// 
  /// newNotification: مستمع للإشعارات الجديدة
  Socket on({
    dynamic Function(dynamic)? connect,
    dynamic Function(dynamic)? disconnect,
    dynamic Function(dynamic)? connectError,
    // dynamic Function(dynamic)? connectTimeout,
    // dynamic Function(dynamic)? disconnecting,
    dynamic Function(dynamic)? disconnectError,
    dynamic Function(dynamic)? reconnect,
    // dynamic Function(dynamic)? reconnecting,
    // dynamic Function(dynamic)? reconnectError,
    // dynamic Function(dynamic)? reconnectFailed,
    dynamic Function(dynamic)? newNotification,
  }){
    if(connect != null) onConnect = connect;
    if(disconnect != null) onDisconnect = disconnect;
    if(connectError != null) onConnectError = connectError;
    if(reconnect != null) onReconnect = reconnect;
    if(newNotification != null) onNewNotification = newNotification;

    return this;
  }

  Socket connect([void Function()? func]){
    _socket.connect();
    if(func != null) func();
    return this;
  }

  Socket disconnect([void Function()? func]){
     _socket.disconnect();
     if(func != null) func();
     return this;
  }

  Socket dispose([void Function()? func]){
    _socket.dispose();
    if(func != null) func();
    return this;
  }

  Socket emit(String event, {data, void Function()? afterEmit})
  {
    _socket.emit(event, data);
    if(afterEmit != null) afterEmit();
    return this;
  }

}

