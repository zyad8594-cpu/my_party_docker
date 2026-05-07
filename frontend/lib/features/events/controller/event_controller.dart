// import 'dart:convert' show jsonDecode;
import 'dart:io' show File;
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart' show debugPrint, Theme, Icons, Icon;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;
import '../../../data/models/user.dart';
// import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
// import '../../../../core/api/api_constants.dart' show ApiKeys;
import '../../../../core/api/auth_service.dart';
import '../../../../core/controllers/network_controller.dart';
import '../../../../core/utils/status.dart';
import '../../../../core/utils/utils.dart' show MyPUtils;
// import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../../core/themes/app_colors.dart' show AppColors;
// import '../../clients/controller/client_controller.dart' show ClientController;
// import '../../clients/data/models/client.dart' show Client;
import '../../shared/controllers/base_controller.dart';
import '../data/models/event.dart' show Event;
import '../data/repository/event_repository.dart' show EventRepository;

class EventController extends BaseGenericController<Event> 
{
  @override
  final EventRepository repository = Get.find<EventRepository>();

  
  final selectedStatus = 'الكل'.obs;
  final selectedFilterTab = 'كل المهام'.obs;
  final selectedFilterBudget = 'الدفعات'.obs;
  final selectedEvent = Rxn<Event>();
  
  Event? _initialEvent;

  // Reactive state for Event Add/Edit
  final eventNameRx = ''.obs;
  final locationRx = ''.obs;
  final descriptionRx = ''.obs;
  final budgetRx = 0.0.obs;
  final dateRx = DateTime.now().obs;
  final durationRx = 1.obs;
  final durationUnitRx = 'DAY'.obs;
  final clientIdRx = 0.obs;

