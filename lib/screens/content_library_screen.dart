import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_selector/file_selector.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
// NO dart:html import!
import 'package:http/http.dart' as http;
import '../widgets/coach_read_screen.dart';
import '../widgets/ar_reading_screen.dart';
import '../models/content_item.dart';
import '../providers/progress_provider.dart';
import '../screens/content_detail_screen.dart';

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
  // ...other items...
];

class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  final Map<String, int> _shownCount = {'Beginner': 3, 'Intermediate': 3, 'Advanced': 3};
  static const int _increment = 3;
  late ThemeData theme;
  final String fontFamily = 'OpenDyslexic';
  final FlutterTts flutterTts = FlutterTts();
  List<String> _localFiles = [];
  List<String> _bookmarkedIds = [];
  int _userMood = 5;
  final Map<String, XFile> _fileMap = {};

  @override
  void initState() {
    super.initState();
    _loadAdvancedFeatures();
  }

  Future<void> _loadAdvancedFeatures() async {
    await _loadLocalFiles();
    await _loadBookmarks();
    await _loadUserMood();
  }

  Future<void> _loadLocalFiles() async {
    var box = await Hive.openBox('localFiles');
    setState(() {
      _localFiles = List<String>.from(box.values);
    });
  }

  Future<void> _pickAndSaveFile() async {
    final XFile? file = await openFile();
    if (file == null) return;
    if (kIsWeb) {
      setState(() {
        _localFiles.add(file.name);
        _fileMap[file.name] = file;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File "${file.name}" added successfully!')),
      );
    }
  }

  Future<void> _loadBookmarks() async {
    var box = await Hive.openBox('bookmarks');
    setState(() {
      _bookmarkedIds = List<String>.from(box.values);
    });
  }

  Future<void> _toggleBookmark(String contentId) async {
    var box = await Hive.openBox('bookmarks');
    if (_bookmarkedIds.contains(contentId)) {
      await box.delete(contentId);
      _bookmarkedIds.remove(contentId);
    } else {
      await box.put(contentId, contentId);
      _bookmarkedIds.add(contentId);
    }
    setState(() {});
  }

  Future<void> _loadUserMood() async {
    var box = await Hive.openBox('userSettings');
    setState(() {
      _userMood = box.get('mood', defaultValue: 5);
    });
  }

  Future<void> _saveMood(int mood) async {
    var box = await Hive.openBox('userSettings');
    await box.put('mood', mood);
    setState(() {
      _userMood = mood;
    });
  }

  Widget _buildLevelSection(String level, ProgressProvider progressProvider) {
    final items = allContent.where((item) => item.category == level).toList();
    final shownItems = items.take(_shownCount[level]!).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$level Level', style: TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _buildCardRow(shownItems, progressProvider, key: ValueKey(_shownCount[level]!)),
        ),
        if (shownItems.length < items.length)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                  textStyle: TextStyle(fontSize: 15, fontFamily: fontFamily),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                label: const Text('Show More'),
                onPressed: () {
                  setState(() {
                    _shownCount[level] = (_shownCount[level]! + _increment).clamp(0, items.length);
                  });
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCardRow(List<ContentItem> items, ProgressProvider progressProvider, {Key? key}) {
    return SizedBox(
      key: key,
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, idx) => _buildContentCard(items[idx], progressProvider),
      ),
    );
  }

  Widget _buildContentCard(ContentItem item, ProgressProvider progressProvider) {
    final progress = progressProvider.getProgress(item.id);
    final isBookmarked = _bookmarkedIds.contains(item.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ContentDetailScreen(item: item),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.title,
                        style: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.red : theme.colorScheme.primary,
                      ),
                      onPressed: () => _toggleBookmark(item.id),
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(item.preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: fontFamily, fontSize: 15, color: theme.colorScheme.onSurface),
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
                Text('${(progress * 100).toStringAsFixed(0)}% completed',
                  style: TextStyle(fontFamily: fontFamily, fontSize: 12, color: theme.colorScheme.primary),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
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
                      IconButton(
                        icon: const Icon(Icons.psychology),
                        color: theme.colorScheme.primary,
                        tooltip: 'AI Coach Reading',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoachReadScreen(sentence: item.fullText),
                            ),
                          );
                        },
                      ),
                      // AR Overlay Button
                      IconButton(
                        icon: const Icon(Icons.view_in_ar),
                        color: theme.colorScheme.primary,
                        tooltip: 'AR Reading Guide',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ARReadingScreen(text: item.fullText),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
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
        actions: [
          // Mood Indicator (optional, you can comment/remove if not needed)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {},
              child: Text('😊', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
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
}
