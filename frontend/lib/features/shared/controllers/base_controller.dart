import 'package:flutter/widgets.dart' show ScrollController, Curves;
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:get/get.dart';
import '../../../core/api/api_result.dart';
import '../../../core/utils/utils.dart' show MyPUtils;

abstract class BaseGenericController<T> extends GetxController 
{
  final list = <T>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final scrollController = ScrollController();
  final showScrollToTop = false.obs;
  final showHeader = true.obs;

  /// Repository must be provided by sub-classes
  dynamic get repository;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchAll();
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

  Future<void> fetchAll({bool force = false}) async {
    if(isLoading.value) return;
    if (!force && list.isNotEmpty) return;
    isLoading.value = true;
    Get.log('Fetching all ${T.toString()}');
    final result = await repository.getAll();
    if (result is ApiResult<List<T>>) {
      result.fold(
        (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
        (data) => list.assignAll(data),
      );
    }
    isLoading.value = false;
  }

  Future<void> deleteItem(int id, {String? successMessage}) async {
    final result = await repository.delete(id);
    if (result is ApiResult) {
      result.fold(
        (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
        (_) {
          list.removeWhere((item) => (item as dynamic).id == id);
          MyPUtils.showSnackbar('نجاح', successMessage ?? 'تم الحذف بنجاح');
        },
      );
    }
  }

  /// Filtered list logic for search
  List<T> getFilteredList(bool Function(T item, String query) searchLogic) {
    final query = searchQuery.value.toLowerCase();
    return list.where((item) => searchLogic(item, query)).toList();
  }

  Future<T?> fetchById(int id) async {
    isLoading.value = true;
    final result = await repository.getById(id);
    T? data;
    if (result is ApiResult<T>) {
      result.fold(
        (error) => MyPUtils.showSnackbar('خطأ', error.message, isError: true),
        (fetchedData) {
          data = fetchedData;
          // Optimistically update or add to list
          final index = list.indexWhere((item) => (item as dynamic).id == (fetchedData as dynamic).id);
          if (index != -1) {
            list[index] = fetchedData;
          } else {
            list.add(fetchedData);
          }
        },
      );
    }
    isLoading.value = false;
    return data;
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }
}