  final eventImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  /// Compatibility getter
  List<Event> get events => list;

  

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      eventImage.value = File(image.path);
    }
  }

  List<Event> get filteredEvents {
    return getFilteredList((e, query) {
      final matchCoordinator = AuthService.userIsSupplier || e.coordinatorId == AuthService.user.value.id;
      final matchesSearch =
          e.eventName.toLowerCase().contains(query) ||
          (e.location?.toLowerCase().contains(query) ?? false);
      
      bool matchesStatus = true;
      if (selectedStatus.value != 'الكل' && selectedStatus.value != 'محذوفة') {
        matchesStatus = e.status.tryText() == selectedStatus.value;
      }
      
      return matchesSearch && matchesStatus && matchCoordinator;
    });
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to reconnection
    if (Get.isRegistered<NetworkController>()) {
      ever(Get.find<NetworkController>().onReconnected, (_) {
        if (list.isEmpty) {
          fetchAll(force: true);
        }
      });
    }
  }

  void clearFields() {
    eventNameRx.value = '';
    locationRx.value = '';
    descriptionRx.value = '';
    budgetRx.value = 0.0;
    dateRx.value = DateTime.now();
    durationRx.value = 1;
    durationUnitRx.value = 'DAY';
    clientIdRx.value = 0;
    eventImage.value = null;
  }

  void populateFields(Event event) {
    eventNameRx.value = event.eventName;
    locationRx.value = event.location ?? '';
    descriptionRx.value = event.description ?? '';
    budgetRx.value = event.budget;
    dateRx.value = DateTime.tryParse(event.eventDate) ?? DateTime.now();
    durationRx.value = event.eventDuration;
    
    final unit = event.eventDurationUnit.toUpperCase();
    durationUnitRx.value = ['DAY', 'WEEK', 'MONTH'].contains(unit) ? unit : 'DAY';
    
    clientIdRx.value = event.clientId;
     
    _initialEvent = event;
  }

  Future<void> fetchEvent(int id) async {
    isLoading.value = true;
    final result = await repository.getById(id);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (event) => selectedEvent.value = event,
    );
    isLoading.value = false;
  }

  Future<void> create() async {
    if(isLoading.value) return;
    if (eventNameRx.value.isEmpty) {
        return MyPUtils.showSnackbar(
          'تنبيه',
          'يرجى إدخال اسم المناسبة',
          position: SnackPosition.TOP,
          icon: Icon(Icons.warning_amber_rounded, color: AppColors.accent.getByBrightness(Theme.of(Get.context!).brightness)),
        );
      }
    if (clientIdRx.value <= 0) {
      return MyPUtils.showSnackbar(
        'تنبيه',
        'يرجى اختيار العميل',
        position: SnackPosition.TOP,
        icon: Icon(Icons.warning_amber_rounded, color: AppColors.accent.getByBrightness(Theme.of(Get.context!).brightness)),
      );
    }
    isLoading.value = true;
    final result = await repository.create(dio.FormData.fromMap({
      'client_id': clientIdRx.value,
      'coordinator_id': AuthService.user.id,
      'event_name': eventNameRx.value,
      'description': descriptionRx.value,
      'event_date': dateRx.value.toIso8601String(),
      'event_duration': durationRx.value,
      'event_duration_unit': durationUnitRx.value,
      'location': locationRx.value,
      'budget': budgetRx.value,
      if (eventImage.value != null) 'img_url': await dio.MultipartFile.fromFile(
        eventImage.value!.path,
        filename: eventImage.value!.path.split('/').last,
      )
    }));
    final res = result.fold(
      (error) {
        debugPrint('❌ event creation failed: ${error.message}');
        MyPUtils.showSnackbar('خطأ', error.message, isError: true);
        return false;
      },
      (newEvent) {
        list.add(newEvent);

        // MyPUtils.showSnackbar('نجاح', 'تم إضافة المناسبة بنجاح');
        clearFields();
        return true;
      },
    );
    // await Future.delayed(const Duration(milliseconds: 1500), () {
      if(res) Get.back();
      isLoading.value = false;
    // });
    
    
  }

  Future<void> updateEvent(int id) async {
    if(isLoading.value) return;
    if (eventNameRx.value.isEmpty) {
        return MyPUtils.showSnackbar(
          'تنبيه',
          'يرجى إدخال اسم المناسبة',
          position: SnackPosition.TOP,
          icon: Icon(Icons.warning_amber_rounded, color: AppColors.accent.getByBrightness(Theme.of(Get.context!).brightness)),
        );
      }
    if (_initialEvent != null) {
      bool isChanged = eventNameRx.value != _initialEvent!.eventName ||
                       locationRx.value != (_initialEvent!.location ?? '') ||
                       descriptionRx.value != (_initialEvent!.description ?? '') ||
                       budgetRx.value != _initialEvent!.budget ||
                       durationRx.value != _initialEvent!.eventDuration ||
                       durationUnitRx.value != _initialEvent!.eventDurationUnit.toUpperCase() ||
                       clientIdRx.value != _initialEvent!.clientId ||
                       eventImage.value != null;
      
      if (!isChanged) {
        final initialDate = DateTime.tryParse(_initialEvent!.eventDate);
        if (initialDate?.toIso8601String() != dateRx.value.toIso8601String()) {
          isChanged = true;
        }
      }

      if (!isChanged) {
        return Get.back();
      }
    }
    isLoading.value = true;

    // final event = list.firstWhereOrNull((e) => e.id == id);
    final result = await repository.update(
      id, 
      dio.FormData.fromMap({
        'client_id': clientIdRx.value,
        'event_name': eventNameRx.value,
        'description': descriptionRx.value,
        'event_date': dateRx.value.toIso8601String(),
        'event_duration': durationRx.value,
        'event_duration_unit': durationUnitRx.value,
        'location': locationRx.value,
        'budget': budgetRx.value,
        // 'status': event?.status.tryText() ?? Status.PENDING.tryText(),
        if (eventImage.value != null) 'img_url': await dio.MultipartFile.fromFile(
          eventImage.value!.path,
          filename: eventImage.value!.path.split('/').last,
        ),
      })
    );
     result.fold(
      (error) {
        MyPUtils.showSnackbar('خطأ', error.message, isError: true);
        return false;
      },
      (updated) {
        final index = list.indexWhere((c) => c.id == id);
        if (index != -1) {
          list.value[index] = selectedEvent.value = updated;
        }
        
        list.refresh();
        MyPUtils.showSnackbar('نجاح', 'تم تحديث المناسبة');
        clearFields();
        return true;
      },
    );
    Get.back();
    isLoading.value = false;
   
  }

  Future<void> updateEventStatus(int id, Status status) async {
    isLoading.value = true;
    final result = await repository.updateStatus(id, status.tryValue());
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (updated) {
        final index = list.indexWhere((c) => c.id == id);
        if (index != -1) list[index] = list[index].copyWith(status: status);
        if (selectedEvent.value?.id == id) {
          selectedEvent.value = list[index];
        }
        MyPUtils.showSnackbar('نجاح', 'تم تحديث حالة المناسبة');
      },
    );
    isLoading.value = false;
  }

  Future<void> deleteEvent(int id) async {
    await deleteItem(id, successMessage: 'تم حذف المناسبة');
    if (selectedEvent.value?.id == id) {
      selectedEvent.value = null;
    }
  }

  void rateTask(int id, int rating, String text) {}
}
