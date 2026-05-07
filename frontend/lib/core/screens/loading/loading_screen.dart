// import 'package:flutter/gestures.dart' show DragStartBehavior;
// import 'package:flutter/material.dart';
// import '../../themes/app_colors.dart' ;

// typedef BottomSheetScrimBuilder = Widget? Function(BuildContext, Animation<double>);
// class LoadingScreen extends StatelessWidget 
// {
//   final Future<void> Function() onRefresh;
//   final ScaffoldAttr scaffoldAttr;

//   LoadingScreen({
//     super.key,
//     this.scaffoldAttr = const ScaffoldAttr(),
//     Future<void> Function()? onRefresh,
//   }): this.onRefresh = onRefresh ?? ((){} as Future<void> Function())
//   ;

//   @override
//   Widget build(BuildContext context) {
//     Brightness brightness = Theme.of(context).brightness;


//     return Scaffold(
//         key: scaffoldAttr.key,
//         appBar: scaffoldAttr.appBar,
//         floatingActionButton: scaffoldAttr.floatingActionButton,
//         floatingActionButtonLocation: scaffoldAttr.floatingActionButtonLocation,
//         floatingActionButtonAnimator: scaffoldAttr.floatingActionButtonAnimator,
//         persistentFooterButtons: scaffoldAttr.persistentFooterButtons,
//         persistentFooterAlignment: scaffoldAttr.persistentFooterAlignment,
//         persistentFooterDecoration: scaffoldAttr.persistentFooterDecoration,
//         drawer: scaffoldAttr.drawer,
//         onDrawerChanged: scaffoldAttr.onDrawerChanged,
//         endDrawer: scaffoldAttr.endDrawer,
//         onEndDrawerChanged: scaffoldAttr.onEndDrawerChanged,
//         bottomNavigationBar: scaffoldAttr.bottomNavigationBar,
//         bottomSheet: scaffoldAttr.bottomSheet,
//         backgroundColor: scaffoldAttr.backgroundColor,
//         resizeToAvoidBottomInset: scaffoldAttr.resizeToAvoidBottomInset,
//         primary: scaffoldAttr.primary,
//         drawerDragStartBehavior: scaffoldAttr.drawerDragStartBehavior,
//         extendBody: scaffoldAttr.extendBody,
//         drawerBarrierDismissible: scaffoldAttr.drawerBarrierDismissible,
//         extendBodyBehindAppBar: scaffoldAttr.extendBodyBehindAppBar,
//         drawerScrimColor: scaffoldAttr.drawerScrimColor,
//         bottomSheetScrimBuilder: scaffoldAttr.bottomSheetScrimBuilder,
//         drawerEdgeDragWidth: scaffoldAttr.drawerEdgeDragWidth,
//         drawerEnableOpenDragGesture: scaffoldAttr.drawerEnableOpenDragGesture,
//         endDrawerEnableOpenDragGesture: scaffoldAttr.endDrawerEnableOpenDragGesture,
//         restorationId: scaffoldAttr.restorationId,
//         body: RefreshIndicator(
//           onRefresh: onRefresh,
//           child:  SafeArea(
//             child: Column(
//               children: [
//                 /// صندوق البحث والفلاتر
//                 SearchBox.withNotLayout(
//                   context, 
//                   'بحث عن عميل...',
//                   searchOnChanged: (value) => controller.searchQuery.value = value,
//                 ),
//                 const SizedBox(height: 8),
//                 /// قائمة العملاء
//                 MyPListView.expandedBuilder(context, 
//                   ///  حالة التحميل
//                   isLoading: controller.isLoading, 
//                   loadingWidget: ()=> LoadingWidget(), 
//                   ///  حالة عدم وجود عملاء
//                   emptyWidget: ()=>  const EmptyStateWidget(message: 'لا يوجد عملاء مضافين', icon: Icons.people_outline_rounded), 
//                   ///  قائمة العملاء
//                   filters: () => controller.filteredClients, 
//                   ///  بناء بطاقة عرض العميل 
//                   itemBuilder: (index, client)=> _buildClientCard(context, client),
//                 ),
//               ],
//             ),
//           ),
//         ),
      
//         ///  زر إضافة عميل
//         floatingActionButton: MyPActions.floatButton(
//           context, 
//           icon: Icons.add_rounded, 
//           heroTag: 'add_client',
//           onPressed: () => Get.toNamed(AppRoutes.clientAdd),
//         ),
//       );
//   }
// }


// class ScaffoldAttr {
//   final Key? key;
//   final PreferredSizeWidget? appBar;
//   final Widget? body;
//   final Widget? floatingActionButton;
//   final FloatingActionButtonLocation? floatingActionButtonLocation;
//   final FloatingActionButtonAnimator? floatingActionButtonAnimator;
//   final List<Widget>? persistentFooterButtons;
//   final AlignmentDirectional persistentFooterAlignment;
//   final BoxDecoration? persistentFooterDecoration;
//   final Widget? drawer;
//   final void Function(bool)? onDrawerChanged;
//   final Widget? endDrawer;
//   final void Function(bool)? onEndDrawerChanged;
//   final Widget? bottomNavigationBar;
//   final Widget? bottomSheet;
//   final Color? backgroundColor;
//   final bool? resizeToAvoidBottomInset;
//   final bool primary;
//   final DragStartBehavior drawerDragStartBehavior;
//   final bool extendBody;
//   final bool drawerBarrierDismissible;
//   final bool extendBodyBehindAppBar;
//   final Color? drawerScrimColor;
  
//   final  bottomSheetScrimBuilder;
//   final double? drawerEdgeDragWidth;
//   final bool drawerEnableOpenDragGesture;
//   final bool endDrawerEnableOpenDragGesture;
//   final String? restorationId;
//   const ScaffoldAttr({
//       this.key,
//       this.appBar,
//       this.body,
//       this.floatingActionButton,
//       this.floatingActionButtonLocation,
//       this.floatingActionButtonAnimator,
//       this.persistentFooterButtons,
//       this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
//       this.persistentFooterDecoration,
//       this.drawer,
//       this.onDrawerChanged,
//       this.endDrawer,
//       this.onEndDrawerChanged,
//       this.bottomNavigationBar,
//       this.bottomSheet,
//       this.backgroundColor,
//       this.resizeToAvoidBottomInset,
//       this.primary = true,
//       this.drawerDragStartBehavior = DragStartBehavior.start,
//       this.extendBody = false,
//       this.drawerBarrierDismissible = true,
//       this.extendBodyBehindAppBar = false,
//       this.drawerScrimColor,
//       this.bottomSheetScrimBuilder,
//       this.drawerEdgeDragWidth,
//       this.drawerEnableOpenDragGesture = true,
//       this.endDrawerEnableOpenDragGesture = true,
//       this.restorationId,
//   });

// }