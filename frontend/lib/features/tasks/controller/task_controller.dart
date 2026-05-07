import 'package:flutter/material.dart' show ScrollController, TextEditingController, debugPrint;
import 'package:get/get.dart';
import '../../../../core/api/auth_service.dart';
import '../../../../core/controllers/network_controller.dart';
import '../../../../core/utils/status.dart';
import '../../../../core/utils/utils.dart' show MyPUtils;
import '../../events/controller/event_controller.dart' show EventController;
import '../../events/data/models/event.dart' show Event;
import '../../shared/controllers/base_controller.dart';
import '../../suppliers/controller/supplier_controller.dart' show SupplierController;
import '../../suppliers/data/models/supplier.dart' show Supplier;
import '../data/models/task.dart' show Task;
import '../data/repository/task_repository.dart' show TaskRepository;
import 'dart:io' show File;
import 'package:dio/dio.dart' as dio;
import '../../auth/controller/auth_controller.dart' show AuthController;

class TaskController extends BaseGenericController<Task> 
{
  @override
  final TaskRepository repository = Get.find<TaskRepository>();
  final AuthController authController = Get.find<AuthController>();

  // Reactive state for Task Add/Edit
  final typeRx = ''.obs;
  final descriptionRx = ''.obs;
  final costRx = 0.0.obs;
  final eventIdRx = 0.obs;
  final serviceIdRx = RxnInt();
  final assignmentTypeRx = 'COORDINATOR'.obs;
  final selectedSupplierForNewTaskRx = Rxn<Supplier>();
  final assigneeIdRx = RxnInt();
  final startDateRx = DateTime.now().obs;
  final dueDateRx = DateTime.now().add(const Duration(days: 7)).obs;
  final reminderTypeRx = 'none'.obs;
  final reminderValueRx = 1.obs;
  final reminderUnitRx = 'DAY'.obs;
  
  // Controllers for TextFields to prevent keyboard dismissal on rebuild
  final typeController = TextEditingController();
  final descriptionController = TextEditingController();
  final costController = TextEditingController();
  final reminderValueController = TextEditingController();

  final selectedStatus = 'الكل'.obs;
  final selectedFilterTab = 'كل المهام'.obs; // 'كل المهام', 'مهامي', 'مهام الموردين'
  final selectedTask = Rxn<Task>();
  final myTasksScrollController = ScrollController();
  final supplierTasksScrollController = ScrollController();
  
  Task? _initialTask;

  /// Compatibility getter
  List<Task> get tasks => list;

  @override
  void onInit() {
    super.onInit();
    
    // Sync controllers with Rx
    typeController.addListener(() => typeRx.value = typeController.text);
    descriptionController.addListener(() => descriptionRx.value = descriptionController.text);
    costController.addListener(() => costRx.value = double.tryParse(costController.text) ?? 0.0);
    reminderValueController.addListener(() => reminderValueRx.value = int.tryParse(reminderValueController.text) ?? 1);

    // Listen to reconnection
    if (Get.isRegistered<NetworkController>()) {
      ever(Get.find<NetworkController>().onReconnected, (_) {
        if (list.isEmpty) {
          fetchAll(force: true);
        }
      });
    }
  }

  @override
  void onClose() {
    typeController.dispose();
    descriptionController.dispose();
    costController.dispose();
    reminderValueController.dispose();
    myTasksScrollController.dispose();
    supplierTasksScrollController.dispose();
    super.onClose();
  }

  void clearFields() {
    typeRx.value = '';
    descriptionRx.value = '';
    costRx.value = 0.0;
    eventIdRx.value = 0;
    serviceIdRx.value = null;
    assignmentTypeRx.value = 'COORDINATOR';
    selectedSupplierForNewTaskRx.value = null;
    assigneeIdRx.value = null;
    startDateRx.value = DateTime.now();
    dueDateRx.value = DateTime.now().add(const Duration(days: 7));
    reminderTypeRx.value = 'none';
    reminderValueRx.value = 1;
    reminderUnitRx.value = 'DAY';
    
    typeController.text = '';
    descriptionController.text = '';
    costController.text = '';
    reminderValueController.text = '1';
  }

