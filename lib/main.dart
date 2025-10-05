import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/content_item.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';


import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/content_library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/progress_tracker_screen.dart';
import 'screens/speech_interaction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ContentItemAdapter()); // generated adapter
  await Hive.openBox<ContentItem>('contentBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: const LexiApp(),
    ),
  );
}

class LexiApp extends StatelessWidget {
  const LexiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LexiApp',
        theme: settings.selectedTheme.copyWith(
          textTheme: settings.selectedTheme.textTheme.apply(
            fontFamily: settings.useDyslexicFont ? 'OpenDyslexic' : null,
            fontSizeFactor: settings.fontSize / 16,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          textTheme: ThemeData.dark().textTheme.apply(
                fontFamily: settings.useDyslexicFont ? 'OpenDyslexic' : null,
                fontSizeFactor: settings.fontSize / 16,
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (ctx) => const LoginScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/content-library': (ctx) => ContentLibraryScreen(),
          '/settings': (ctx) =>  SettingsScreen(),
          '/progress': (ctx) =>  ProgressTrackerScreen(),
          '/speech-interaction': (ctx) => SpeechInteractionScreen(),
        },
      ),
    );
  }
}
