import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable gradients for the holographic UI.
class AppGradients {
  AppGradients._();

  /// Full-screen holographic background wash.
  static const LinearGradient holo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.pink, Color(0xFFC6A0F5), Color(0xFF93A9FF), AppColors.cyan],
    stops: [0.0, 0.34, 0.66, 1.0],
  );

  /// Softer holo (used for header cards / avatars).
  static const LinearGradient holoSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBB6E6), Color(0xFFC9A2F2), Color(0xFF8FC6F5)],
    stops: [0.0, 0.45, 1.0],
  );

  /// Primary call-to-action (pink -> violet -> amber).
  static const LinearGradient cta = LinearGradient(
    begin: Alignment(-1, -0.2),
    end: Alignment(1, 0.2),
    colors: [AppColors.ctaViolet, AppColors.ctaPink, AppColors.ctaAmber],
    stops: [0.0, 0.52, 1.0],
  );

  static const LinearGradient pink =
      LinearGradient(colors: [AppColors.gPinkA, AppColors.gPinkB]);
  static const LinearGradient violet =
      LinearGradient(colors: [AppColors.gVioletA, AppColors.gVioletB]);
  static const LinearGradient blue =
      LinearGradient(colors: [AppColors.gBlueA, AppColors.gBlueB]);
  static const LinearGradient teal =
      LinearGradient(colors: [AppColors.gTealA, AppColors.gTealB]);
  static const LinearGradient amber =
      LinearGradient(colors: [AppColors.gAmberA, AppColors.gAmberB]);
}
