import 'package:flutter/foundation.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  bool _darkMode = false;

  bool get darkMode => _darkMode;

  void syncDarkMode(bool value) {
    if (_darkMode == value) return;
    _darkMode = value;
    notifyListeners();
  }
}
