import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive user settings. Anything secret belongs in TokenStorage.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _localeKey = 'locale';
  static const _themeKey = 'theme_mode';
  static const _onboardedKey = 'has_onboarded';
  static const _mapThemeKey = 'map_theme';

  /// Null means "follow the device language".
  Locale? get locale {
    final code = _prefs.getString(_localeKey);
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }

  ThemeMode get themeMode {
    final value = _prefs.getString(_themeKey);
    return switch (value) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      // The cream page with dark cards is the product's identity, so the
      // light theme is the default rather than following the system.
      _ => ThemeMode.light,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, mode.name);

  /// Name of the selected [MapTheme]; null falls back to the app's own style.
  String? get mapTheme => _prefs.getString(_mapThemeKey);

  Future<void> setMapTheme(String name) => _prefs.setString(_mapThemeKey, name);

  bool get hasOnboarded => _prefs.getBool(_onboardedKey) ?? false;

  Future<void> setOnboarded() => _prefs.setBool(_onboardedKey, true);
}
