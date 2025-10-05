import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/content_item.dart';
import '../providers/progress_provider.dart';

class ContentReaderScreen extends StatefulWidget {
  final ContentItem contentItem;

  const ContentReaderScreen({super.key, required this.contentItem});

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

      context.read<ProgressProvider>().addProgress(
        ProgressEntry(
          contentId: widget.contentItem.id,
          progress: newProgress,
          accuracy: 100.0,
          score: 0.0,
          date: DateTime.now(),
          url: widget.contentItem.url,
        ),
      );
    }
  }

  Future<void> _speak() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    await flutterTts.setLanguage('en-US');

    if (settings.selectedVoiceName != null && settings.selectedVoiceLocale != null) {
      await flutterTts.setVoice({
        "name": settings.selectedVoiceName,
        "locale": settings.selectedVoiceLocale,
      });
    }

    await flutterTts.setPitch(settings.voicePitch);
    await flutterTts.setSpeechRate(settings.speechRate);

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
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          IconButton(onPressed: _speak, icon: const Icon(Icons.volume_up)),
          IconButton(onPressed: _stop, icon: const Icon(Icons.stop)),
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
