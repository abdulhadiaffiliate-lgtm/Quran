import 'package:flutter/material.dart';

/// Centralized color palette. Deliberately avoids the expected
/// bright-green-and-gold "Islamic app" look in favor of a calmer,
/// more distinctive teal/ivory/muted-gold identity.
class AppColors {
  AppColors._();

  // Dark theme
  static const Color darkBg = Color(0xFF0E2A2E); // deep teal-charcoal
  static const Color darkSurface = Color(0xFF153539); // slightly lighter panel
  static const Color darkSurfaceAlt = Color(0xFF1D4146);
  static const Color tealPrimary = Color(0xFF1B4B4F); // brand teal
  static const Color tealPrimaryLight = Color(0xFF2E6B70);

  // Light theme
  static const Color lightBg = Color(0xFFF7F3EA); // warm ivory, not pure white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEFE8D8);
  static const Color textWarmDark = Color(0xFF2D2A24); // warm near-black

  // Shared accent
  static const Color gold = Color(0xFFC9A461); // muted, not gaudy
  static const Color goldLight = Color(0xFFDDC28A);
  static const Color brownSecondary = Color(0xFF8B6F47);

  // Functional
  static const Color success = Color(0xFF4F9A7D);
  static const Color danger = Color(0xFFB75C5C);

  // Text on dark
  static const Color textOnDarkPrimary = Color(0xFFF5F1E6);
  static const Color textOnDarkSecondary = Color(0xFFAFC4C2);
}
