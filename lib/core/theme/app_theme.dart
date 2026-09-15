import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Light & dark themes for Prisma Scan.
///
/// Display face: Poppins (rounded geometric, matches the reference headings).
/// Body face: Plus Jakarta Sans (clean, modern, great at small sizes).
class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color ink, Color muted) {
    final display = GoogleFonts.poppinsTextTheme();
    final body = GoogleFonts.plusJakartaSansTextTheme();
    return TextTheme(
      displayLarge: display.displayLarge?.copyWith(
          color: ink, fontWeight: FontWeight.w800, letterSpacing: -1.2),
      headlineMedium: display.headlineMedium
          ?.copyWith(color: ink, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      titleLarge: display.titleLarge
          ?.copyWith(color: ink, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: body.titleMedium?.copyWith(color: ink, fontWeight: FontWeight.w700),
      bodyLarge: body.bodyLarge?.copyWith(color: ink, height: 1.5),
      bodyMedium: body.bodyMedium?.copyWith(color: muted, height: 1.5),
      labelLarge: body.labelLarge?.copyWith(color: ink, fontWeight: FontWeight.w700),
      labelSmall: body.labelSmall?.copyWith(
          color: muted, fontWeight: FontWeight.w700, letterSpacing: 1.4),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.ctaPink,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
      textTheme: _textTheme(AppColors.ink, AppColors.muted),
      dividerColor: AppColors.line,
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceDark2,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.ctaPink,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.inkDark,
        error: AppColors.danger,
      ),
      textTheme: _textTheme(AppColors.inkDark, AppColors.mutedDark),
      dividerColor: AppColors.lineDark,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