  void populateFields(Task task) {
    typeRx.value = task.typeTask ?? '';
    descriptionRx.value = task.description ?? '';
    costRx.value = task.cost;  
    eventIdRx.value = task.eventId;
    serviceIdRx.value = task.serviceId;
    assignmentTypeRx.value = task.assignmentType.toUpperCase();
    selectedSupplierForNewTaskRx.value = Get.find<SupplierController>().suppliers.firstWhereOrNull((s) => s.id == task.userAssignId);
    assigneeIdRx.value = task.userAssignId;
    startDateRx.value = task.dateStart != null ? DateTime.parse(task.dateStart!) : DateTime.now();
    dueDateRx.value = task.dateDue != null ? DateTime.parse(task.dateDue!) : DateTime.now();
    reminderTypeRx.value = task.reminderType ?? 'none';
    reminderValueRx.value = task.reminderValue ?? 1;
    reminderUnitRx.value = task.reminderUnit ?? 'DAY';

    typeController.text = task.typeTask ?? '';
    descriptionController.text = task.description ?? '';
    costController.text = task.cost == 0.0 ? '' : task.cost.toString();
    reminderValueController.text = (task.reminderValue ?? 1).toString();
    _initialTask = task;
  }

  List<Task> get filteredTasks {
    final userId = AuthService.user.value.id;

    return getFilteredList((t, query) {
      if (AuthService.userIsSupplier && t.userAssignId != userId) return false;
      
      final matchesSearch =
          (t.typeTask?.toLowerCase().contains(query) ?? false) ||
          (t.assigneName?.toLowerCase().contains(query) ?? false) ||
          (t.description?.toLowerCase().contains(query) ?? false);

      bool matchesTab = true;
      if (selectedFilterTab.value == 'مهامي') {
        matchesTab = t.userAssignId == userId || t.userAssignId == 0;
      } else if (selectedFilterTab.value == 'مهام الموردين') {
        matchesTab = t.userAssignId != userId;
      }

      bool matchesStatus = true;
      if (selectedStatus.value != 'الكل') {
        matchesStatus = t.status.text() == selectedStatus.value;
      }

      return matchesSearch && matchesTab && matchesStatus;
    });
  }

  Future<void> rateTask(int taskId, int rating, String? comment) async {
    isLoading.value = true;
    final result = await repository.rate(taskId, rating, comment);
    if (result.isSuccess) {
      MyPUtils.showSnackbar('نجاح', 'تم تقييم المهمة بنجاح');
      final index = list.indexWhere((c) => c.id == taskId);
      if (index != -1) {
        final updatedTask = list[index].copyWith(rating: rating.toDouble(), ratingComment: comment);
        list[index] = updatedTask;
        if (selectedTask.value?.id == taskId) {
          selectedTask.value = updatedTask;
        }
      }
      list.refresh();
    } else {
      MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
    }
    isLoading.value = false;
  }

  Future<void> fetchTasks({bool force = false}) => fetchAll(force: force);

  Future<void> fetchTask(int id) async {
    isLoading.value = true;
    final result = await repository.getById(id);
    if (result.isSuccess) {
      selectedTask.value = result.data;
    } else {
      MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
    }
    isLoading.value = false;
  }

  DateTime _calculateEventEndDate(Event event) {
    final start = DateTime.tryParse(event.eventDate) ?? DateTime.now();
    final duration = event.eventDuration;
    final unit = event.eventDurationUnit.toUpperCase();

    switch (unit) {
      case 'WEEK':
        return start.add(Duration(days: duration * 7));
      case 'MONTH':
        return DateTime(start.year, start.month + duration, start.day, start.hour, start.minute);
      case 'DAY':
      default:
        return start.add(Duration(days: duration));
    }
  }

  Future<void> createTask() async {
    if(isLoading.value) return;
    final event = Get.find<EventController>().list.firstWhereOrNull((e) => e.id == eventIdRx.value);
    
    if (event == null) {
      MyPUtils.showSnackbar('خطأ', 'المناسبة غير موجودة', isError: true);
      return;
    }

    final eventStart = DateTime.tryParse(event.eventDate) ?? DateTime.now();
    final eventEnd = _calculateEventEndDate(event);
    
    if (startDateRx.value.isBefore(eventStart) || startDateRx.value.isAfter(eventEnd) ||
        dueDateRx.value.isBefore(eventStart) || dueDateRx.value.isAfter(eventEnd) ||
        dueDateRx.value.isBefore(startDateRx.value)) {
      MyPUtils.showSnackbar('خطأ', 'التواريخ المختارة غير صالحة', isError: true);
      return;
    }

    isLoading.value = true;
    final coordinatorId = AuthService.user.value.id;
    final data = {
      'event_id': eventIdRx.value,
      if (serviceIdRx.value != null) 'service_id': serviceIdRx.value,
      'type_task': typeRx.value,
      'date_start': startDateRx.value.toIso8601String(),
      'date_due': dueDateRx.value.toIso8601String(),
      'user_assign_id': (assignmentTypeRx.value.toUpperCase() == 'COORDINATOR') ? coordinatorId : assigneeIdRx.value,
      'description': descriptionRx.value,
      'cost': costRx.value,
      'reminder_type': reminderTypeRx.value,
      'reminder_value': reminderValueRx.value,
      'reminder_unit': reminderUnitRx.value,
    };
    
    final result = await repository.create(data);
    if (result.isSuccess) {
      list.add(result.data!);
      Get.back();
      // MyPUtils.showSnackbar('نجاح', 'تم إضافة المهمة');
      clearFields();
    } else {
      MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
    }
    isLoading.value = false;
  }

