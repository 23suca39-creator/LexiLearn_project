import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/settings_provider.dart';

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
}
class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late FlutterTts flutterTts;
  List<dynamic> voices = [];

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    loadVoices();
  }

  Future<void> loadVoices() async {
    final availableVoices = await flutterTts.getVoices;
    setState(() {
      voices = availableVoices ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Font Size'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  min: 8,
                  max: 48,
                  divisions: 40,
                  label: settings.fontSize.round().toString(),
                  value: settings.fontSize,
                  onChanged: settings.setFontSize,
                ),
                Text('Current font size: ${settings.fontSize.round()}'),
              ],
            ),
          ),
          ListTile(
            title: const Text('Voice'),
            subtitle: voices.isEmpty
                ? const Text('Loading voices...')
                : DropdownButton<String>(
                    isExpanded: true,
                    value: settings.selectedVoiceName ?? voices.first['name'],
                    items: voices
                        .map((voice) => DropdownMenuItem<String>(
                              value: voice['name'],
                              child: Text('${voice['name']} (${voice['locale']})'),
                            ))
                        .toList(),
                    onChanged: (newVoiceName) {
                      if (newVoiceName != null) {
                        final voiceLocale = voices
                            .firstWhere((v) => v['name'] == newVoiceName)['locale'];
                        settings.setSelectedVoice(newVoiceName, voiceLocale);
                      }
                    },
                  ),
          ),
          ListTile(
            title: const Text('Voice Pitch'),
            subtitle: Slider(
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: settings.voicePitch.toStringAsFixed(2),
              value: settings.voicePitch,
              onChanged: settings.setVoicePitch,
            ),
          ),
          ListTile(
            title: const Text('Speech Rate'),
            subtitle: Slider(
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: settings.speechRate.toStringAsFixed(2),
              value: settings.speechRate,
              onChanged: settings.setSpeechRate,
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: settings.toggleDarkMode,
          ),
          ListTile(
            title: const Text('App Theme'),
            subtitle: DropdownButton<String>(
              value: settings.selectedThemeName,
              isExpanded: true,
              items: settings.availableThemes
                  .map((name) => DropdownMenuItem<String>(value: name, child: Text(name)))
                  .toList(),
              onChanged: (val) {
                if (val != null) settings.setSelectedTheme(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
