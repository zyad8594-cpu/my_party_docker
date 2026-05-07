import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import '../../shared/controllers/base_controller.dart' show BaseGenericController;
import '../data/repository/income_repository.dart' show IncomeRepository;
import '../../../core/utils/utils.dart' show MyPUtils;
import '../data/models/income.dart' show Income;

import 'dart:io' show File;
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource, XFile;

class IncomeController extends BaseGenericController<Income>
{
  @override
  final IncomeRepository repository = Get.find<IncomeRepository>();
  // final IncomeRepository _repository = Get.find<IncomeRepository>();

  List<Income> get incomes => list;
  final selectedIncome = Rxn<Income>();
  // final isLoading = false.obs;
  
  Income? _initialIncome;

  // Reactive state for Income Add/Edit
  final eventIdRx = 0.obs;
  final amountRx = 0.0.obs;
  final paymentMethodRx = 'نقداً'.obs; // Default
  final paymentDateRx = DateTime.now().obs;
  final descriptionRx = ''.obs;
  final urlImageRx = ''.obs;
  
  final incomeImage = Rxn<File>();
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      incomeImage.value = File(image.path);
    }
  }

  // final amountController = TextEditingController();
  // final descriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchIncomes();
  }

  void clearFields() {
    eventIdRx.value = 0;
    amountRx.value = 0.0;
    paymentMethodRx.value = 'نقداً';
    paymentDateRx.value = DateTime.now();
    descriptionRx.value = '';
    urlImageRx.value = '';
    incomeImage.value = null;
  }

  void populateFields(Income income) {
    eventIdRx.value = income.eventId;
    amountRx.value = income.amount;
    paymentMethodRx.value = income.paymentMethod ?? 'نقداً';
    paymentDateRx.value =
        DateTime.tryParse(income.paymentDate) ?? DateTime.now();
    descriptionRx.value = income.description ?? '';
    urlImageRx.value = income.urlImage ?? '';
    _initialIncome = income;
  }

  Future<void> fetchIncomes({bool force = false}) async {
    return await fetchAll(force: force);
    // if (!force && incomes.isNotEmpty) return;
    // isLoading.value = true;
    // final result = await _repository.getAll();
    // result.fold(
    //   (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
    //   (data) => incomes.value = data,
    // );
    // isLoading.value = false;
  }

  Future<void> fetchIncome(int id) async {
    final result = await fetchById(id);
    selectedIncome.value = result;
    // isLoading.value = true;
    // final result = await _repository.getById(id);
    // result.fold(
    //   (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
    //   (income) => selectedIncome.value = income,
    // );
    // isLoading.value = false;
  }

  Future<void> createIncome() async 
  {
    if (eventIdRx.value == 0) {
      MyPUtils.showSnackbar('تنبيه', 'يرجى اختيار المناسبة', isError: true);
      return;
    }
    isLoading.value = true;
    final Map<String, dynamic> dataMap = {
      'event_id': eventIdRx.value,
      'amount': amountRx.value,
      'payment_method': paymentMethodRx.value,
      'payment_date': paymentDateRx.value.toIso8601String(),
      'description': descriptionRx.value,
    };
    if (incomeImage.value != null) {
      dataMap['url_image'] = await dio.MultipartFile.fromFile(
        incomeImage.value!.path,
        filename: incomeImage.value!.path.split('/').last,
      );
    }
    final data = dio.FormData.fromMap(dataMap);
    final result = await repository.create(data);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (newIncome) {
        incomes.add(newIncome);
        Get.back();
        MyPUtils.showSnackbar('نجاح', 'تم إضافة الدفعة');
        clearFields();
      },
    );
    isLoading.value = false;
  }

  Future<void> updateIncome(int id) async {
    // --- Dirty Check ---
    if (_initialIncome != null) {
      bool isChanged = eventIdRx.value != _initialIncome!.eventId ||
                       amountRx.value != _initialIncome!.amount ||
                       paymentMethodRx.value != (_initialIncome!.paymentMethod ?? 'نقداً') ||
                       descriptionRx.value != (_initialIncome!.description ?? '') ||
                       incomeImage.value != null;
      
      if (!isChanged) {
        final initialDate = DateTime.tryParse(_initialIncome!.paymentDate);
        if (initialDate?.toIso8601String() != paymentDateRx.value.toIso8601String()) {
          isChanged = true;
        }
      }

      if (!isChanged) {
        debugPrint('No changes detected for income $id, skipping API call.');
        Get.back();
        return;
      }
    }
    // -------------------

    isLoading.value = true;
    final Map<String, dynamic> dataMap = {
      'event_id': eventIdRx.value,
      'amount': amountRx.value,
      'payment_method': paymentMethodRx.value,
      'payment_date': paymentDateRx.value.toIso8601String(),
      'description': descriptionRx.value,
    };
    if (incomeImage.value != null) {
      dataMap['url_image'] = await dio.MultipartFile.fromFile(
        incomeImage.value!.path,
        filename: incomeImage.value!.path.split('/').last,
      );
    } else if (urlImageRx.value.isNotEmpty) {
      dataMap['url_image'] = urlImageRx.value;
    }
    final data = dio.FormData.fromMap(dataMap);
    final result = await repository.update(id, data);
    result.fold(
      (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
      (updated) {
        final index = incomes.indexWhere((c) => c.id == id);
        if (index != -1) incomes[index] = updated;
        selectedIncome.value = updated;
        Get.back();
        MyPUtils.showSnackbar('نجاح', 'تم تحديث الدفعة');
        clearFields();
      },
    );
    isLoading.value = false;
  }

  Future<void> deleteIncome(int id) async {
    await deleteItem(id, successMessage: 'تم حذف الدفعة');
    // final result = await _repository.delete(id);
    // result.fold(
    //   (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
    //   (_) {
    //     incomes.removeWhere((c) => c.id == id);
    //     if (selectedIncome.value?.id == id) {
    //       selectedIncome.value = null;
    //     }
    //     MyPUtils.showSnackbar('نجاح', 'تم حذف الدفعة');
    //   },
    // );
  }
}
