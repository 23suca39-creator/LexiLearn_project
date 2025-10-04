import 'package:flutter/material.dart';
import '../themes/themes.dart';

class SettingsProvider with ChangeNotifier {
  // Initial theme set to Soft Blue
  ThemeData _selectedTheme = DyslexiaThemes.softBlue;

  bool _isDarkMode = false;
  bool _useDyslexicFont = true;
  double _fontSize = 16;

  // Getters
  ThemeData get selectedTheme => _selectedTheme;
  bool get isDarkMode => _isDarkMode;
  bool get useDyslexicFont => _useDyslexicFont;
  double get fontSize => _fontSize;

  // Setters with notifyListeners()

  void setSelectedTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  void toggleDarkMode(bool enabled) {
    _isDarkMode = enabled;
    notifyListeners();
  }

  void toggleDyslexicFont(bool enabled) {
    _useDyslexicFont = enabled;
    notifyListeners();
  }

  void setFontSize(double size) {
    if (size < 8 || size > 48) return; // sensible limits
    _fontSize = size;
    notifyListeners();
  }
}
