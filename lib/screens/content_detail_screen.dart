import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../models/content_item.dart';
import '../providers/progress_provider.dart';

class ContentDetailScreen extends StatefulWidget {
  final ContentItem item;

  const ContentDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  late ScrollController _scrollController;
  late FlutterTts _flutterTts;
  bool _isReadingAloud = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _flutterTts = FlutterTts();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      double progress = maxScroll == 0 ? 1 : currentScroll / maxScroll;
      if (progress > 1) progress = 1;
      if (progress < 0) progress = 0;

      Provider.of<ProgressProvider>(context, listen: false)
          .addProgress(ProgressEntry(
            contentId: widget.item.id,
            progress: progress,
            accuracy: 100.0, // Supply real value if available
            score: 0.0, // Supply real value if you track quiz scores
            date: DateTime.now(),
));

    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isReadingAloud = false;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isReadingAloud = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleReadAloud() async {
    if (_isReadingAloud) {
      await _flutterTts.stop();
      setState(() {
        _isReadingAloud = false;
      });
    } else {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(widget.item.fullText);
      setState(() {
        _isReadingAloud = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title, style: const TextStyle(fontFamily: 'OpenDyslexic')),
        actions: [
          IconButton(
            tooltip: _isReadingAloud ? 'Stop Read Aloud' : 'Read Aloud',
            icon: Icon(_isReadingAloud ? Icons.stop : Icons.volume_up),
            onPressed: _toggleReadAloud,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Text(
              widget.item.fullText,
              style: const TextStyle(
                fontFamily: 'OpenDyslexic',
                fontSize: 18,
                height: 1.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
