import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/content_item.dart';
import '../providers/progress_provider.dart';

class ContentDetailScreen extends StatefulWidget {
  final ContentItem item;

  const ContentDetailScreen({super.key, required this.item});

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

      // Save progress when user reaches end (100%)
      if (progress >= 0.9) {
        _markContentAsRead(100.0);
      }
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

  void _markContentAsRead(double progressPercent) {
    final provider = Provider.of<ProgressProvider>(context, listen: false);
    
    final progressItem = ProgressItem(
      id: widget.item.id,
      level: widget.item.category,  // "Beginner", "Intermediate", "Advanced"
      accuracy: progressPercent,    // e.g., 100.0 for complete
      date: DateTime.now(),
    );
    
    provider.addProgress(progressItem);
  }

  Future<void> _toggleReadAloud() async {
  final settings = Provider.of<SettingsProvider>(context, listen: false);

  if (_isReadingAloud) {
    await _flutterTts.stop();
    setState(() {
      _isReadingAloud = false;
    });
  } else {
    await _flutterTts.setLanguage("en-US");

    if (settings.selectedVoiceName != null && settings.selectedVoiceLocale != null) {
      await _flutterTts.setVoice({
        "name": settings.selectedVoiceName ?? "defaultVoiceName",
        "locale": settings.selectedVoiceLocale ?? "en-US",
      });
    }

    await _flutterTts.setSpeechRate(settings.speechRate);
    await _flutterTts.setVolume(1.0);  // you can also make volume customizable
    await _flutterTts.setPitch(settings.voicePitch);

    setState(() {
      _isReadingAloud = true;
    });

    await _flutterTts.speak(widget.item.fullText);

    // Optionally listen to completion event and reset _isReadingAloud after speech ends
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isReadingAloud = false;
      });
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