  Future<void> updateTask(int id, {Status? currentStatus}) async {
    if (_initialTask != null) {
      bool isChanged = typeRx.value != (_initialTask!.typeTask ?? '') ||
                       descriptionRx.value != (_initialTask!.description ?? '') ||
                       costRx.value != _initialTask!.cost ||
                       eventIdRx.value != _initialTask!.eventId ||
                       serviceIdRx.value != _initialTask!.serviceId ||
                       assigneeIdRx.value != _initialTask!.userAssignId ||
                       reminderTypeRx.value != (_initialTask!.reminderType ?? 'none') ||
                       reminderValueRx.value != (_initialTask!.reminderValue ?? 1) ||
                       reminderUnitRx.value != (_initialTask!.reminderUnit ?? 'DAY');
      
      if (!isChanged) {
        final initialStart = _initialTask!.dateStart != null ? DateTime.tryParse(_initialTask!.dateStart!) : null;
        final initialDue = _initialTask!.dateDue != null ? DateTime.tryParse(_initialTask!.dateDue!) : null;
        
        if (initialStart?.toIso8601String() != startDateRx.value.toIso8601String() ||
            initialDue?.toIso8601String() != dueDateRx.value.toIso8601String()) {
          isChanged = true;
        }

        if (!isChanged && currentStatus != null && currentStatus != _initialTask!.status) {
          isChanged = true;
        }
      }

      if (!isChanged) {
        Get.back();
        return;
      }
    }

    final eventController = Get.find<EventController>();
    final task = list.firstWhereOrNull((t) => t.id == id);
    if (task == null) return;
    
    final event = eventController.list.firstWhereOrNull((e) => e.id == task.eventId);
    
    if (event != null) {
       if (event.isDeleted) {
        MyPUtils.showSnackbar('خطأ', 'لا يمكن تعديل مهام لمناسبة محذوفة', isError: true);
        return;
      }

      final eventStart = DateTime.tryParse(event.eventDate) ?? DateTime.now();
      final eventEnd = _calculateEventEndDate(event);
      
      if (startDateRx.value.isBefore(eventStart) || startDateRx.value.isAfter(eventEnd) ||
          dueDateRx.value.isBefore(eventStart) || dueDateRx.value.isAfter(eventEnd) ||
          dueDateRx.value.isBefore(startDateRx.value)) {
        MyPUtils.showSnackbar('خطأ', 'التواريخ المختارة غير صالحة', isError: true);
        return;
      }
    }

    if (task.status == Status.COMPLETED || task.status == Status.CANCELLED || task.status == Status.REJECTED) {
      MyPUtils.showSnackbar('خطأ', 'لا يمكن تعديل مهمة منتهية، ملغاة أو مرفوضة', isError: true);
      return;
    }

    final bool isUnderReview = task.status == Status.UNDER_REVIEW;

    isLoading.value = true;
    final data = {
      if (!isUnderReview) if (serviceIdRx.value != null) 'service_id': serviceIdRx.value,
      if (!isUnderReview) 'type_task': typeRx.value,
      'status': (currentStatus ?? task.status).name,
      if (!isUnderReview) 'date_start': startDateRx.value.toIso8601String(),
      if (!isUnderReview) 'date_due': dueDateRx.value.toIso8601String(),
      if (!isUnderReview) 'description': descriptionRx.value,
      'cost': costRx.value,
      if (!isUnderReview) 'notes': '',
      if (!isUnderReview) 'url_image': '',
      if (!isUnderReview) 'reminder_type': reminderTypeRx.value,
      if (!isUnderReview) 'reminder_value': reminderValueRx.value,
      if (!isUnderReview) 'reminder_unit': reminderUnitRx.value,
    };
    final result = await repository.update(id, data);
    if (result.isSuccess) {
      final updated = result.data!;
      final index = list.indexWhere((c) => c.id == id);
      if (index != -1) list[index] = updated;
      selectedTask.value = updated;
      Get.back();
      // MyPUtils.showSnackbar('نجاح', 'تم تحديث المهمة');
      clearFields();
    } else {
      MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
    }
    isLoading.value = false;
  }
  
