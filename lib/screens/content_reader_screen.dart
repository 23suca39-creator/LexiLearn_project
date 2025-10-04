import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../models/content_item.dart';
import '../providers/progress_provider.dart';

class ContentReaderScreen extends StatefulWidget {
  final ContentItem contentItem;

  ContentReaderScreen({Key? key, required this.contentItem}) : super(key: key);

  @override
  State<ContentReaderScreen> createState() => _ContentReaderScreenState();
}

class _ContentReaderScreenState extends State<ContentReaderScreen> {
  final FlutterTts flutterTts = FlutterTts();
  late ScrollController _scrollController;
  double _progress = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedProgress =
          context.read<ProgressProvider>().getProgress(widget.contentItem.id);
      setState(() {
        _progress = savedProgress;
      });
      if (_scrollController.hasClients) {
        final pos = _scrollController.position.maxScrollExtent * savedProgress;
        _scrollController.jumpTo(pos);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final currentScroll = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    double newProgress = maxScroll == 0 ? 1 : (currentScroll / maxScroll);
    newProgress = newProgress.clamp(0, 1);

    if ((newProgress - _progress).abs() > 0.01) {
      setState(() {
        _progress = newProgress;
      });

      // Record progress with required named parameters
      context.read<ProgressProvider>().addProgress(
        ProgressEntry(
            contentId: widget.contentItem.id,
            progress: newProgress,
            accuracy: 100.0, // Replace with actual accuracy calculation if available
            score: 0.0,      // Replace with actual score if any, else set to 0
            date: DateTime.now(),
            url: widget.contentItem.url, // Pass the url here
        ),
    );

    }
  }

  Future<void> _speak() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(widget.contentItem.fullText);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contentItem.title,
          style: TextStyle(
            fontFamily: 'OpenDyslexic',
            color: theme.colorScheme.primary,
          ),
        ),
        backgroundColor: theme.colorScheme.background,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          IconButton(onPressed: _speak, icon: Icon(Icons.volume_up)),
          IconButton(onPressed: _stop, icon: Icon(Icons.stop)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Text(
              widget.contentItem.fullText,
              style: TextStyle(
                fontFamily: 'OpenDyslexic',
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
