import 'dart:io' show File;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/utils.dart' show MyPUtils;
import '../../../data/models/user.dart';
import '../data/repository/user_repository.dart';
import 'base_controller.dart';

abstract class GenericUserController<T extends User> extends BaseGenericController<T> 
{
  @override
  final UserRepository<T> repository;

  GenericUserController({required this.repository});

  final selectedItem = Rxn<T>();
  final profileImage = Rxn<File>();
  final isPasswordVisible = false.obs;

  final _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  List<T> get filteredList {
    return getFilteredList((item, query) {
      return item.name.toLowerCase().contains(query) || 
             (item.email?.toLowerCase().contains(query) ?? false) ||
             (item.phoneNumber?.contains(query) ?? false);
    });
  }

  Future<void> fetch(int id) async {
    isLoading.value = true;
    final result = await repository.getById(id);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (item) => selectedItem.value = item,
    );
    isLoading.value = false;
  }

  Future<void> delete(int id) async {
    await deleteItem(id, successMessage: 'تم حذف المستخدم بنجاح');
  }

  Future<void> toggleStatus(int id, bool isActive) async {
    isLoading.value = true;
    final result = await repository.toggleStatus(id, isActive);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (_) {
        final index = list.indexWhere((item) => item.id == id);
        if (index != -1) {
          list[index] = list[index].copyWith(isActive: isActive) as T;
        }
        if (selectedItem.value?.id == id) {
          selectedItem.value = selectedItem.value!.copyWith(isActive: isActive) as T;
        }
        MyPUtils.showSnackbar('نجاح', isActive ? 'تم تفعيل الحساب' : 'تم تعطيل الحساب');
      },
    );
    isLoading.value = false;
  }
}
