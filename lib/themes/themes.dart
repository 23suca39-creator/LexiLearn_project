import 'package:flutter/material.dart';

const String dyslexiaFont = 'OpenDyslexic';

class DyslexiaThemes {
  static final ThemeData softBlue = _buildTheme(
    backgroundColor: Color(0xFFE6F0FA),
    textColor: Color(0xFF003366),
    accentColor: Colors.teal,
  );

  static final ThemeData peachCoral = _buildTheme(
    backgroundColor: Color(0xFFFFF3E0),
    textColor: Color(0xFF3E2723),
    accentColor: Color(0xFFFF7043),
  );

  static final ThemeData lavenderCalm = _buildTheme(
    backgroundColor: Color(0xFFF3E5F5),
    textColor: Color(0xFF311B92),
    accentColor: Color(0xFF81C784),
  );

  static final ThemeData highContrast = _buildTheme(
    backgroundColor: Color(0xFFFFFDE7),
    textColor: Colors.black,
    accentColor: Colors.blue,
  );

  static final ThemeData sageGreen = _buildTheme(
    backgroundColor: Color(0xFFE8F5E9),
    textColor: Color(0xFF1B5E20),
    accentColor: Color(0xFFA5D6A7),
  );

  static final ThemeData warmSand = _buildTheme(
    backgroundColor: Color(0xFFFFF8E1),
    textColor: Color(0xFF3E2723),
    accentColor: Color(0xFFFFAB91),
  );

  static final ThemeData softGrey = _buildTheme(
    backgroundColor: Color(0xFFF5F5F5),
    textColor: Color(0xFF212121),
    accentColor: Color(0xFF90A4AE),
  );

  static final ThemeData oceanBreeze = _buildTheme(
    backgroundColor: Color(0xFFE1F5FE),
    textColor: Color(0xFF004D40),
    accentColor: Color(0xFF4DD1E),
  );

  static final ThemeData mintCream = _buildTheme(
    backgroundColor: Color(0xFFE0F2F1),
    textColor: Color(0xFF1B5E20),
    accentColor: Color(0xFFA5D6A7),
  );

  static final ThemeData softCoral = _buildTheme(
    backgroundColor: Color(0xFFFFEBEE),
    textColor: Color(0xFFB71C1C),
    accentColor: Color(0xFFFF8A80),
  );

  static final ThemeData softSky = _buildTheme(
    backgroundColor: Color(0xFFE1F5FE),
    textColor: Color(0xFF002F6C),
    accentColor: Color(0xFF81D4FA),
  );

  static final ThemeData softLemon = _buildTheme(
    backgroundColor: Color(0xFFFFFDE7),
    textColor: Color(0xFF827717),
    accentColor: Color(0xFFFFF176),
  );

  static final ThemeData softAqua = _buildTheme(
    backgroundColor: Color(0xFFE0F7FA),
    textColor: Color(0xFF004D40),
    accentColor: Color(0xFF4DD1E),
  );

  static final ThemeData rosewood = _buildTheme(
    backgroundColor: Color(0xFFFCE4EC),
    textColor: Color(0xFF880E4F),
    accentColor: Color(0xFFF48FB1),
  );

  static ThemeData _buildTheme({
    required Color backgroundColor,
    required Color textColor,
    required Color accentColor,
  }) {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: accentColor,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        onPrimary: Colors.white,
        background: backgroundColor,
        onBackground: textColor,
        surface: Colors.white,
        onSurface: textColor,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        iconTheme: IconThemeData(color: accentColor),
      ),
      cardColor: Colors.white,
      iconTheme: IconThemeData(color: accentColor),
      buttonTheme: ButtonThemeData(
        buttonColor: accentColor,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
