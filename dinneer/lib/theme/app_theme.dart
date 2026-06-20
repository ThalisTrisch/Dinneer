import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.terracota,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.terracota,
      onPrimary: Colors.white,
      secondary: AppColors.tan,
      onSecondary: AppColors.tanTexto,
      surface: AppColors.marfim,
      onSurface: AppColors.tinta,
      error: AppColors.erro,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.creme,
      textTheme: AppTypography.textTheme,
      iconTheme: const IconThemeData(color: AppColors.tinta),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creme,
        foregroundColor: AppColors.tinta,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.serif(fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: AppColors.marfim,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracota,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.tan,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          textStyle: AppTypography.sans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.marfim,
        hintStyle: AppTypography.sans(color: AppColors.bege),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xl,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.bordaSuave),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.bordaSuave),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.terracota, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.marfim,
        selectedColor: AppColors.terracota,
        side: const BorderSide(color: AppColors.bordaSuave),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        labelStyle: AppTypography.sans(fontSize: 13),
        secondaryLabelStyle: AppTypography.sans(
          fontSize: 13,
          color: Colors.white,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.bordaSuave,
        thickness: 0.6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.terracota,
      ),
    );
  }
}
