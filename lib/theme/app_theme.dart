import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds the app's light and dark ThemeData using a deliberate
/// Amiri (Arabic display) + Outfit (UI sans) type pairing.
class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    final outfit = GoogleFonts.outfitTextTheme(base);
    return outfit.copyWith(
      displayLarge: outfit.displayLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: outfit.headlineMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: outfit.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: outfit.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: outfit.bodyLarge?.copyWith(color: textColor),
      bodyMedium: outfit.bodyMedium?.copyWith(color: textColor),
      labelLarge: outfit.labelLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static ThemeData get darkTheme {
    const textColor = AppColors.textOnDarkPrimary;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.tealPrimaryLight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.tealPrimaryLight,
        secondary: AppColors.gold,
        surface: AppColors.darkSurface,
        error: AppColors.danger,
      ),
      textTheme: _buildTextTheme(ThemeData.dark().textTheme, textColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textColor,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textOnDarkSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: AppColors.darkSurfaceAlt,
    );
  }

  static ThemeData get lightTheme {
    const textColor = AppColors.textWarmDark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.tealPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.tealPrimary,
        secondary: AppColors.gold,
        surface: AppColors.lightSurface,
        error: AppColors.danger,
      ),
      textTheme: _buildTextTheme(ThemeData.light().textTheme, textColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textColor,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.tealPrimary,
        unselectedItemColor: Color(0xFF8A8478),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: AppColors.lightSurfaceAlt,
    );
  }

  /// Arabic display text style using Amiri, used for Quran verses
  /// and other Arabic script throughout the app.
  static TextStyle arabicStyle({
    required Color color,
    double fontSize = 24,
    FontWeight weight = FontWeight.w400,
    double height = 1.8,
  }) {
    return GoogleFonts.amiri(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
      height: height,
    );
  }
}
