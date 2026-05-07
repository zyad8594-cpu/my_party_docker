// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:window_manager/window_manager.dart';
// import 'core/themes/app_colors.dart';


// Future<void> windowManagerInit({Size? size}) async {
//   if (kIsWeb || (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
//     return;
//   }
  
//   size = size ?? Size(400, 700);
//   WidgetsFlutterBinding.ensureInitialized();
//   await windowManager.ensureInitialized();

//   WindowOptions windowOptions = WindowOptions(
//     size: size,
//     center: true,
//     maximumSize: size,
//     minimumSize: size,
//     backgroundColor: AppColors.transparent,
//     title: 'تطبيق مناسابتي',
//     titleBarStyle: TitleBarStyle.normal,
//     windowButtonVisibility: false,
//   );
//   // تعيين خيارات النافذة

//   await windowManager.waitUntilReadyToShow(windowOptions, () async {
//     await windowManager.show();
//     await windowManager.focus();
//   });
// }
