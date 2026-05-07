import 'package:flutter/material.dart' show 
  Brightness, Color, LinearGradient, Alignment, Colors, Theme, BuildContext, MaterialColor, MaterialAccentColor;

class AppColorSet<T> 
{
  final T light;
  final T dark;

  const AppColorSet({required this.light, required this.dark});

  T getByBrightness(Brightness brightness) => brightness == Brightness.dark ? dark : light;
}

class AppColors 
{
  // Primary & Secondary
  static const primary = AppColorSet(light: Color(0xFFD4AF37), dark: Color(0xFFD4AF37));
  static const secondary = AppColorSet(light: Color(0xFFD4AF37), dark: Color(0xFFF3E5AB)); 
  static const accent = AppColorSet(light: Color(0xFFE11D48), dark: Color(0xFFE11D48)); 

  // Functional colors
  static const success = AppColorSet(light: Color(0xFF10B981), dark: Color(0xFF10B981));
  static const warning = AppColorSet(light: Color(0xFFF59E0B), dark: Color(0xFFF59E0B));
  static const info = AppColorSet(light: Color(0xFF0EA5E9), dark: Color(0xFF0EA5E9));
  static const error = AppColorSet(light: Color(0xFFE11D48), dark: Color(0xFFE11D48));
  static const rejected = AppColorSet(light: Color(0xFF7C3AED), dark: Color(0xFF8B5CF6));

  // Background & Surface
  static const background = AppColorSet(light: Color(0xFFF8FAFC), dark: Color(0xFF020617)); // Pearl White & Very Dark Blue
  static const surface = AppColorSet(light: Color(0xFFFFFFFF), dark: Color(0xFF0F172A)); // White & Dark Navy
  static const boxDecoration = AppColorSet(light: Color(0xFFFFFFFF), dark: Color(0xFF1E293B));
  static const card = surface;
  static const cardClient = AppColorSet(light: Color(0xFFF1F5F9), dark: Color(0xFF1E293B));
  static const searchBarFillColor = AppColorSet(light: Color(0xFF0F172A), dark: Color(0xFF1E293B));
  static const appBarBackground = AppColorSet(light: Color(0xFFF8FAFC), dark: Color(0xFF020617));

  // Text colors
  static const textPrimary = AppColorSet(light: Color(0xFF0F172A), dark: Color(0xFFF1F5F9));
  static const textBody = textPrimary;
  static const textBasec = AppColorSet(light: Colors.black, dark: Colors.white);
  static const textInverse = AppColorSet(light: Colors.white, dark: Colors.black);
  static const w_b = textInverse;
  static const textSubtitle = AppColorSet(light: Color(0xFF64748B), dark: Color(0xFF94A3B8));
  static const text = AppColorSet(light: Color(0xFF94A3B8), dark: Color(0xFF64748B));

  // Status Special backgrounds (Pastels)
  static const primaryStatusBg = AppColorSet(light: Color(0xFFF1F5F9), dark: Color(0xFF1E293B)); // Slate pastel
  static const successStatusBg = AppColorSet(light: Color(0xFFECFDF5), dark: Color(0xFF064E3B));
  static const warningStatusBg = AppColorSet(light: Color(0xFFFFFBEB), dark: Color(0xFF78350F));
  static const dangerStatusBg = AppColorSet(light: Color(0xFFFEF2F2), dark: Color(0xFF7F1D1D));

  // Common UI Colors mapped cleanly to raw Colors to preserve `const` rules
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const MaterialColor grey = Colors.grey;
  
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  
  // App specific const mappings for Colors.* global replacement
  static const MaterialColor red = Colors.red;
  static const MaterialColor green = Colors.green;
  static const MaterialColor blue = Colors.blue;
  static const MaterialColor amber = Colors.amber;
  static const MaterialColor orange = Colors.orange;
  static const MaterialColor yellow = Colors.yellow;
  static const MaterialColor purple = Colors.purple;
  static const MaterialColor pink = Colors.pink;
  static const MaterialColor cyan = Colors.cyan;
  static const MaterialColor teal = Colors.teal;
  static const MaterialColor indigo = Colors.indigo;
  static const MaterialColor brown = Colors.brown;
  static const MaterialColor lightBlue = Colors.lightBlue;
  static const MaterialColor lightGreen = Colors.lightGreen;
  static const MaterialColor deepPurple = Colors.deepPurple;
  static const MaterialColor deepOrange = Colors.deepOrange;
  static const MaterialColor blueGrey = Colors.blueGrey;

