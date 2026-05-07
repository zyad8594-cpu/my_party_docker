import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/components/widgets/myp_list_view_widget.dart';
import '../../../core/components/widgets/loading_widget.dart';
import '../../../core/components/empty_state_widget.dart';

import '../../../core/components/custom_app_bar.dart' show CustomAppBar;
import '../../../core/routes/app_routes.dart' show AppRoutes;
import '../../suppliers/data/models/supplier.dart' show Supplier;

class GenericUserListView<T> extends StatelessWidget {
  final RxBool isLoading;
  final List<T> Function() filters;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final RxString searchQuery;
  final String searchHint;
  final String emptyMessage;
  final IconData emptyIcon;

  const GenericUserListView({
    super.key,
    required this.isLoading,
    required this.filters,
    required this.itemBuilder,
    required this.scrollController,
    required this.onRefresh,
    required this.searchQuery,
    this.searchHint = 'بحث...',
    this.emptyMessage = 'لا توجد نتائج للبحث',
    this.emptyIcon = Icons.search_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: CustomAppBar(title: 'قائمة ${T == Supplier? "الموردين" : "المنسقين"}'),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient.getByBrightness(brightness),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.getByBrightness(brightness).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'add_${T == Supplier? "supplier" : "coordinator"}',
          onPressed: () => Get.toNamed(T == Supplier? AppRoutes.supplierAdd: AppRoutes.coordinatorAdd),
          backgroundColor: AppColors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: AppColors.white, size: 30),
        ),
      ),


      body: Container(
        decoration: BoxDecoration(color: AppColors.background.getByBrightness(brightness)),
        child: Column(
          children: [
            _buildSearchBox(brightness),
            MyPListView.expandedBuilder<T>(
              context,
              isLoading: isLoading,
              loadingWidget: () => const LoadingWidget(),
              emptyWidget: () => EmptyStateWidget(
                message: emptyMessage,
                icon: emptyIcon,
              ),
              filters: filters,
              itemBuilder: itemBuilder,
              scrollController: scrollController,
              onRefresh: onRefresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextFormField(
        onChanged: (value) => searchQuery.value = value,
        initialValue: searchQuery.value,
        style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: TextStyle(
            color: AppColors.textSubtitle.getByBrightness(brightness),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primary.getByBrightness(brightness),
          ),
          filled: true,
          fillColor: AppColors.surface.getByBrightness(brightness),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
