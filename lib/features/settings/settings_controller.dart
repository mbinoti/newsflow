import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.country = 'br',
    this.textScale = 1.0,
  });

  final ThemeMode themeMode;
  final String country;
  final double textScale;

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? country,
    double? textScale,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    country: country ?? this.country,
    textScale: textScale ?? this.textScale,
  );
}

class SettingsController extends ChangeNotifier {
  SettingsController(this._preferences) {
    final themeName = _preferences.getString('themeMode');
    _settings = AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == themeName,
        orElse: () => ThemeMode.system,
      ),
      country: _preferences.getString('country') ?? 'br',
      textScale: _preferences.getDouble('textScale') ?? 1,
    );
  }

  final SharedPreferences _preferences;
  late AppSettings _settings;

  AppSettings get settings => _settings;

  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
    await _preferences.setString('themeMode', mode.name);
  }

  Future<void> setCountry(String country) async {
    _settings = _settings.copyWith(country: country);
    notifyListeners();
    await _preferences.setString('country', country);
  }

  Future<void> setTextScale(double scale) async {
    _settings = _settings.copyWith(textScale: scale);
    notifyListeners();
    await _preferences.setDouble('textScale', scale);
  }
}
