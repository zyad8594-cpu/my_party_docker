import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart' as dio;
import '../../../core/controllers/network_controller.dart';
import '../../services/data/models/service.dart' show Service;
import '../../services/data/models/service_request.dart' show ServiceRequest;
import '../../shared/controllers/user_controller.dart';
import '../../shared/data/repository/user_repository.dart';
import '../data/repository/supplier_repository.dart' show SupplierRepository;
import '../../../core/utils/utils.dart' show MyPUtils;
import '../../../core/api/auth_service.dart' show AuthService;
import '../data/models/supplier.dart' show Supplier;
import '../provider/supplier_provider.dart';

class SupplierController extends GenericUserController<Supplier> 
{
  SupplierController() : 
    super(repository: UserRepository<Supplier>(
      provider: Get.find<SupplierProvider>(),
      fromJson: (json) => Supplier.fromJson(json),
    ));

  // Reactive state for Supplier Add/Edit
  final servicesRx = <Service>[].obs;
  final nameRx = ''.obs;
  final phoneRx = ''.obs;
  final emailRx = ''.obs;
  final addressRx = ''.obs;
  final notesRx = ''.obs;
  final passwordRx = ''.obs;
  final isActiveRx = true.obs;
  final showPasswordEdit = false.obs;
  
  Supplier? _initialSupplier;

  // Compatibility Getters
  RxList<Supplier> get suppliers => list;
  Rxn<Supplier> get selectedSupplier => selectedItem;
  List<Supplier> get filteredSuppliers => filteredList;
  
