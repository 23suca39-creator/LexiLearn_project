import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'package:lexilearn/themes/themes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // FIXED: Changed from final field to static getter
  static Map<String, ThemeData> get themeOptions => {
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
  };

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: settings.useDyslexicFont ? 'OpenDyslexic' : null,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Font Size'),
            subtitle: Slider(
              min: 8,
              max: 48,
              divisions: 40,
              label: settings.fontSize.round().toString(),
              value: settings.fontSize,
              onChanged: settings.setFontSize,
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: settings.toggleDarkMode,
          ),
          SwitchListTile(
            title: const Text('Use Dyslexic Font'),
            value: settings.useDyslexicFont,
            onChanged: settings.toggleDyslexicFont,
          ),
          ListTile(
            title: const Text('App Theme'),
            subtitle: DropdownButton<ThemeData>(
              value: settings.selectedTheme,
              isExpanded: true,
              items: themeOptions.entries
                  .map(
                    (e) => DropdownMenuItem<ThemeData>(
                      value: e.value,
                      child: Text(e.key),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  settings.setSelectedTheme(val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
