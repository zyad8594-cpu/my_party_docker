import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show ScrollController, TextEditingController;
import 'package:get/get.dart';
import '../../suppliers/data/models/supplier.dart' show Supplier;
import '../data/repository/service_repository.dart' show ServiceRepository;
import '../../../core/utils/utils.dart' show MyPUtils;
import '../data/models/service.dart' show Service;
import '../../suppliers/data/repository/supplier_repository.dart' show SupplierRepository;
import '../data/models/service_request.dart' show ServiceRequest;

import '../../shared/controllers/base_controller.dart';

class ServiceController extends BaseGenericController<Service> 
{
  @override
  final ServiceRepository repository = Get.find<ServiceRepository>();

  /// Compatibility getters
  List<Service> get services => list;
  Service? get selectedServiceValue => selectedService.value;

  final selectedService = Rxn<Service>();
  
  Service? _initialService;
  final supplierSearchQuery = ''.obs;
  final currentTabIndex = 0.obs;
  final proposedScrollController = ScrollController();

  List<Service> get filteredServices => getFilteredList((s, query) {
    return s.serviceName.toLowerCase().contains(query) || 
           (s.description?.toLowerCase().contains(query) ?? false);
  });

  List<dynamic> get filteredServiceRequests => serviceRequests.where((r) {
    final query = searchQuery.value.toLowerCase();
    return r.serviceName.toLowerCase().contains(query) || 
           (r.description?.toLowerCase().contains(query) ?? false) ||
           (r.supplierName?.toLowerCase().contains(query) ?? false);
  }).toList();

