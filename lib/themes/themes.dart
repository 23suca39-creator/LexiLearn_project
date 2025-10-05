import 'package:flutter/material.dart';

const String dyslexiaFont = 'OpenDyslexic';

class DyslexiaThemes {
  static ThemeData softBlue(double fontSize) => _buildTheme(
    backgroundColor: Color(0xFFE6F0FA),
    textColor: Color(0xFF003366),
    accentColor: Colors.teal,
    fontSize: fontSize,
  );
  static ThemeData peachCoral(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFFFF3E0),
        textColor: Color(0xFF3E2723),
        accentColor: Color(0xFFFF7043),
        fontSize: fontSize,
      );

  static ThemeData lavenderCalm(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFF3E5F5),
        textColor: Color(0xFF311B92),
        accentColor: Color(0xFF81C784),
        fontSize: fontSize,
      );

  static ThemeData highContrast(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFFFFDE7),
        textColor: Colors.black,
        accentColor: Colors.blue,
        fontSize: fontSize,
      );

  static ThemeData sageGreen(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFE8F5E9),
        textColor: Color(0xFF1B5E20),
        accentColor: Color(0xFFA5D6A7),
        fontSize: fontSize,
      );

  static ThemeData warmSand(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFFFF8E1),
        textColor: Color(0xFF3E2723),
        accentColor: Color(0xFFFFAB91),
        fontSize: fontSize,
      );

  static ThemeData softGrey(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFF5F5F5),
        textColor: Color(0xFF212121),
        accentColor: Color(0xFF90A4AE),
        fontSize: fontSize,
      );

  static ThemeData oceanBreeze(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFE1F5FE),
        textColor: Color(0xFF004D40),
        accentColor: Color(0xFF4DD1E),
        fontSize: fontSize,
      );

  static final ThemeData oceanBreeze = _buildTheme(
    backgroundColor: Color(0xFFE1F5FE),
    textColor: Color(0xFF004D40),
    accentColor: Color(0x0ff4dd1e),
  );
  static ThemeData mintCream(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFE0F2F1),
        textColor: Color(0xFF1B5E20),
        accentColor: Color(0xFFA5D6A7),
        fontSize: fontSize,
      );

  static ThemeData softCoral(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFFFEBEE),
        textColor: Color(0xFFB71C1C),
        accentColor: Color(0xFFFF8A80),
        fontSize: fontSize,
      );

  static ThemeData softSky(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFE1F5FE),
        textColor: Color(0xFF002F6C),
        accentColor: Color(0xFF81D4FA),
        fontSize: fontSize,
      );

  static ThemeData softLemon(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFFFFDE7),
        textColor: Color(0xFF827717),
        accentColor: Color(0xFFFFF176),
        fontSize: fontSize,
      );

  static ThemeData softAqua(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFE0F7FA),
        textColor: Color(0xFF004D40),
        accentColor: Color(0xFF4DD1E),
        fontSize: fontSize,
      );

  static final ThemeData softAqua = _buildTheme(
    backgroundColor: Color(0xFFE0F7FA),
    textColor: Color(0xFF004D40),
    accentColor: Color(0x0ff4dd1e),
  );
  static ThemeData rosewood(double fontSize) => _buildTheme(
        backgroundColor: Color(0xFFFCE4EC),
        textColor: Color(0xFF880E4F),
        accentColor: Color(0xFFF48FB1),
        fontSize: fontSize,
      );

  // Repeat for all other theme getters as needed...

  static ThemeData _buildTheme({
    required Color backgroundColor,
    required Color textColor,
    required Color accentColor,
    required double fontSize,
  }) {
    final double base = fontSize.clamp(8.0, 48.0);
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: accentColor,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: textColor,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.bold,
          fontSize: base + 12,
        ),
        displayMedium: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.bold,
          fontSize: base + 10,
        ),
        displaySmall: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w600,
          fontSize: base + 8,
        ),
        headlineLarge: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.bold,
          fontSize: base + 8,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w700,
          fontSize: base + 6,
        ),
        headlineSmall: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w600,
          fontSize: base + 4,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.bold,
          fontSize: base + 6,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w600,
          fontSize: base + 2,
        ),
        titleSmall: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w500,
          fontSize: base,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontSize: base + 2,
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontSize: base,
        ),
        bodySmall: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontSize: base - 2,
        ),
        labelLarge: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w700,
          fontSize: base,
        ),
        labelMedium: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w500,
          fontSize: base - 2,
        ),
        labelSmall: TextStyle(
          color: textColor,
          fontFamily: dyslexiaFont,
          fontWeight: FontWeight.w400,
          fontSize: base - 4,
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
          fontSize: base + 6,
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
