import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
// Import your ContentItem model and detail screen
import '../models/content_item.dart';
import '../providers/progress_provider.dart';
import '../screens/content_detail_screen.dart';

// Sample content - replace with actual content source
final List<ContentItem> allContent = [
  // BEGINNER CONTENT
  ContentItem(
    id: 'b1',
    title: 'Reading Passage 1',
    category: 'Beginner',
    preview: 'A simple passage for beginner readers about outdoor play.',
    fullText: 'The sun was shining. Ravi walked to the park with his dog. The dog ran after a ball. Ravi laughed. He liked to play outside.',
    url: '',
  ),
  ContentItem(
    id: 'b2',
    title: 'Animals in the Zoo',
    category: 'Beginner',
    preview: 'Read about the animals Ravi sees at the zoo.',
    fullText: 'Ravi went to the zoo. He saw lions, monkeys, and birds. The lions slept, the monkeys jumped, and birds sang songs.',
    url: '',
  ),
  ContentItem(
    id: 'b3',
    title: 'Comprehension Exercise 1',
    category: 'Beginner',
    preview: 'A quick quiz about yesterday\'s reading.',
    fullText: 'Who went to the park? What did the dog chase?',
    url: '',
  ),
  ContentItem(
    id: 'b4',
    title: 'Story: The Red Ball',
    category: 'Beginner',
    preview: 'A short story about a lost and found ball.',
    fullText: 'Maya lost her red ball. She looked under the bed. She found it in her school bag. She was happy and played outside.',
    url: '',
  ),
  // Add more beginner content as needed
  // INTERMEDIATE CONTENT
  ContentItem(
    id: 'i1',
    title: 'Animals of India',
    category: 'Intermediate',
    preview: 'Discover important facts about Indian wildlife.',
    fullText: 'India is home to elephants, tigers, deer, and many birds. Many of these animals live in forests and national parks. Conserving their habitats is important for the balance of nature.',
    url: '',
  ),
  ContentItem(
    id: 'i2',
    title: 'Comprehension Quiz: Water Cycle',
    category: 'Intermediate',
    preview: 'Quiz: Explain what happens when water evaporates.',
    fullText: 'Evaporation is when the sun heats up water to make it vapor. True or False: Clouds are made from water vapor.',
    url: '',
  ),
  // Add more intermediate content as needed
  // ADVANCED CONTENT
  ContentItem(
    id: 'a1',
    title: 'Excerpt: Pride and Prejudice',
    category: 'Advanced',
    preview: 'A classic passage for advanced readers.',
    fullText: 'It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife...',
    url: '',
  ),
  ContentItem(
    id: 'a2',
    title: 'Article: The Water Cycle Explained',
    category: 'Advanced',
    preview: 'In-depth reading about the environment and precipitation.',
    fullText: 'The water cycle, also known as the hydrologic cycle, explains how water moves from the surface to the atmosphere and back...',
    url: '',
  ),
  // Add more advanced content as needed
];

class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({Key? key}) : super(key: key);

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  // Controls the number of items shown per level
  final Map<String, int> _shownCount = {
    'Beginner': 3,
    'Intermediate': 3,
    'Advanced': 3,
  };
  static const int _increment = 3;

  late ThemeData theme;
  final String fontFamily = 'OpenDyslexic';

  // Text-to-Speech instance
  final FlutterTts flutterTts = FlutterTts();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
  }

  @override
  void dispose() {
    flutterTts.stop(); // Stop TTS when screen is disposed
    super.dispose();
  }

  List<ContentItem> _itemsForLevel(String level) {
    return allContent.where((item) => item.category == level).toList();
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Content Library',
          style: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelSection('Beginner', progressProvider),
              const SizedBox(height: 20),
              _buildLevelSection('Intermediate', progressProvider),
              const SizedBox(height: 20),
              _buildLevelSection('Advanced', progressProvider),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Builds each level section with cards and a show more button
  Widget _buildLevelSection(String level, ProgressProvider progressProvider) {
    final items = _itemsForLevel(level);
    final shownItems = items.take(_shownCount[level]!).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$level Level',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _buildCardRow(shownItems, progressProvider,
              key: ValueKey(_shownCount[level]!)),
        ),
        if (shownItems.length < items.length)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontFamily: fontFamily,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                label: const Text('Show More'),
                onPressed: () {
                  setState(() {
                    _shownCount[level] =
                        (_shownCount[level]! + _increment).clamp(0, items.length);
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  // Horizontal scrollable cards per level
  Widget _buildCardRow(
      List<ContentItem> items, ProgressProvider progressProvider,
      {Key? key}) {
    return SizedBox(
      key: key,
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, idx) =>
            _buildContentCard(items[idx], progressProvider),
      ),
    );
  }

  // Individual content card with TTS button
  Widget _buildContentCard(ContentItem item, ProgressProvider progressProvider) {
    final progress = progressProvider.getProgress(item.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ContentDetailScreen(item: item),
          ),
        );
      },
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        tween: Tween(begin: 1.0, end: 1.0),
        builder: (_, scale, child) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(scale),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 7,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
        child: Ink(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      item.preview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    color: theme.colorScheme.secondary,
                    backgroundColor: theme.dividerColor,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% completed',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up),
                      color: theme.colorScheme.primary,
                      tooltip: 'Read Aloud',
                      onPressed: () async {
                        await flutterTts.stop();
                        await flutterTts.setLanguage("en-US");
                        await flutterTts.setPitch(1.0);
                        await flutterTts.speak(item.fullText);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