  // Reactive state for Service Add/Edit
  final serviceNameRx = ''.obs;
  final descriptionRx = ''.obs;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final supplierSearchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(() {
      serviceNameRx.value = nameController.text;
    });
    descriptionController.addListener(() {
      descriptionRx.value = descriptionController.text;
    });
  }
  
  RxList<Supplier> get serviceSuppliers{
    return (selectedService.value?.suppliers ?? []).obs;
  }

  Future<void> fetchSuppliersForService(int serviceId) async {
    isLoading.value = true;
    final supplierRepo = Get.find<SupplierRepository>();
    final result = await supplierRepo.getAllByServiceId(serviceId);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (suppliers) {
        if (selectedService.value != null && selectedService.value!.id == serviceId) {
          selectedService.value = selectedService.value!.assignAllSuppliers(suppliers);
        }
      },
    );
    isLoading.value = false;
  }
  int? pendingApprovalRequestId;

  void clearFields() {
    serviceNameRx.value = '';
    descriptionRx.value = '';

    nameController.clear();
    descriptionController.clear();
    pendingApprovalRequestId = null;
  }

  void populateFields(Service service) {
    serviceNameRx.value = service.serviceName;
    descriptionRx.value = service.description ?? '';

    nameController.text = service.serviceName;
    descriptionController.text = service.description ?? '';
    _initialService = service;
  }

  Future<void> createService() async {
    if(isLoading.value) return;
    if (serviceNameRx.value.isEmpty) {
      MyPUtils.showSnackbar('تنبيه', 'يرجى إدخال اسم الخدمة', isError: true);
      return;
    }
    isLoading.value = true;
    final data = {
      'service_name': serviceNameRx.value,
      'description': descriptionRx.value,
    };

    bool wasApproving = pendingApprovalRequestId != null;
    if (wasApproving) {
      final result = await repository.approveRequest(pendingApprovalRequestId!, data);
      result.fold(
        (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
        (newService) async {
          await fetchAll(force: true); 
          await fetchServiceRequests();
          MyPUtils.showSnackbar('نجاح', 'تم إضافة الخدمة واعتماد المقترح بنجاح');
          clearFields();
          Get.back(result: true);
        }
      );
      isLoading.value = false;
      return;
    }

    final result = await repository.create(data);
    result.fold(
      (error) {
        MyPUtils.showSnackbar('خطأ', error.message, isError: true);
      },
      (newService) async {
        await fetchAll(force: true); 
        MyPUtils.showSnackbar('نجاح', 'تم إضافة الخدمة');
        clearFields();
        Get.back();
      },
    );
    isLoading.value = false;
  }

  Future<void> updateService(int id) async {
    // --- Dirty Check ---
    if (_initialService != null) {
      bool isChanged = serviceNameRx.value != _initialService!.serviceName ||
                       descriptionRx.value != (_initialService!.description ?? '');
      
      if (!isChanged) {
        debugPrint('No changes detected for service $id, skipping API call.');
        Get.back();
        return;
      }
    }
    // -------------------

    isLoading.value = true;
    final data = {
      'service_name': serviceNameRx.value,
      'description': descriptionRx.value,
    };
    final result = await repository.update(id, data);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (updated) {
        final index = list.indexWhere((c) => c.id == id);
        if (index != -1) list[index] = updated;
        selectedService.value = updated;
        Get.back();
        MyPUtils.showSnackbar('نجاح', 'تم تحديث الخدمة');
        clearFields();
      },
    );
    isLoading.value = false;
  }

  Future<void> deleteService(int id) async {
    final result = await repository.delete(id);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (_) {
        list.removeWhere((c) => c.id == id);
        if (selectedService.value?.id == id) {
          selectedService.value = null;
        }
        MyPUtils.showSnackbar('نجاح', 'تم حذف الخدمة');
      },
    );
  }

  // --- Proposed Services Logic ---
  final serviceRequests = <dynamic>[].obs; // Using dynamic or ServiceRequest model
  final isRequestsLoading = false.obs;
  final selectedRequestFilter = 'الكل'.obs;

  List<dynamic> get displayedServiceRequests {
    final list = filteredServiceRequests;
    if (selectedRequestFilter.value == 'الكل') return list;
    if (selectedRequestFilter.value == 'قيد الإنتظار') return list.where((r) => r.status == 'PENDING').toList();
    if (selectedRequestFilter.value == 'معتمدة') return list.where((r) => r.status == 'APPROVED').toList();
    if (selectedRequestFilter.value == 'مرفوضة') return list.where((r) => r.status == 'REJECTED' || r.status == 'CANCELLED').toList();
    return list;
  }

  Future<void> fetchServiceRequests() async {
    isRequestsLoading.value = true;
    final result = await repository.getAllRequests();
    result.fold(
        (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
        (data) {
          serviceRequests.value = data;
        },
      );
    isRequestsLoading.value = false;
  }

  Future<void> fetchMyServiceRequests() async {
    isRequestsLoading.value = true;
    final result = await repository.getMyRequests();
    result.fold(
        (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
        (data) {
          serviceRequests.value = data;
        },
      );
    isRequestsLoading.value = false;
  }

  Future<void> updateRequestStatus(int id, String status) async {
    isRequestsLoading.value = true;
    final result = await repository.updateRequestStatus(id, status);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (data) {
        // update locally instead of remove, so we can see it in tabs
        final index = serviceRequests.indexWhere((r) => r.id == id);
        if (index != -1) {
          final r = serviceRequests[index];
          if (r is ServiceRequest) {
            serviceRequests[index] = r.copyWith(status: status);
          } else {
            // Fallback for dynamic/Map if still used
            final Map<String, dynamic> updatedMap = Map<String, dynamic>.from(r is Map ? r : {});
            updatedMap['status'] = status;
            serviceRequests[index] = updatedMap;
          }
        }
        MyPUtils.showSnackbar('نجاح', 'تم تحديث حالة الاقتراح');
      },
    );
    isRequestsLoading.value = false;
  }
  Future<void> withdrawRequest(int id) async {
    isRequestsLoading.value = true;
    final result = await repository.withdrawRequest(id);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (_) {
        serviceRequests.removeWhere((r) => r.id == id);
        MyPUtils.showSnackbar('نجاح', 'تم سحب الاقتراح بنجاح');
      },
    );
    isRequestsLoading.value = false;
  }

  @override
  void onClose() {
    proposedScrollController.dispose();

    try {
      nameController.dispose();
      descriptionController.dispose();
      supplierSearchController.dispose();
    } catch (e) {
      debugPrint('Error disposing controllers in ServiceController: $e');
    }
    
    super.onClose();
  }
}
