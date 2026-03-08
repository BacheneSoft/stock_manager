import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1976D2);
  static const secondary = Color(0xFFFFB300);
  static const error = Color(0xFFD32F2F);
  static const background = Color(0xFFF5F6FA);
  static const surface = Colors.white;
  static const onPrimary = Colors.white;
  static const onSecondary = Color(0xFF212121);
  static const onBackground = Color(0xFF212121);
  static const onSurface = Color(0xFF212121);
  static const onError = Colors.white;
}

class AppTheme {
  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    error: AppColors.error,
    onError: AppColors.onError,
    background: AppColors.surface, // Updated to use the new AppColors.surface
    onBackground:
        AppColors.onSurface, // Updated to use the new AppColors.onSurface
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  );
}
