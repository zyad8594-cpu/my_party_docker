import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_constants.dart';

/// خدمة لتخزين رابط الخادم وتفعيل الاشعارات
/// 
/// يتم استخدامها لتخزين رابط الخادم وتفعيل الاشعارات
class ConfigService extends GetxService {
  /// مفتاح تخزين رابط الخادم
  final _baseUrlKey = 'api_base_url';
  /// مفتاح تخزين تفعيل الاشعارات
  final _notifEnabledKey = 'notifications_enabled';
  /// مفتاح تخزين تفعيل صوت الاشعارات
  final _notifSoundKey = 'notification_sound_enabled';
  /// مفتاح تخزين مسار صوت الاشعارات
  final _notifSoundPathKey = 'notification_sound_path';
  /// مفتاح تخزين اسم صوت الاشعارات
  final _notifSoundNameKey = 'notification_sound_name';
  /// مفتاح تخزين نوع صوت الاشعارات
  final _notifSoundTypeKey = 'notification_sound_type';
  /// - متغير لإدارة تخزين البيانات
  SharedPreferences? _prefs;
  
  /// متغير لتخزين رابط الخادم
  final baseUrl = ''.obs;
  /// متغير لتخزين تفعيل الاشعارات
  final notificationsEnabled = true.obs;
  /// متغير لتخزين تفعيل صوت الاشعارات
  final notificationSoundEnabled = true.obs;
  /// متغير لتخزين مسار صوت الاشعارات
  final notificationSoundPath = ''.obs;
  /// متغير لتخزين اسم صوت الاشعارات
  final notificationSoundName = 'Default'.obs;
  /// متغير لتخزين نوع صوت الاشعارات
  /// 
  /// الأنواع هي: 
  /// - default
  /// - system
  /// - custom
  final notificationSoundType = 'default'.obs;

  /// دالة لتهيئة الخدمة
  /// 
  /// المعاملات:
  /// 
  /// لا يوجد
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<ConfigService>`: 
  Future<ConfigService> init() async 
  {
    _prefs = await SharedPreferences.getInstance();
    
    baseUrl.value = _prefs?.getString(_baseUrlKey) ?? ApiConstants.baseUrl;
    notificationsEnabled.value = _prefs?.getBool(_notifEnabledKey) ?? true;
    notificationSoundEnabled.value = _prefs?.getBool(_notifSoundKey) ?? true;
    notificationSoundPath.value = _prefs?.getString(_notifSoundPathKey) ?? '';
    notificationSoundName.value = _prefs?.getString(_notifSoundNameKey) ?? 'Default';
    notificationSoundType.value = _prefs?.getString(_notifSoundTypeKey) ?? 'default';
    return this;
  }

  /// دالة لتحديث رابط الخادم
  /// 
  /// المعاملات:
  /// 
  /// - `String` newUrl: رابط الخادم الجديد
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>`: 
  Future<void> updateBaseUrl(String newUrl) async 
  {
    if (newUrl.isEmpty) return;
    if (newUrl.endsWith('/')) 
    {
      newUrl = newUrl.substring(0, newUrl.length - 1);
    }
    baseUrl.value = newUrl;
    await _prefs?.setString(_baseUrlKey, newUrl);
  }

  /// دالة لتفعيل الاشعارات
  /// 
  /// المعاملات:
  /// 
  /// - `bool` value: تفعيل الاشعارات
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>`: 
  Future<void> setNotificationsEnabled(bool value) async 
  {
    notificationsEnabled.value = value;
    await _prefs?.setBool(_notifEnabledKey, value);
  }

  /// دالة لتفعيل صوت الاشعارات
  /// 
  /// المعاملات:
  /// 
  /// - `bool` value: تفعيل صوت الاشعارات
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>`: 
  Future<void> setNotificationSoundEnabled(bool value) async 
  {
    notificationSoundEnabled.value = value;
    await _prefs?.setBool(_notifSoundKey, value);
  }

  /// دالة لتحديد صوت الاشعارات
  /// 
  /// المعاملات:
  /// 
  /// - `String` path: مسار صوت الاشعارات
  /// - `String` name: اسم صوت الاشعارات
  /// - `String` type: نوع صوت الاشعارات
  /// 
  /// الإرجاع:
  /// 
  /// - `Future<void>`: 
  Future<void> setNotificationSound(String path, String name, String type) async 
  {
    notificationSoundPath.value = path;
    notificationSoundName.value = name;
    notificationSoundType.value = type;
    await _prefs?.setString(_notifSoundPathKey, path);
    await _prefs?.setString(_notifSoundNameKey, name);
    await _prefs?.setString(_notifSoundTypeKey, type);
  }
}

