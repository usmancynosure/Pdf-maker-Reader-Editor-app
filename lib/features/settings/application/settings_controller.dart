import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_settings.dart';

/// Provides the [SharedPreferences] instance. Overridden in `main()` with the
/// already-loaded instance so settings can be read synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('override sharedPreferencesProvider in main()'),
);

/// Reads/writes persisted [AppSettings].
class SettingsController extends Notifier<AppSettings> {
  static const _kTheme = 'theme_mode';
  static const _kLock = 'app_lock';
  static const _kSync = 'cloud_sync';
  static const _kQuality = 'export_quality';
  static const _kPro = 'is_pro';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    return AppSettings(
      themeMode: _themeFrom(_prefs.getString(_kTheme)),
      appLock: _prefs.getBool(_kLock) ?? false,
      cloudSync: _prefs.getBool(_kSync) ?? false,
      quality: _qualityFrom(_prefs.getString(_kQuality)),
      isPro: _prefs.getBool(_kPro) ?? false,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setString(_kTheme, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  void setAppLock(bool value) {
    _prefs.setBool(_kLock, value);
    state = state.copyWith(appLock: value);
  }

  void setCloudSync(bool value) {
    _prefs.setBool(_kSync, value);
    state = state.copyWith(cloudSync: value);
  }

  void setQuality(ExportQuality quality) {
    _prefs.setString(_kQuality, quality.name);
    state = state.copyWith(quality: quality);
  }

  void setPro(bool value) {
    _prefs.setBool(_kPro, value);
    state = state.copyWith(isPro: value);
  }

  ThemeMode _themeFrom(String? v) => switch (v) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  ExportQuality _qualityFrom(String? v) => switch (v) {
        'medium' => ExportQuality.medium,
        'low' => ExportQuality.low,
        _ => ExportQuality.high,
      };
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
