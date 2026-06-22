import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle serif({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.tinta,
    double? height,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.tinta,
    double? letterSpacing,
  }) {
    return GoogleFonts.mulish(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme get textTheme {
    return GoogleFonts.mulishTextTheme().copyWith(
      displayLarge: serif(fontSize: 32, fontWeight: FontWeight.w600),
      displayMedium: serif(fontSize: 26, fontWeight: FontWeight.w600),
      headlineSmall: serif(fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge: serif(fontSize: 20, fontWeight: FontWeight.w500),
      titleMedium: serif(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: sans(fontSize: 15),
      bodyMedium: sans(fontSize: 14),
      bodySmall: sans(fontSize: 12, color: AppColors.bege),
      labelLarge: sans(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }
}
