import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_selector/file_selector.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import '../widgets/coach_read_screen.dart';

// ADD THIS IMPORT FOR AR READING:
import '../widgets/ar_reading_screen.dart';

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
];

class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen> {
  final Map<String, int> _shownCount = {
    'Beginner': 3,
    'Intermediate': 3,
    'Advanced': 3,
  };
  static const int _increment = 3;
  late ThemeData theme;
  final String fontFamily = 'OpenDyslexic';
  final FlutterTts flutterTts = FlutterTts();
  
  List<String> _localFiles = [];
  List<String> _bookmarkedIds = [];
  int _userMood = 5;
  Map<String, List<String>> _userNotes = {};
  final Map<String, XFile> _fileMap = {};
  
  @override
  void initState() {
    super.initState();
    _loadAdvancedFeatures();
  }

  // ADVANCED FEATURES METHODS
  Future<void> _loadAdvancedFeatures() async {
    await _loadLocalFiles();
    await _loadBookmarks();
    await _loadUserMood();
    await _loadUserNotes();
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
    } else {
      // Normal desktop logic...
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

  Future<void> _loadUserNotes() async {
    var box = await Hive.openBox('userNotes');
    setState(() {
      _userNotes = Map<String, List<String>>.from(
        box.toMap().map((key, value) => MapEntry(key.toString(), List<String>.from(value))),
      );
    });
  }

  void _openFile(String nameOrPath) async {
    if (kIsWeb) {
      XFile? file = _fileMap[nameOrPath];
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File not found')));
        return;
      }
      String ext = file.name.split('.').last.toLowerCase();
      Uint8List bytes = await file.readAsBytes();

      if (['txt', 'json', 'csv', 'dart'].contains(ext)) {
        String text = await file.readAsString();
        _showCustomFontPreview(text, file.name);
      } else if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
        _showWebImagePreview(bytes, file.name);
      } else if (['pdf', 'docx'].contains(ext)) {
        try {
          var uri = Uri.parse('http://127.0.0.1:5000/extract');
          var request = http.MultipartRequest('POST', uri);
          request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name));
          var streamedResponse = await request.send();

          print('API Response Status: ${streamedResponse.statusCode}');

          if (streamedResponse.statusCode == 200) {
            String extractedText = await streamedResponse.stream.bytesToString();
            print('Extracted text length: ${extractedText.length}');
            _showCustomFontPreview(extractedText, file.name);
          } else {
            print('API Error: ${streamedResponse.statusCode}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('API error: ${streamedResponse.statusCode}')),
            );
          }
        } catch (e) {
          print('Exception: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Network error: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File type not supported: .$ext')),
        );
      }
    } else {
      // desktop/macos code...
    }
  }

  void _showWebTextPreview(String text, String fileName) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(fileName)),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(text, style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    ));
  }

  void _showWebImagePreview(Uint8List bytes, String fileName) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(fileName)),
        body: Center(
          child: InteractiveViewer(child: Image.memory(bytes)),
        ),
      ),
    ));
  }

  void _showCustomFontPreview(String extractedText, String fileName) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(fileName)),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              extractedText,
              style: TextStyle(fontFamily: 'OpenDyslexic', fontSize: 18),
            ),
          ),
        ),
      ),
    ));
  }

  void _showWebDocument(Uint8List bytes, String fileName, String ext) {
    String mimeType;
    if (ext == 'pdf') {
      mimeType = 'application/pdf';
    } else if (ext == 'doc' || ext == 'docx') mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    else mimeType = 'application/octet-stream';
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
  }

  // Smart Content Suggestions (No ML - based on progress)
  List<ContentItem> _getSuggestedContent(ProgressProvider progressProvider) {
    return []; // No suggestions at all
  }

  // Mood-based theme colors
  Color _getMoodColor() {
    if (_userMood >= 8) return Colors.green.shade300;
    if (_userMood >= 6) return Colors.blue.shade300;
    if (_userMood >= 4) return Colors.orange.shade300;
    return Colors.red.shade300;
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

  List<ContentItem> _itemsForLevel(String level) {
    return allContent.where((item) => item.category == level).toList();
  }

  void _showMoodSelector() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('How are you feeling?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: _userMood.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _userMood.toString(),
              onChanged: (value) {
                setState(() {
                  _userMood = value.toInt();
                });
              },
            ),
            Text('$_userMood/10'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveMood(_userMood);
              Navigator.pop(ctx);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBookmarks() {
    final bookmarkedContent = allContent.where((item) => _bookmarkedIds.contains(item.id)).toList();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Your Bookmarks'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: bookmarkedContent.isEmpty
              ? Center(child: Text('No bookmarks yet'))
              : ListView.builder(
                  itemCount: bookmarkedContent.length,
                  itemBuilder: (ctx, i) => ListTile(
                    title: Text(bookmarkedContent[i].title),
                    subtitle: Text(bookmarkedContent[i].category),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContentDetailScreen(item: bookmarkedContent[i]),
                        ),
                      );
                    },
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: theme.colorScheme.primary,
                          ),
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
                        // NEW AR BUTTON HERE:
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
      ),
    );
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
          // Mood Indicator
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getMoodColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: _showMoodSelector,
              child: Text(
                _userMood >= 8 ? '😊' : _userMood >= 6 ? '🙂' : _userMood >= 4 ? '😐' : '😢',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          // Local File Picker
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _pickAndSaveFile,
            tooltip: 'Add Local File',
          ),
          // Show bookmarks
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: _showBookmarks,
            tooltip: 'View Bookmarks',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Suggested Content Section (Smart recommendations)
              if (_getSuggestedContent(progressProvider).isNotEmpty) ...[
                Text(
                  'Suggested for You',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _getMoodColor(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 192,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getSuggestedContent(progressProvider).take(5).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, idx) {
                      final suggestedItems = _getSuggestedContent(progressProvider).take(5).toList();
                      return _buildContentCard(suggestedItems[idx], progressProvider);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            
              // Your Local Files (if any)
              if (_localFiles.isNotEmpty) ...[
                Text(
                  'Your Local Files',
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _localFiles.length,
                    itemBuilder: (ctx, i) => Card(
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Choose Preview Mode'),
                              content: Text('Select how you want to view your document.'),
                              actions: [
                                TextButton(
                                  child: Text('Dyslexic Reading'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _openFile(_localFiles[i]);
                                  },
                                ),
                                TextButton(
                                  child: Text('Original Format'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    XFile? file = _fileMap[_localFiles[i]];
                                    if (file != null) {
                                      String ext = file.name.split('.').last.toLowerCase();
                                      file.readAsBytes().then((bytes) {
                                        _showWebDocument(bytes, file.name, ext);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: 150,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Icon(Icons.insert_drive_file, size: 30),
                              Expanded(
                                child: Text(
                                  _localFiles[i].split('/').last,
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ORIGINAL CONTENT SECTIONS (unchanged)
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
