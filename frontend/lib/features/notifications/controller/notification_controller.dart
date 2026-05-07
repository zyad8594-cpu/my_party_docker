import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show ScrollController, TextEditingController, Curves;
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../../../core/api/auth_service.dart' show AuthService;
// import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../features/notifications/data/repository/notification_repository.dart' show NotificationRepository;
import '../../../core/utils/utils.dart' show MyPUtils;
import '../../../data/models/notification.dart' show NotificationModel;
import '../../../core/services/socket_service.dart' show SocketService;
import '../../../core/services/config_service.dart' show ConfigService;
import '../../clients/controller/client_controller.dart' show ClientController;
import '../../coordinators/controller/coordinator_controller.dart' show CoordinatorController;
import '../../events/controller/event_controller.dart' show EventController;
import '../../incomes/controller/income_controller.dart' show IncomeController;
import '../../services/controller/service_controller.dart' show ServiceController;
import '../../shared/controllers/base_controller.dart' show BaseGenericController;
import '../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../../tasks/controller/task_controller.dart' show TaskController;

class NotificationController extends GetxController 
{
  final NotificationRepository _repository = Get.find<NotificationRepository>();
  late final SocketService _socketService;
  final ConfigService _configService = Get.find<ConfigService>();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final notifications = <NotificationModel>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final notiNotReadCount = 0.obs;

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final filterStatus = 'all'.obs; // 'all', 'read', 'unread'
  final showHeader = true.obs;
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  final showScrollToTop = false.obs;
  final isSelectionMode = false.obs;
  final selectionModeAction = ''.obs; // 'delete' or 'mark_read'
  final selectedNotificationIds = <int>{}.obs;