  Future<void> updateTaskStatus(int id, dynamic newStatus, {String? note, dynamic urlImage, double? adjustmentAmount, String? adjustmentType}) async {
    isLoading.value = true;
    try {
      Status statusEnum;
      if (newStatus is Status) {
        statusEnum = newStatus;
      } else {
        String statusStr = newStatus.toString();
        statusEnum = Status.values.firstWhere(
          (e) => e.name == statusStr || e.value() == statusStr, 
          orElse: () => Status.PENDING
        );
      }
      
      if (AuthService.userIsSupplier) {
        final eventController = Get.isRegistered<EventController>() ? Get.find<EventController>() : null;
        if (eventController != null) {
          final task = list.firstWhereOrNull((t) => t.id == id);
          if (task != null) {
            final event = eventController.list.firstWhereOrNull((e) => e.id == task.eventId);
            if (event != null) {
              final eventStart = DateTime.tryParse(event.eventDate) ?? DateTime.now();
              if (DateTime.now().isBefore(eventStart) && statusEnum != Status.REJECTED && statusEnum != Status.IN_PROGRESS && statusEnum != Status.PENDING) {
                MyPUtils.showSnackbar('خطأ', 'لا يمكن تقديم المهمة لمراجعة قبل بدء المناسبة', isError: true);
                isLoading.value = false;
                return;
              }
            }
          }
        }
      }

      final Map<String, dynamic> dataMap = {
        'status': statusEnum.value(),
        'notes': note ?? '',
        'adjustment_amount': adjustmentAmount ?? 0.0,
        'adjustment_type': adjustmentType ?? 'NONE',
      };

      if (urlImage != null && urlImage is File) {
        dataMap['url_image'] = await dio.MultipartFile.fromFile(
          urlImage.path,
          filename: urlImage.path.split('/').last,
        );
      }
      final data = dio.FormData.fromMap(dataMap);
      
      final result = await repository.updateTaskStatus(id, data);
      if (result.isSuccess) {
        final index = list.indexWhere((c) => c.id == id);
        if (index != -1) {
          final oldTask = list[index];
          final updatedTask = oldTask.copyWith(
            status: statusEnum,
            adjustmentAmount: adjustmentAmount,
            adjustmentType: adjustmentType,
          );
          list[index] = updatedTask;
          
          if (selectedTask.value?.id == id) {
            selectedTask.value = updatedTask;
          }
        }
        list.refresh();
        MyPUtils.showSnackbar('نجاح', 'تم تحديث حالة المهمة');
      } else {
        MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
      }
    } catch (e) {
      debugPrint('Error in updateTaskStatus: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectTask(int id) async {
    await updateTaskStatus(id, Status.REJECTED);
  }

  Future<void> deleteTask(int id) async {
    await deleteItem(id, successMessage: 'تم حذف المهمة');
    if (selectedTask.value?.id == id) {
      selectedTask.value = null;
    }
  }

  Future<void> addTaskReminder(int taskId, String type, int value, String unit) async {
    isLoading.value = true;
    final data = {
      'reminder_type': type,
      'reminder_value': value,
      'reminder_unit': unit,
    };
    final result = await repository.addTaskReminder(taskId, data);
    if (result.isSuccess) {
      MyPUtils.showSnackbar('نجاح', 'تم إضافة التذكير بنجاح');
      await fetchAll(force: true);
      Get.back();
    } else {
      MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
    }
    isLoading.value = false;
  }

  Future<void> updateTaskReminder(int taskId, String type, int value, String unit) async {
    isLoading.value = true;
    final data = {
      'reminder_type': type,
      'reminder_value': value,
      'reminder_unit': unit,
    };
    final result = await repository.updateTaskReminder(taskId, data);
    if (result.isSuccess) {
      MyPUtils.showSnackbar('نجاح', 'تم تحديث التذكير بنجاح');
      await fetchAll(force: true);
      Get.back();
    } else {
      MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
    }
    isLoading.value = false;
  }

  Future<void> deleteTaskReminder(int taskId) async {
    isLoading.value = true;
    final result = await repository.deleteTaskReminder(taskId);
    if (result.isSuccess) {
      MyPUtils.showSnackbar('نجاح', 'تم حذف التذكير بنجاح');
    } else {
      MyPUtils.showSnackbar('خطأ', result.failure?.message ?? 'حدث خطأ', isError: true);
    }
    isLoading.value = false;
    await fetchAll(force: true);
  }
}
