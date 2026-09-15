import 'package:flutter/material.dart';

enum ExportQuality { high, medium, low }

extension ExportQualityX on ExportQuality {
  String get label => switch (this) {
        ExportQuality.high => 'High · 300 DPI',
        ExportQuality.medium => 'Medium · 200 DPI',
        ExportQuality.low => 'Low · 150 DPI',
      };
}

/// All persisted user preferences.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.appLock = false,
    this.cloudSync = false,
    this.quality = ExportQuality.high,
    this.isPro = false,
  });

  final ThemeMode themeMode;
  final bool appLock;
  final bool cloudSync;
  final ExportQuality quality;
  final bool isPro;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? appLock,
    bool? cloudSync,
    ExportQuality? quality,
    bool? isPro,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      appLock: appLock ?? this.appLock,
      cloudSync: cloudSync ?? this.cloudSync,
      quality: quality ?? this.quality,
      isPro: isPro ?? this.isPro,
    );
  }
}
