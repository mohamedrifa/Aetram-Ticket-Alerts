import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      surface: AppColors.surface,
      error: AppColors.error,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme,
      cardColor: AppColors.card,
      dividerColor: AppColors.border,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.primaryText),
        bodyMedium: TextStyle(color: AppColors.secondaryText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: TextStyle(color: AppColors.primaryText),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
