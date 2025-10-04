import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lexilearn/themes/themes.dart';

class SpeechInteractionScreen extends StatefulWidget {
  const SpeechInteractionScreen({Key? key}) : super(key: key);

  @override
  State<SpeechInteractionScreen> createState() => _SpeechInteractionScreenState();
}

class _SpeechInteractionScreenState extends State<SpeechInteractionScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Tap the mic and speak...';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('Speech status: $val');
        // Auto restart listening when it ends for continuous experience
        if (val == 'done' || val == 'notListening') {
          if (_isListening) {
            _startListening();
          }
        }
      },
      onError: (val) {
        print('Speech error: ${val.errorMsg}');
        setState(() {
          _isListening = false;
        });
      },
    );
    if (!available) {
      setState(() {
        _text = 'Speech recognition not available';
      });
    }
  }

  void _startListening() async {
    await _speech.listen(
      onResult: (result) {
        setState(() {
          var recognized = result.recognizedWords;
          // Basic punctuation heuristic: add period if missing on final result
          if (result.finalResult) {
            if (!recognized.endsWith('.') &&
                !recognized.endsWith('!') &&
                !recognized.endsWith('?')) {
              recognized = '$recognized.';
            }
          }
          _text = recognized;
          _confidence = result.confidence;
        });
        if (result.finalResult) {
          _processCommand(_text.toLowerCase());
        }
      },
      listenFor: const Duration(minutes: 30), // try long duration and auto restart
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation, // better for continuous dictation
    );
    setState(() {
      _isListening = true;
      _text = '';
    });
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _processCommand(String command) {
    print('Processing command: $command');
    // Implement response to recognized commands here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Interaction'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _text,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FloatingActionButton(
                onPressed: _toggleListening,
                child: Icon(_isListening ? Icons.mic : Icons.mic_off),
              ),
              const SizedBox(height: 20),
              Text(
                _isListening
                    ? 'Listening... Confidence: ${(_confidence * 100).toStringAsFixed(1)}%'
                    : 'Tap the mic to start speaking',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