  final myServices = <dynamic>[].obs;
  final isMyServicesLoading = false.obs;

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
    servicesRx.value = [];
    nameRx.value = '';
    phoneRx.value = '';
    emailRx.value = '';
    addressRx.value = '';
    notesRx.value = '';
    profileImage.value = null;
    passwordRx.value = '';
    isActiveRx.value = true;
    showPasswordEdit.value = false;
  }

  void populateFields(Supplier supplier) {
    servicesRx.value = supplier.services.toList();
    nameRx.value = supplier.name;
    phoneRx.value = supplier.phoneNumber??'';
    emailRx.value = supplier.email;
    addressRx.value = supplier.address ?? '';
    notesRx.value = supplier.notes ?? '';
    isActiveRx.value = supplier.isActive;
    showPasswordEdit.value = false;
    _initialSupplier = supplier;
  }

  Future<void> save() async {
    isLoading.value = true;
    final data = {
      'services': servicesRx.map((e) => e.id).toList(),
      'full_name': nameRx.value,
      'phone_number': phoneRx.value,
      'email': emailRx.value,
      'address': addressRx.value,
      'notes': notesRx.value,
      'is_active': isActiveRx.value ? 1 : 0,
      'password': passwordRx.value,
    };

    final dio.FormData formData = dio.FormData.fromMap(data);
    if (profileImage.value != null) {
      formData.files.add(MapEntry(
        'img_url',
        await dio.MultipartFile.fromFile(
          profileImage.value!.path,
          filename: profileImage.value!.path.split('/').last,
        ),
      ));
    }

    final result = await repository.create(formData as dynamic);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (newSupplier) {
        list.add(newSupplier);
        Get.back();
        MyPUtils.showSnackbar('نجاح', 'تم إضافة المورد');
        clearFields();
      },
    );
    isLoading.value = false;
  }

  Future<void> updateSupplier(int id) async {
    // --- Dirty Check ---
    if (_initialSupplier != null) {
      bool isChanged = nameRx.value != _initialSupplier!.name ||
                       phoneRx.value != (_initialSupplier!.phoneNumber ?? '') ||
                       emailRx.value != _initialSupplier!.email ||
                       addressRx.value != (_initialSupplier!.address ?? '') ||
                       notesRx.value != (_initialSupplier!.notes ?? '') ||
                       isActiveRx.value != _initialSupplier!.isActive ||
                       profileImage.value != null ||
                       (showPasswordEdit.value && passwordRx.value.isNotEmpty);
      
      // Compare services
      if (!isChanged) {
        final initialServiceIds = _initialSupplier!.services.map((e) => e.id).toSet();
        final currentServiceIds = servicesRx.map((e) => e.id).toSet();
        if (initialServiceIds.length != currentServiceIds.length || 
            !initialServiceIds.containsAll(currentServiceIds)) {
          isChanged = true;
        }
      }

      if (!isChanged) {
        debugPrint('No changes detected for supplier $id, skipping API call.');
        Get.back();
        return;
      }
    }
    // -------------------

    isLoading.value = true;
    try {
      final data = {
        'services': servicesRx.map((e) => e.id).toList(),
        'full_name': nameRx.value,
        'phone_number': phoneRx.value,
        'email': emailRx.value,
        'address': addressRx.value,
        'notes': notesRx.value,
        'is_active': isActiveRx.value,
        if (showPasswordEdit.value && passwordRx.value.isNotEmpty) 'password': passwordRx.value,
      };

      final dio.FormData formData = dio.FormData.fromMap(data);
      if (profileImage.value != null) {
        formData.files.add(MapEntry(
          'img_url',
          await dio.MultipartFile.fromFile(
            profileImage.value!.path,
            filename: profileImage.value!.path.split('/').last,
          ),
        ));
      }

      final result = await repository.update(id, formData);
      result.fold(
        (error) => MyPUtils.showSnackbar('خطأ', '${error.message}\n$error', isError: true),
        (updated) {
          final index = list.indexWhere((c) => c.id == id);
          if (index != -1) list[index] = updated;
          selectedItem.value = updated;
          Get.back();
          MyPUtils.showSnackbar('نجاح', 'تم تحديث المورد');
          clearFields();
        },
      );
    } catch (e) {
      MyPUtils.showSnackbar('خطأ غير متوقع', e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> proposeService(String serviceName, String description) async {
    if(isLoading.value) return;
    isLoading.value = true;
    try {
      final int supplierId = AuthService.user.value.id;
      if(supplierId <= 0) {
        throw Exception("Invalid user ID");
      }
      
      final supplierRepo = Get.find<SupplierRepository>();
      final result = await supplierRepo.proposeService(supplierId, serviceName, description);
      
      isLoading.value = false;
      result.fold(
        (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
        (id) {
          myProposals.add(ServiceRequest(
            id: id, 
            supplierId: supplierId, 
            supplierName: AuthService.user.value.name,
            serviceName: serviceName, 
            description: description, 
            isDeleted: false,
            status: 'PENDING',
            supplierEmail: AuthService.user.value.email,
            supplierPhone: AuthService.user.value.phoneNumber,
            supplierAddress: AuthService.user.value.details['address'],
            supplierImg: AuthService.user.value.details['img_url'],
            
            ));
          Get.back(); // close bottom sheet
          MyPUtils.showSnackbar('نجاح', 'تم إرسال اقتراحك للخدمة بنجاح، وهو قيد المراجعة الآن.', isError: false);
          isLoading.value = false;
        },
      );
    } catch (e) {
      MyPUtils.showSnackbar('خطأ', e.toString(), isError: true);
      isLoading.value = false;
    } finally {
      
    }
  }

  Future<void> assignService(int supplierId, int serviceId) async {
    isLoading.value = true;
    final supplierRepo = Get.find<SupplierRepository>();
    final result = await supplierRepo.assignServiceToSupplier(supplierId, serviceId);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (_) {
        MyPUtils.showSnackbar('نجاح', 'تمت إضافة الخدمة بنجاح');
      },
    );
    isLoading.value = false;
  }

  Future<void> removeService(int supplierId, int serviceId) async {
    isLoading.value = true;
    final supplierRepo = Get.find<SupplierRepository>();
    final result = await supplierRepo.deleteService(supplierId, serviceId);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (_) {
        MyPUtils.showSnackbar('نجاح', 'تمت إزالة الخدمة بنجاح');
      },
    );
    isLoading.value = false;
  }

  Future<void> fetchMyServices() async {
    isMyServicesLoading.value = true;
    final supplierRepo = Get.find<SupplierRepository>();
    final result = await supplierRepo.getMyServices();
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (data) => myServices.value = data,
    );
    isMyServicesLoading.value = false;
  }

  // --- Proposal Management ---
  final myProposals = <ServiceRequest>[].obs;
  final isProposalsLoading = false.obs;
  final proposalSearchQuery = ''.obs;

  List<ServiceRequest> get filteredProposals => myProposals.where((p) {
    final query = proposalSearchQuery.value.toLowerCase();
    if (query.isEmpty) return true;
    return (p.serviceName.toLowerCase().contains(query)) ||
           (p.description?.toLowerCase().contains(query) ?? false);
  }).toList();

  Future<void> fetchMyProposals() async {
    isProposalsLoading.value = true;
    final supplierRepo = Get.find<SupplierRepository>();
    final result = await supplierRepo.getMyProposals();
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (data) {
        myProposals.value = data;
      },
    );
    isProposalsLoading.value = false;
  }

  Future<void> withdrawProposal(int proposalId) async {
    isProposalsLoading.value = true;
    final supplierRepo = Get.find<SupplierRepository>();
    final result = await supplierRepo.withdrawProposal(proposalId);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (_) {
        myProposals.removeWhere((p) => p.id == proposalId);
        MyPUtils.showSnackbar('نجاح', 'تم التراجع عن الاقتراح بنجاح');
      },
    );
    isProposalsLoading.value = false;
  }
  
  // Backward compatibility
  Future<void> create() => save();
  Future<void> edit(int id) => updateSupplier(id);
}
