import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart' as dio show FormData;
import '../../data/models/user.dart' show User;
import '../api/api_result.dart' show ApiResult;
import '../components/widgets/loading_widget.dart' show LoadingWidget;
import '../themes/app_colors.dart';


class MyPUtils
{
  static void showSnackbar(
    String title, 
    String message, {
      bool isError = false, 
      SnackPosition position = SnackPosition.BOTTOM,
    Widget? icon,
    Duration duration = const Duration(milliseconds: 2500),
  }) 
  {
    // Close existing snackbars to prevent queuing and annoying behavior
    if (Get.isSnackbarOpen) {
      try {
        Get.closeAllSnackbars();
      } catch (e) {
        debugPrint('Error closing snackbars: $e');
      }
    }

    Get.snackbar(
      title,
      message,
      snackPosition: position,
      backgroundColor: isError ? AppColors.red.withValues(alpha: 0.9) : AppColors.green.withValues(alpha: 0.9),
      colorText: AppColors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: icon ?? Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: Colors.white),
      duration: duration,
      instantInit: true,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void showLoading() 
  {
    Get.dialog(
      const LoadingWidget(),
      barrierDismissible: false,
    );
  }

  static void hideLoading() 
  {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  static void showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    bool isDanger = false,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(cancelLabel, style: TextStyle(color: AppColors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? AppColors.red : AppColors.green,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// @param [user]: `User` object is 
  /// - `User`
  /// - `Map<String, dynamic>`
  /// - `dio.FormData`
  /// -
  /// - `Rx<User>`
  /// - `Rx<Map<String, dynamic>>`
  /// - `Rx<dio.FormData>`
  /// -
  /// - `ApiResult<User>`
  /// - `ApiResult<Map<String, dynamic>>`
  /// - `ApiResult<dio.FormData>`
  /// 
  /// @param [defaultUser]: `User` default value
  /// 
  /// @return `User`
  static User proccessUser(dynamic user, {User defaultUser = const User(id: 0, name: '', role: '', email: '',)})
  {
    try{
      if(user == null) throw Exception('User is null');
      return switch(user){
        User()=> user,
        Map<String, dynamic>()=> User.fromJson(user),
        dio.FormData()=> User.fromJson(user.fields),

        Rx<User>()=> user.value,
        Rx<Map<String, dynamic>>()=> User.fromJson(user.value),
        Rx<dio.FormData>()=> User.fromJson(user.value.fields),

        ApiResult<User>() => ((){
          if(user.data != null) return user.data!;
          throw Exception('User is null');
        })(),
        ApiResult<Map<String, dynamic>>() => ((){
          if(user.data != null) return User.fromJson(user.data!);
          throw Exception('User is null');
        })(),
        ApiResult<dio.FormData>() => ((){
          if(user.data != null) return User.fromJson(user.data!.fields);
          throw Exception('User is null');
        })(),
        _=> user.value
      };
    }
    catch(e)
    {
      return defaultUser;
    }
  }
  

}






// num toNum(val, [num defaultValue = 0]) 
// {
//   if (val is num) return val;
//   if (val is String) return num.parse(val);
//   return defaultValue;
// }

// String toStr(val, [String defaultValue = '']) 
// {
//   if (val is String) return val;
//   try 
//   {
//     return val.toString();
//   } 
//   catch (e) 
//   {
//     return defaultValue;
//   }
// }