import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  final String _key = 'isDarkMode';
  SharedPreferences? _prefs;

  Future<ThemeService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  ThemeMode get theme {
    if (_prefs == null) return ThemeMode.system;
    
    final isDark = _prefs!.getBool(_key);
    if (isDark == null) return ThemeMode.system;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void saveThemeToBox(bool isDarkMode) {
    _prefs?.setBool(_key, isDarkMode);
  }

  void switchTheme() {
    final bool currentIsDark = Get.isDarkMode;
    Get.changeThemeMode(currentIsDark ? ThemeMode.light : ThemeMode.dark);
    saveThemeToBox(!currentIsDark);
  }
}
