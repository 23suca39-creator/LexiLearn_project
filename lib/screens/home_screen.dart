import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'content_library_screen.dart';
import '../providers/progress_provider.dart';
import 'speech_interaction_screen.dart';
import 'quiz_screen.dart';
import 'progress_tracker_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  int getColumnCount(double width) {
    if (width >= 1024) return 3; // Desktop: 3 columns
    if (width >= 600) return 2;  // Tablet: 2 columns
    return 1;                    // Mobile: 1 column stacked
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    const userName = 'User'; // TODO: replace with dynamic user name

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'LexiLearn',
          style: textTheme.titleLarge?.copyWith(
            fontFamily: 'OpenDyslexic',
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colorScheme.onBackground),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Hi $userName 👋 Ready to practice today?',
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: 'OpenDyslexic',
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Happy Learning!',
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'OpenDyslexic',
                  color: colorScheme.onBackground,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: getColumnCount(width),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.25,
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.library_books,
                      title: 'Library',
                      color: colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ContentLibraryScreen()),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.bar_chart,
                      title: 'Progress Tracker',
                      color: colorScheme.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProgressTrackerScreen()),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.mic,
                      title: 'Speech Interaction',
                      color: colorScheme.primaryContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SpeechInteractionScreen()),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.quiz,
                      title: 'Quiz',
                      color: colorScheme.secondaryContainer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => QuizScreen()),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      color: colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  '© 2025 LexiLearn',
                  style: textTheme.bodySmall?.copyWith(
                    fontFamily: 'OpenDyslexic',
                    color: colorScheme.onBackground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      splashColor: color.withOpacity(0.25),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Theme.of(context).cardColor,
        shadowColor: color.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  icon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontFamily: 'OpenDyslexic',
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
