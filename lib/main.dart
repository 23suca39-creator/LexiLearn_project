import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/content_item.dart';
import 'models/user.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/content_library_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/progress_tracker_screen.dart';
import 'screens/speech_interaction_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ContentItemAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<ContentItem>('contentBox');
  await Hive.openBox<User>('usersBox');
  await Hive.openBox('rememberMeBox');
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
        theme: settings.selectedTheme, // Dynamic, no .apply!
        darkTheme: ThemeData.dark(),   // Use a custom dark theme if you want, or a builder like above
        themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/home',
        routes: {
          '/home': (ctx) => const HomeScreenWithLoginDialog(),
          '/content-library': (ctx) => ContentLibraryScreen(),
          '/settings': (ctx) => SettingsScreen(),
          '/progress': (ctx) => ProgressTrackerScreen(),
          '/speech-interaction': (ctx) => SpeechInteractionScreen(),
          '/forgot-password': (ctx) => ForgotPasswordScreen(),
        },
      ),
    );
  }
}

class HomeScreenWithLoginDialog extends StatefulWidget {
  const HomeScreenWithLoginDialog({Key? key}) : super(key: key);

  @override
  _HomeScreenWithLoginDialogState createState() => _HomeScreenWithLoginDialogState();
}

class _HomeScreenWithLoginDialogState extends State<HomeScreenWithLoginDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginDialog();
    });
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 400,
          height: 600,
          child: LoginScreen(
            onRegisterRequested: _showRegisterDialog,
          ),
        ),
      ),
    );
  }

  void _showRegisterDialog() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 400,
          height: 700,
          child: RegisterScreen(
            onLoginRequested: _showLoginDialog,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
