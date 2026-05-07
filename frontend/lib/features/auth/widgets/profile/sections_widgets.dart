
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/themes/app_colors.dart' show AppColors;

class  ProfileSectionsWidgets {
  static Widget title(BuildContext context, String title) {
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: AppColors.textBody.getByBrightness(brightness),
        ),
      ),
    );
  }


  static Widget tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required bool showBorder,
  }) {
    final brightness = Theme.of(context).brightness;
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1),
                  width: 1,
                ),
              )
            : null,
      ),
      child: ListTile(
        leading: iconContainer(context, icon, color),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSubtitle.getByBrightness(brightness),
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textBody.getByBrightness(brightness),
          ),
        ),
      ),
    );
  }

 static Widget iconContainer(BuildContext context, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
   

  static Widget textInputField(
    TextEditingController controller, String label, IconData icon, Brightness brightness, 
    {RxBool? obscureText, TextInputType? keyboardType, String? Function(String?)? validator}
  ) {
    Widget buildField(bool isObscured, Widget? suffix) {
      return TextFormField(
        controller: controller,
        obscureText: isObscured,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: AppColors.textBody.getByBrightness(brightness)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSubtitle.getByBrightness(brightness)),
          filled: true,
          fillColor: AppColors.background.getByBrightness(brightness),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary.getByBrightness(brightness)),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      );
    }

    if (obscureText == null) return buildField(false, null);

    return Obx(() => buildField(
      obscureText.value,
      IconButton(
        icon: Icon(
          obscureText.value ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: AppColors.textSubtitle.getByBrightness(brightness),
        ),
        onPressed: () => obscureText.toggle(),
      ),
    ));
  }
  
  static Widget divider(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Divider(
      height: 1,
      indent: 70,
      color: AppColors.textSubtitle.getByBrightness(brightness).withValues(alpha: 0.1),
    );
  }

  static TextStyle settingTextStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textBody.getByBrightness(brightness),
    );
  }

}
  