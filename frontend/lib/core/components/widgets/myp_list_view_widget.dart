import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../myp_scrollbar.dart';

class MyPListView 
{
   static Widget builder<T>(BuildContext context,{
    required RxBool isLoading,
    required Widget Function() loadingWidget,
    required Widget Function() emptyWidget,
    required List<T> Function() filters,
    required Widget Function(BuildContext context, int index, T item) itemBuilder,
    ScrollController? scrollController,
    Future<void> Function()? onRefresh,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    Widget Function(BuildContext context, int index)? separatorBuilder,
    Widget? header,
  }) {
    final controller = scrollController ?? ScrollController();
    
    Widget content = Obx(() {
      final filtersList = filters();
      if (isLoading.value) return loadingWidget();
      
      Widget listView;
      int itemCount = (filtersList.isEmpty ? 1 : filtersList.length) + (header != null ? 1 : 0);

      if (filtersList.isEmpty && header == null) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: emptyWidget(),
            ),
          ],
        );
      }
      
      if (separatorBuilder != null) {
        listView = ListView.separated(
          controller: controller,
          padding: padding ?? const EdgeInsets.only(left: 20, right: 20, bottom: 150),
          itemCount: itemCount,
          shrinkWrap: shrinkWrap,
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            if (header != null && index == 0) return const SizedBox.shrink();
            return separatorBuilder(context, header != null ? index - 1 : index);
          },
          itemBuilder: (context, index) {
            if (header != null && index == 0) return header;
            int actualIndex = header != null ? index - 1 : index;
            if (filtersList.isEmpty) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: emptyWidget(),
              );
            }
            return itemBuilder(context, actualIndex, filtersList[actualIndex]);
          },
        );
      } else {
        listView = ListView.builder(
          controller: controller,
          padding: padding ?? const EdgeInsets.only(left: 20, right: 20, bottom: 150),
          itemCount: itemCount,
          shrinkWrap: shrinkWrap,
          physics: physics ?? const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (header != null && index == 0) return header;
            int actualIndex = header != null ? index - 1 : index;
            if (filtersList.isEmpty) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: emptyWidget(),
                );
            }
            return itemBuilder(context, actualIndex, filtersList[actualIndex]);
          },
        );
      }

      return MyPScrollbar(
        controller: controller,
        child: listView,
      );
    });

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: content,
      );
    }
    
    return content;
  }

  static Widget expandedBuilder<T>(BuildContext context,{
    required RxBool isLoading,
    required Widget Function() loadingWidget,
    required Widget Function() emptyWidget,
    required List<T> Function() filters,
    required Widget Function(BuildContext context, int index, T item) itemBuilder,
    ScrollController? scrollController,
    Future<void> Function()? onRefresh,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    Widget Function(BuildContext context, int index)? separatorBuilder,
    Widget? header,
  }) {
    return Expanded(
      child: builder<T>(
        context, 
        isLoading: isLoading, 
        loadingWidget: loadingWidget, 
        emptyWidget: emptyWidget, 
        filters: filters, 
        itemBuilder: itemBuilder,
        scrollController: scrollController,
        onRefresh: onRefresh,
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        separatorBuilder: separatorBuilder,
        header: header,
      ),
    );
  }
}