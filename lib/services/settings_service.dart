import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const _keyDarkMode = 'dark_mode';
  static const _keyLanguage = 'language';
  static const _keyNotifications = 'notifications';

  bool _darkMode = false;
  String _language = 'pt';
  bool _notifications = true;

  bool get darkMode => _darkMode;
  String get language => _language;
  bool get notifications => _notifications;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_keyDarkMode) ?? false;
    _language = prefs.getString(_keyLanguage) ?? 'pt';
    _notifications = prefs.getBool(_keyNotifications) ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    notifyListeners();
  }
}
