import 'package:flutter/material.dart';

/// Prisma Scan color system.
///
/// Derived from the holographic-glassmorphism design concept:
/// pink -> lavender -> periwinkle -> cyan washes over frosted glass.
class AppColors {
  AppColors._();

  // ---- Holographic wash ----
  static const Color pink = Color(0xFFF8A5E0);
  static const Color lavender = Color(0xFFB98CFF);
  static const Color periwinkle = Color(0xFF8AA8FF);
  static const Color cyan = Color(0xFF7EE8FA);

  // ---- Brand / accents ----
  static const Color accent = Color(0xFF7C4DFF); // primary violet
  static const Color ctaPink = Color(0xFFEC4899);
  static const Color ctaViolet = Color(0xFFA855F7);
  static const Color ctaAmber = Color(0xFFFB923C);

  // ---- Functional action tints (icon chips) ----
  static const Color gPinkA = Color(0xFFF472B6);
  static const Color gPinkB = Color(0xFFEC4899);
  static const Color gVioletA = Color(0xFFA78BFA);
  static const Color gVioletB = Color(0xFF7C4DFF);
  static const Color gBlueA = Color(0xFF60A5FA);
  static const Color gBlueB = Color(0xFF3B82F6);
  static const Color gTealA = Color(0xFF5EEAD4);
  static const Color gTealB = Color(0xFF14B8A6);
  static const Color gAmberA = Color(0xFFFBBF24);
  static const Color gAmberB = Color(0xFFF97316);

  // ---- Semantic ----
  static const Color success = Color(0xFF14B8A6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // ---- Light theme neutrals (cool-biased, chosen not defaulted) ----
  static const Color ink = Color(0xFF1A1726); // primary text
  static const Color inkSoft = Color(0xFF241C38);
  static const Color muted = Color(0xFF6B6880); // secondary text
  static const Color line = Color(0xFFEDE9F5);
  static const Color surfaceLight = Color(0xFFFBF9FF);
  static const Color surfaceLight2 = Color(0xFFF4F1FB);

  // ---- Dark theme neutrals ----
  static const Color inkDark = Color(0xFFF3F0FB);
  static const Color mutedDark = Color(0xFF9C97B4);
  static const Color surfaceDark = Color(0xFF1B1826);
  static const Color surfaceDark2 = Color(0xFF121019);
  static const Color lineDark = Color(0x14FFFFFF);

  // ---- Glass fills ----
  static const Color glassLight = Color(0x9EFFFFFF); // ~0.62
  static const Color glassStrong = Color(0xD1FFFFFF); // ~0.82
  static const Color glassDark = Color(0x1FFFFFFF);
}