  static const MaterialAccentColor blueAccent = Colors.blueAccent;
  static const MaterialAccentColor redAccent = Colors.redAccent;
  static const MaterialAccentColor greenAccent = Colors.greenAccent;
  static const MaterialAccentColor orangeAccent = Colors.orangeAccent;
  static const MaterialAccentColor purpleAccent = Colors.purpleAccent;

  static const Color white70 = Colors.white70;
  static const Color white60 = Colors.white60;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white30 = Colors.white30;
  static const Color white24 = Colors.white24;
  static const Color white12 = Colors.white12;
  static const Color white10 = Colors.white10;

  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;
  static const Color black45 = Colors.black45;
  static const Color black38 = Colors.black38;
  static const Color black26 = Colors.black26;
  static const Color black12 = Colors.black12;

  // Gradients
  static const primaryGradient = AppColorSet(
    light: LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF1E293B)], // Midnight Navy to Slate
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    dark: LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFF3E5AB)], // Gold to Champagne
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  
  // Extension Factory
  static AppColorsData of(BuildContext context) {
    return AppColorsData(Theme.of(context).brightness);
  }
}

class AppColorsData {
  final Brightness brightness;
  AppColorsData(this.brightness);

  Color get primary => AppColors.primary.getByBrightness(brightness);
  Color get secondary => AppColors.secondary.getByBrightness(brightness);
  Color get accent => AppColors.accent.getByBrightness(brightness);
  
  Color get success => AppColors.success.getByBrightness(brightness);
  Color get warning => AppColors.warning.getByBrightness(brightness);
  Color get info => AppColors.info.getByBrightness(brightness);
  Color get error => AppColors.error.getByBrightness(brightness);
  
  Color get background => AppColors.background.getByBrightness(brightness);
  Color get surface => AppColors.surface.getByBrightness(brightness);
  Color get boxDecoration => AppColors.boxDecoration.getByBrightness(brightness);
  Color get card => AppColors.card.getByBrightness(brightness);
  Color get cardClient => AppColors.cardClient.getByBrightness(brightness);
  Color get searchBarFillColor => AppColors.searchBarFillColor.getByBrightness(brightness);
  Color get appBarBackground => AppColors.appBarBackground.getByBrightness(brightness);
  
  Color get textPrimary => AppColors.textPrimary.getByBrightness(brightness);
  Color get textBody => AppColors.textBody.getByBrightness(brightness);
  Color get textBasec => AppColors.textBasec.getByBrightness(brightness);
  Color get textInverse => AppColors.textInverse.getByBrightness(brightness);
  // Color get w_b => AppColors.w_b.getByBrightness(brightness);
  Color get textSubtitle => AppColors.textSubtitle.getByBrightness(brightness);
  Color get text => AppColors.text.getByBrightness(brightness);

  Color get primaryStatusBg => AppColors.primaryStatusBg.getByBrightness(brightness);
  Color get successStatusBg => AppColors.successStatusBg.getByBrightness(brightness);
  Color get warningStatusBg => AppColors.warningStatusBg.getByBrightness(brightness);
  Color get dangerStatusBg => AppColors.dangerStatusBg.getByBrightness(brightness);

  Color get transparent => AppColors.transparent;
  Color get white => AppColors.white;
  Color get black => AppColors.black;
  Color get grey => AppColors.grey;
  Color get grey300 => AppColors.grey300;
  Color get grey500 => AppColors.grey500;

  LinearGradient get primaryGradient => AppColors.primaryGradient.getByBrightness(brightness);
}

extension AppColorExtension on BuildContext {
  AppColorsData get colors => AppColors.of(this);
}
