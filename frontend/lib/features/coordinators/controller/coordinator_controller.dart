import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart' as dio;
import '../../../core/utils/utils.dart' show MyPUtils;
import '../../shared/controllers/user_controller.dart';
import '../../shared/data/repository/user_repository.dart';
import '../data/models/coordinator.dart' show Coordinator;
import '../provider/coordinator_provider.dart';

class CoordinatorController extends GenericUserController<Coordinator> 
{
  @override
  // ignore: overridden_fields
  final UserRepository<Coordinator> repository;

  CoordinatorController() : 
    repository = UserRepository<Coordinator>(
      provider: Get.find<CoordinatorProvider>(),
      fromJson: (json) => Coordinator.fromJson(json),
    ),
    super(repository: UserRepository<Coordinator>(
      provider: Get.find<CoordinatorProvider>(),
      fromJson: (json) => Coordinator.fromJson(json),
    ));

  // Reactive state for Coordinator Add/Edit
  final fullNameRx = ''.obs;
  final emailRx = ''.obs;
  final phoneNumberRx = ''.obs;
  final passwordRx = ''.obs;
  final isActiveRx = true.obs;
  final showPasswordEdit = false.obs;
  
  Coordinator? _initialCoordinator;

  // Compatibility Getters
  RxList<Coordinator> get coordinators => list;
  Rxn<Coordinator> get selectedCoordinator => selectedItem;
  List<Coordinator> get filteredCoordinators => filteredList;

  void clearFields() 
  {
    fullNameRx.value = '';
    emailRx.value = '';
    phoneNumberRx.value = '';
    passwordRx.value = '';
    profileImage.value = null;
    isActiveRx.value = true;
    showPasswordEdit.value = false;
  }

  void populateFields(Coordinator coordinator) 
  {
    fullNameRx.value = coordinator.name;
    emailRx.value = coordinator.email;
    phoneNumberRx.value = coordinator.phoneNumber ?? '';
    isActiveRx.value = coordinator.isActive;
    showPasswordEdit.value = false;
    _initialCoordinator = coordinator;
  }

  Future<void> save() async {
    isLoading.value = true;
    final data = {
      'full_name': fullNameRx.value,
      'email': emailRx.value,
      'phone_number': phoneNumberRx.value,
      'is_active': isActiveRx.value ? 1 : 0,
      if (passwordRx.value.isNotEmpty) 'password': passwordRx.value,
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
      (newCoordinator) {
        list.add(newCoordinator);
        Get.back();
        MyPUtils.showSnackbar('نجاح', 'تم إضافة المنسق');
        clearFields();
      },
    );
    isLoading.value = false;
  }

  Future<void> updateCoordinator(int id) async {
    // --- Dirty Check ---
    if (_initialCoordinator != null) {
      bool isChanged = fullNameRx.value != _initialCoordinator!.name ||
                       emailRx.value != _initialCoordinator!.email ||
                       phoneNumberRx.value != (_initialCoordinator!.phoneNumber ?? '') ||
                       isActiveRx.value != _initialCoordinator!.isActive ||
                       profileImage.value != null ||
                       (showPasswordEdit.value && passwordRx.value.isNotEmpty);
      
      if (!isChanged) {
        debugPrint('No changes detected for coordinator $id, skipping API call.');
        Get.back();
        return;
      }
    }
    // -------------------

    isLoading.value = true;
    try {
      final data = {
        'full_name': fullNameRx.value,
        'email': emailRx.value,
        'phone_number': phoneNumberRx.value,
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
        (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
        (updated) {
          final index = list.indexWhere((c) => c.id == id);
          if (index != -1) list[index] = updated;
          selectedItem.value = updated;
          Get.back();
          MyPUtils.showSnackbar('نجاح', 'تم تحديث المنسق');
          clearFields();
        },
      );
    } catch (e) {
      MyPUtils.showSnackbar('خطأ غير متوقع', e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Backward compatibility
  Future<void> create() => save();
  Future<void> edit(int id) => updateCoordinator(id);
}
