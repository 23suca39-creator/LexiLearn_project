import 'package:flutter/material.dart';
import '../themes/themes.dart';

class SettingsProvider with ChangeNotifier {
  double _fontSize = 16.0;
  double _voicePitch = 1.0;
  double _speechRate = 1.0;
  String _selectedThemeName = 'Soft Blue 🌊';
  bool _isDarkMode = false;

  String? _selectedVoiceName;
  String? _selectedVoiceLocale;

  final List<String> availableThemes = [
    'Soft Blue 🌊',
    'Peach Coral 🍑',
    'Lavender Calm 🌸',
    'High Contrast ⚫⚪',
    'Sage Green 🌿',
    'Warm Sand 🏖️',
    'Soft Grey 🌫️',
    'Ocean Breeze 🌊💨',
    'Mint Cream 🌱',
    'Soft Coral 🌷',
    'Soft Sky ☁️',
    'Soft Lemon 🍋',
    'Soft Aqua 🌊',
    'Rosewood 🌹',

    // add other themes here...
  ];

  final Map<String, ThemeData Function(double)> themeOptions = {
    'Soft Blue 🌊': DyslexiaThemes.softBlue,
    'Peach Coral 🍑': DyslexiaThemes.peachCoral,
    'Lavender Calm 🌸': DyslexiaThemes.lavenderCalm,
    'High Contrast ⚫⚪': DyslexiaThemes.highContrast,
    'Sage Green 🌿': DyslexiaThemes.sageGreen,
    'Warm Sand 🏖️': DyslexiaThemes.warmSand,
    'Soft Grey 🌫️': DyslexiaThemes.softGrey,
    'Ocean Breeze 🌊💨': DyslexiaThemes.oceanBreeze,
    'Mint Cream 🌱': DyslexiaThemes.mintCream,
    'Soft Coral 🌷': DyslexiaThemes.softCoral,
    'Soft Sky ☁️': DyslexiaThemes.softSky,
    'Soft Lemon 🍋': DyslexiaThemes.softLemon,
    'Soft Aqua 🌊': DyslexiaThemes.softAqua,
    'Rosewood 🌹': DyslexiaThemes.rosewood,
    // add other themes here...

  };

  double get fontSize => _fontSize.clamp(8, 48);
  double get voicePitch => _voicePitch.clamp(0.5, 2.0);
  double get speechRate => _speechRate.clamp(0.5, 2.0);
  String get selectedThemeName => _selectedThemeName;
  ThemeData get selectedTheme => themeOptions[_selectedThemeName]!(fontSize);
  bool get isDarkMode => _isDarkMode;

  String? get selectedVoiceName => _selectedVoiceName;
  String? get selectedVoiceLocale => _selectedVoiceLocale;

  void setFontSize(double? size) {
    if (size == null) return;
    _fontSize = size.clamp(8, 48);
    notifyListeners();
  }

  void setVoicePitch(double pitch) {
    _voicePitch = pitch.clamp(0.5, 2.0);
    notifyListeners();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate.clamp(0.5, 2.0);
    notifyListeners();
  }

  void setSelectedTheme(String themeName) {
    if (themeOptions.containsKey(themeName)) {
      _selectedThemeName = themeName;
      notifyListeners();
    }
  }

  void toggleDarkMode(bool enabled) {
    _isDarkMode = enabled;
    notifyListeners();
  }

  void setSelectedVoice(String? voiceName, String? locale) {
    _selectedVoiceName = voiceName;
    _selectedVoiceLocale = locale;
    notifyListeners();
  }
}
