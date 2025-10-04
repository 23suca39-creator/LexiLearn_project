import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../widgets/command_suggestions.dart';
import 'package:lexilearn/themes/themes.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({Key? key}) : super(key: key);

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final String dyslexiaFontFamily = 'OpenDyslexic, Arial Rounded, sans-serif';

  late html.SpeechRecognition recognition;
  bool isListening = false;
  String transcription = '';

  @override
  void initState() {
    super.initState();

    recognition = html.SpeechRecognition();
    recognition.lang = 'en-US';
    recognition.continuous = true;
    recognition.interimResults = true;

    recognition.onResult.listen((html.SpeechRecognitionEvent event) {
      final results = event.results;
      final index = event.resultIndex ?? 0;

      if (results != null && index < results.length) {
        final result = results[index];
        final alt = result.item(0);
        final transcript = alt?.transcript ?? "";
        final isFinal = result.isFinal;

        print('Recognized: $transcript, isFinal=$isFinal');

        setState(() {
          transcription = transcript;
        });

        if (isFinal == true) {
          _processCommand(transcript.toLowerCase().trim());
        }
      }
    });

    recognition.onEnd.listen((event) {
      print('Recognition ended');
      setState(() {
        isListening = false;
      });
    });

    recognition.onError.listen((html.SpeechRecognitionError event) {
      print('Recognition error: ${event.error}');
      setState(() {
        isListening = false;
      });
    });
  }

  void _processCommand(String command) {
    print('Processing command: $command');

    if (command.contains('open library')) {
      _speak('Opening Library');
      // TODO: Navigate to Library
    } else if (command.contains('start quiz')) {
      _speak('Starting Quiz');
      // TODO: Navigate to Quiz
    } else if (command.contains('check progress')) {
      _speak('Checking Progress');
      // TODO: Navigate to Progress Tracker
    } else if (command.contains('change theme to dark')) {
      _speak('Switching to dark mode');
      // TODO: Change app theme
    } else {
      _speak('Sorry, I did not understand. Please try again.');
    }
  }

  void _speak(String message) {
    final synth = html.window.speechSynthesis;
    final utterance = html.SpeechSynthesisUtterance(message);
    utterance.lang = 'en-US';
    utterance.rate = 0.8;
    synth?.speak(utterance);
  }

  void _toggleListening() {
    try {
      if (isListening) {
        recognition.stop();
        print('Stopped listening');
      } else {
        recognition.start();
        print('Started listening');
      }

      setState(() {
        isListening = !isListening;
        if (!isListening) transcription = '';
      });
    } catch (e) {
      print('Error toggling listening: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant - LexiLearn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Hi Honey! Ready to learn with your voice?",
                style: TextStyle(
                  fontFamily: dyslexiaFontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isListening ? Colors.blueAccent : Colors.grey.shade400,
                    shape: BoxShape.circle,
                    boxShadow: isListening
                        ? [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 5,
                            )
                          ]
                        : [],
                  ),
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (transcription.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transcription,
                    style: TextStyle(
                      fontFamily: dyslexiaFontFamily,
                      fontSize: 20,
                      letterSpacing: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Text(
                  "Say 'Open Library' or 'Start Quiz'",
                  style: TextStyle(
                    fontFamily: dyslexiaFontFamily,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              const SizedBox(height: 40),
              CommandSuggestions(commands: [
                'Open Library',
                'Start Quiz',
                'Check Progress',
                'Change theme to dark',
                'Increase font size',
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
