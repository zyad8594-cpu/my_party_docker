import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'app_colors.dart';


class AppTheme 
{
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary.light,
    scaffoldBackgroundColor: AppColors.background.light,
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary.light,
      primary: AppColors.primary.light,
      secondary: AppColors.secondary.light,
      surface: AppColors.surface.light,
      error: AppColors.accent.light,
      brightness: Brightness.light,
    ),
    
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).copyWith(
      bodyLarge:  TextStyle(color: AppColors.textBody.light, fontSize: 16),
      bodyMedium:  TextStyle(color: AppColors.textBody.light, fontSize: 14),
      titleLarge: GoogleFonts.cairo(
        color: AppColors.textBody.light,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appBarBackground.light,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.text.light),

      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.text.light,
        fontFamily: 'Cairo', // Direct fallback
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.light,
        foregroundColor: AppColors.w_b.light,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.surface.light,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.text.light.withValues(alpha: 0.05)),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface.light,
      hoverColor: AppColors.primary.light.withValues(alpha: 0.02),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.textSubtitle.light.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.textSubtitle.light.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.primary.light, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.accent.light, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      labelStyle: TextStyle(color: AppColors.textSubtitle.light, fontWeight: FontWeight.w500),
      floatingLabelStyle: TextStyle(color: AppColors.primary.light, fontWeight: FontWeight.bold),
      prefixIconColor: AppColors.primary.light,
      suffixIconColor: AppColors.textSubtitle.light,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary.dark,
    scaffoldBackgroundColor: AppColors.background.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary.dark,
      primary: AppColors.primary.dark,
      secondary: AppColors.secondary.dark,
      surface: AppColors.surface.dark,
      error: AppColors.accent.dark,
      brightness: Brightness.dark,
    ),
    
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: TextStyle(color: AppColors.textBody.dark, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textBody.dark, fontSize: 14),
      titleLarge: GoogleFonts.cairo(
        color: AppColors.textBody.dark,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appBarBackground.dark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textBody.dark),

      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textBody.dark,
        fontFamily: 'Cairo',
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.dark,
        foregroundColor: AppColors.w_b.dark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface.dark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.text.dark.withValues(alpha: 0.05)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface.dark,
      hoverColor: AppColors.primary.dark.withValues(alpha: 0.02),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.textSubtitle.dark.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.textSubtitle.dark.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.primary.dark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.accent.dark, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      labelStyle: TextStyle(color: AppColors.textSubtitle.dark, fontWeight: FontWeight.w500),
      floatingLabelStyle: TextStyle(color: AppColors.primary.dark, fontWeight: FontWeight.bold),
      prefixIconColor: AppColors.primary.dark,
      suffixIconColor: AppColors.textSubtitle.dark,
    ),
  );
}