  List<NotificationModel> get filteredNotifications {
    final userId = AuthService.user.value.id;
    return notifications.where((n) {
      // فلتر المستخدم
      bool isForMe = (n.userId == userId || n.supplierId == userId);
      if (!isForMe) return false;
      
      bool matchesSearch = true;
      // فلتر صندوق البحث
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        matchesSearch = n.title.toLowerCase().contains(query) || 
                             n.message.toLowerCase().contains(query);
        // if (!matchesSearch) return false;
      }

      // فلتر التأريخ
      bool matchesDate = true;
      DateTime? notificationDate;
      try {
        notificationDate = DateTime.parse(n.createdAt);
      } catch (_) {}

      if (notificationDate != null) {
        if (startDate.value != null) {
          matchesDate = notificationDate.isAtSameMomentAs(startDate.value!) || notificationDate.isAfter(startDate.value!);
        }
        
        if (endDate.value != null) {
          matchesDate = matchesDate && (notificationDate.isAtSameMomentAs(endDate.value!) || notificationDate.isBefore(endDate.value!));
        }
      }

      // فلتر الحالة
      bool matchesStatus = true;
      if (filterStatus.value == 'read') {
        if (!n.isRead) matchesStatus = false;
      } else if (filterStatus.value == 'unread') {
        if (n.isRead) matchesStatus = false;
      }

      return matchesSearch && matchesDate && matchesStatus;
    }).toList();
  }

  @override
  void onInit() {
    _socketService = Get.find<SocketService>();
    
    // Fetch only if already logged in (e.g. app restart with saved token)
    if (AuthService.token.isNotEmpty) {
      fetchNotifications(force: true);
    }

    // React to token changes (Login/Logout)
    ever(AuthService.token, (String token) {
      if (token.isNotEmpty) {
        fetchNotifications(force: true);
      } else {
        notifications.clear();
        notiNotReadCount.value = 0;
      }
    });

    // Listening to notification stream from socket server
    _socketService.onNotification.listen(_handleNewNotification);
    
    // Add Scroll Listener
    scrollController.addListener(_scrollListener);
    super.onInit();
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    try {
      if (scrollController.offset > 300 && !showScrollToTop.value) {
        showScrollToTop.value = true;
      } else if (scrollController.offset <= 300 && showScrollToTop.value) {
        showScrollToTop.value = false;
      }

      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (showHeader.value) showHeader.value = false;
      } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!showHeader.value) showHeader.value = true;
      }
    } catch (_) {}
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchController.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }

  void _handleNewNotification(NotificationModel notification) 
  {
    bool isForMe = (notification.userId != null && notification.userId == AuthService.user.value.id) ||
                   (notification.supplierId != null && notification.supplierId == AuthService.user.value.id);
    
    if (isForMe) {
      bool exists = notifications.any((n) => n.id == notification.id);
      if (!exists) {
        notifications.insert(0, notification);
        if (!notification.isRead) {
          notiNotReadCount.value++;
          _h();
          // Check user preferences from ConfigService
          if (_configService.notificationsEnabled.value) {
            MyPUtils.showSnackbar(notification.title, notification.message, position: SnackPosition.TOP);
            
            // Play sound if enabled
            if (_configService.notificationSoundEnabled.value) {
              _playNotificationSound();
            }
          }
        }
      }
    }
  }

  Future<void> _h() async{
    final ctrl = _getController(Get.currentRoute);
    await Get.forceAppUpdate();
    if(ctrl != null)
    {
        Get.back();
       ctrl.list.refresh();
      
    }
    return;
  }

   BaseGenericController? _getController(String route){
    if(route.contains('coordinator')) return Get.find<CoordinatorController>();
    if(route.contains('supplier')) return Get.find<SupplierController>();
    if(route.contains('client')) return Get.find<ClientController>();
    if(route.contains('event') || route.contains('event-client-selection')) return Get.find<EventController>();
    if(route.contains('task')) return Get.find<TaskController>();
    if(route.contains('income')) return Get.find<IncomeController>();
    if(route.contains('service')) return Get.find<ServiceController>();
    return null;
  }
  
  Future<void> _playNotificationSound() async {
    if (!_configService.notificationSoundEnabled.value) return;

    try {
      final type = _configService.notificationSoundType.value;
      final path = _configService.notificationSoundPath.value;

      if (type == 'custom' && path.isNotEmpty) {
        // Play custom file picked by user
        await _audioPlayer.play(DeviceFileSource(path));
      } else if (type == 'system' && path.isNotEmpty) {
        // Play system sound by URI (common on Android)
        await _audioPlayer.play(UrlSource(path));
      } else {
        // Default behavior: custom asset or fallback to system notification
        try {
          await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
        } catch (e) {
          await FlutterRingtonePlayer().play(
            android: AndroidSounds.notification,
            ios: IosSounds.glass,
            looping: false,
            volume: 1.0,
          );
        }
      }
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
    }
  }

  /// Fetches notifications from repository
  Future<void> fetchNotifications({bool force = false}) async {
    if (AuthService.token.isEmpty) return;
    if (!force && notifications.isNotEmpty) return;
    
    try {
      isLoading.value = true;
      final result = await _repository.getAll();
      notifications.assignAll(result);
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notiNotReadCount.value = notifications.where((notification) => !notification.isRead).length;
    } catch (e) {
      MyPUtils.showSnackbar('خطاء', '$e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        if (notiNotReadCount.value > 0) {
          notiNotReadCount.value--;
        }
      }
    } catch (e) {
      MyPUtils.showSnackbar('Error', 'Failed to mark notification as read', isError: true);
    }
  }

  /// Clears all notifications (matches repository.clearAll)
  Future<void> clearAll() async {
    try {
      await _repository.clearAll();
      notifications.clear();
      notiNotReadCount.value = 0;
    } catch (e) {
      MyPUtils.showSnackbar('Error', 'Failed to clear all notifications', isError: true);
    }
  }

  /// Marks all as read (if needed by UI)
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      fetchNotifications(force: true);
    } catch (e) {
      MyPUtils.showSnackbar('Error', 'Failed to mark all as read', isError: true);
    }
  }

  /// Deletes a specific notification
  Future<void> deleteNotification(int id) async {
    try {
      await _repository.delete(id);
      notifications.removeWhere((n) => n.id == id);
      notiNotReadCount.value = notifications.where((n) => !n.isRead).length;
      selectedNotificationIds.remove(id);
    } catch (e) {
      MyPUtils.showSnackbar('Error', 'Failed to delete notification', isError: true);
    }
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      cancelSelectionMode();
    }
  }

  void startSelectionMode(String action, List<int> allIds) {
    selectionModeAction.value = action;
    isSelectionMode.value = true;
    selectedNotificationIds.assignAll(allIds);
  }

  bool cancelSelectionMode() {
    if(isSelectionMode.value){
      isSelectionMode.value = false;
      selectedNotificationIds.clear();
      selectionModeAction.value = '';
      return true;
    }
    return false;
  }

  void toggleNotificationSelection(int id) {
    if (selectedNotificationIds.contains(id)) {
      selectedNotificationIds.remove(id);
    } else {
      selectedNotificationIds.add(id);
    }
  }

  void toggleSelectAll(List<int> allIds) {
    if (selectedNotificationIds.length == allIds.length) {
      selectedNotificationIds.clear();
    } else {
      selectedNotificationIds.assignAll(allIds);
    }
  }

  Future<void> deleteSelectedNotifications() async {
    if (selectedNotificationIds.isEmpty) return;

    try {
      isLoading.value = true;
      final idsToDelete = selectedNotificationIds.toList();
      
      for (final id in idsToDelete) {
        await _repository.delete(id);
      }
      
      notifications.removeWhere((n) => idsToDelete.contains(n.id));
      notiNotReadCount.value = notifications.where((n) => !n.isRead).length;
      
      selectedNotificationIds.clear();
      isSelectionMode.value = false;
      selectionModeAction.value = '';
      
      MyPUtils.showSnackbar('نجاح', 'تم مسح الإشعارات المحددة بنجاح');
    } catch (e) {
      MyPUtils.showSnackbar('خطأ', 'فشل في مسح الإشعارات: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markSelectedAsRead() async {
    if (selectedNotificationIds.isEmpty) return;

    try {
      isLoading.value = true;
      final idsToMark = selectedNotificationIds.toList();
      
      for (final id in idsToMark) {
        await _repository.markAsRead(id);
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
        }
      }
      
      notiNotReadCount.value = notifications.where((n) => !n.isRead).length;
      
      selectedNotificationIds.clear();
      isSelectionMode.value = false;
      selectionModeAction.value = '';
      
      MyPUtils.showSnackbar('نجاح', 'تم تمييز الإشعارات المحددة كمقروءة بنجاح');
    } catch (e) {
      MyPUtils.showSnackbar('خطأ', 'فشل في مسح الإشعارات: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
}
