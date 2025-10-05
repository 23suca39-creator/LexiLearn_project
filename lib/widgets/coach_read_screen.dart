import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class CoachReadScreen extends StatefulWidget {
  final String sentence;
  const CoachReadScreen({super.key, required this.sentence});
  @override
  State<CoachReadScreen> createState() => _CoachReadScreenState();
}

class _CoachReadScreenState extends State<CoachReadScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _listening = false;
  bool _available = false;
  String _recognized = '';
  int _lastCorrectIndex = -1;
  String? _correction;
  bool _success = false;
  bool _finalChecked = false;
  final Set<int> _skippedLines = {};
  final Map<String, int> _mistakeCount = {};
  String? _practiceSuggestion;

  String _cleanWord(String word) {
    return word.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase().trim();
  }

  List<String> _cleanSplit(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  bool _wordsAreSimilar(String word1, String word2) {
    word1 = _cleanWord(word1);
    word2 = _cleanWord(word2);
    if (word1 == word2) return true;
    if (word1.contains(word2) || word2.contains(word1)) return true;
    Map<String, List<String>> similarWords = {
      'shining': ['shiny', 'shinning', 'shinin', 'shine'],
      'the': ['a', 'de', 'thee'],
      'was': ['is', 'as', 'has'],
      'park': ['bark', 'pack'],
      'dog': ['dock', 'dogs'],
      'ball': ['call', 'wall', 'balls'],
      'outside': ['outsider', 'outsize', 'out'],
    };
    for (String key in similarWords.keys) {
      if ((word1 == key && similarWords[key]!.contains(word2)) ||
          (word2 == key && similarWords[key]!.contains(word1))) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    _available = await _speech.initialize(
      onStatus: (status) {
        setState(() {
          _listening = status == 'listening';
        });
        if (status == "notListening" && !_finalChecked) {
          _finalChecked = true;
          _checkFinalSentence();
        }
      },
      onError: (error) {
        setState(() {
          _listening = false;
        });
      },
    );
    setState(() {});
  }

  void _startCoach() async {
    if (!_available) return;
    setState(() {
      _recognized = '';
      _lastCorrectIndex = -1;
      _correction = null;
      _success = false;
      _finalChecked = false;
      _skippedLines.clear();
      _practiceSuggestion = null;
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognized = result.recognizedWords;
        });
        _compareWordsLive();
      },
      localeId: 'en_US',
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
    );
  }

  void _compareWordsLive() async {
    if (_recognized.trim().isEmpty) {
      setState(() {
        _lastCorrectIndex = -1;
        _correction = null;
      });
      return;
    }
    List<String> original = _cleanSplit(widget.sentence);
    List<String> spoken = _cleanSplit(_recognized);

    if (spoken.length < 2) {
      setState(() {
        _lastCorrectIndex = spoken.length - 1;
        _correction = null;
      });
      return;
    }

    int wrongAt = -1;
    for (int i = 0; i < spoken.length; i++) {
      if (i >= original.length || !_wordsAreSimilar(spoken[i], original[i])) {
        wrongAt = i;
        break;
      }
    }

    if (wrongAt != -1 && spoken.length >= 3 && !_finalChecked) {
      String wrongWord = original[wrongAt];
      setState(() {
        _lastCorrectIndex = wrongAt - 1;
        _correction = wrongWord;
        _success = false;
        // Mistake logging:
        _mistakeCount[wrongWord] = (_mistakeCount[wrongWord] ?? 0) + 1;
        if (_mistakeCount[wrongWord]! >= 3) {
          _practiceSuggestion = wrongWord;
        }
      });
      await _flutterTts.speak("Try again! The correct word is: $wrongWord");
      _speech.stop();
      _finalChecked = true;
    } else {
      setState(() {
        _lastCorrectIndex = spoken.length - 1;
        _correction = null;
      });
    }
  }

  void _checkFinalSentence() async {
    if (_recognized.trim().isEmpty) {
      setState(() {
        _skippedLines.clear();
        _success = false;
        _correction = null;
      });
      return;
    }

    List<String> original = _cleanSplit(widget.sentence);
    List<String> spoken = _cleanSplit(_recognized);

    // Multi-line check (sentences split by periods)
    List<List<String>> originalLines = widget.sentence
        .split('.')
        .map((line) => _cleanSplit(line))
        .where((line) => line.isNotEmpty)
        .toList();
    List<List<String>> spokenChunks = _recognized
        .split('.')
        .map((chunk) => _cleanSplit(chunk))
        .where((chunk) => chunk.isNotEmpty)
        .toList();

    if (spokenChunks.isEmpty || spoken.join().isEmpty) {
      setState(() {
        _skippedLines.clear();
        _success = false;
        _correction = null;
      });
      return;
    }

    // Only check for skipped lines if there are multiple lines
    bool skippedLine = false;
    _skippedLines.clear();
    if (originalLines.length > 1) {
      for (int i = 0; i < originalLines.length; i++) {
        if (spokenChunks.length <= i ||
            spokenChunks[i].isEmpty ||
            !_almostLineMatch(originalLines[i], spokenChunks[i])) {
          _skippedLines.add(i);
          skippedLine = true;
        }
      }
    }

    if (skippedLine) {
      setState(() {
        _success = false;
        _correction = null;
      });
      await _flutterTts.speak("You skipped, try again!");
      return;
    }

    // Accept "well done" if 80%+ correct, or all spoken match in order
    int len = spoken.length < original.length ? spoken.length : original.length;
    int matches = 0;
    int firstWrong = -1;
    for (int i = 0; i < len; i++) {
      if (_wordsAreSimilar(spoken[i], original[i])) {
        matches++;
      } else if (firstWrong == -1) {
        firstWrong = i;
      }
    }
    int minLength = (original.length * 0.8).ceil();

    if ((spoken.length == original.length && matches == original.length) ||
        (matches >= minLength && spoken.length == original.length)) {
      setState(() {
        _lastCorrectIndex = len - 1;
        _correction = null;
        _success = true;
        _practiceSuggestion = null;
      });
      await _flutterTts.speak("Well done! Perfect reading!");
      return;
    }
    if (firstWrong != -1) {
      String wrongWord = original[firstWrong];
      setState(() {
        _lastCorrectIndex = firstWrong - 1;
        _correction = wrongWord;
        _success = false;
        // Mistake logging:
        _mistakeCount[wrongWord] = (_mistakeCount[wrongWord] ?? 0) + 1;
        if (_mistakeCount[wrongWord]! >= 3) {
          _practiceSuggestion = wrongWord;
        }
      });
      await _flutterTts.speak("Try again! The correct word is: $wrongWord");
      return;
    }
    setState(() {
      _lastCorrectIndex = spoken.length - 1;
      _correction = spoken.length < original.length ? original[spoken.length] : null;
      _success = false;
    });
    if (_correction != null) {
      await _flutterTts.speak("Next word is: $_correction");
    }
  }

  bool _almostLineMatch(List<String> original, List<String> spoken) {
    int len = spoken.length < original.length ? spoken.length : original.length;
    int matches = 0;
    for (int i = 0; i < len; i++) {
      if (_wordsAreSimilar(spoken[i], original[i])) {
        matches++;
      }
    }
    int minLength = (original.length * 0.8).ceil();
    return matches >= minLength;
  }

  void _stopCoach() {
    _speech.stop();
    setState(() {
      _listening = false;
      _finalChecked = true;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> words = widget.sentence.split(" ");
    return Scaffold(
      appBar: AppBar(title: Text("AI Coach Reading")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              children: List.generate(words.length, (i) {
                Color color;
                if (_lastCorrectIndex >= i) {
                  color = Colors.green;
                } else if (_correction != null && _cleanWord(words[i]) == (_correction ?? '')) {
                  color = Colors.red;
                } else {
                  color = Colors.grey[800]!;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(words[i],
                    style: TextStyle(
                      fontSize: 22,
                      color: color,
                      fontWeight: (color == Colors.green)
                        ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 30),
            
            // Success with stars
            if (_success)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    SizedBox(width: 10),
                    Text("Well done! ⭐", style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            
            SizedBox(height: 20),
            
            // Feedback messages
            if (_skippedLines.isNotEmpty)
              Text("You skipped, try again!", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
            if (_correction != null)
              Text("Try again! Correct word: $_correction", style: TextStyle(color: Colors.orange, fontSize: 18)),
            if (_practiceSuggestion != null)
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border.all(color: Colors.purple.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Practice this word: ${_practiceSuggestion!}",
                  style: TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            
            SizedBox(height: 16),
            Text('Recognized: "$_recognized"', style: TextStyle(fontSize: 16, color: Colors.blue)),
            SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(_listening ? Icons.stop : Icons.mic),
                  onPressed: _listening ? _stopCoach : _startCoach,
                  label: Text(_listening ? "Stop" : "Start AI Coach"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _listening ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                if (!_listening)
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    onPressed: _startCoach,
                    label: Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
