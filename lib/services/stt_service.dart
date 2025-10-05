import 'dart:html' as html;

class SpeechToTextService {
  html.SpeechRecognition? _recognition;
  bool _isListening = false;
  Function(String)? _onResult;

  Future<bool> startListening({required Function(String) onResult}) async {
    if (_isListening) {
      await stopListening();
    }
    _recognition = html.SpeechRecognition();
    _recognition?.lang = 'en-US';
    _recognition?.continuous = true;
    _recognition?.interimResults = true;
    _onResult = onResult;

    _recognition?.onResult.listen((event) {
      final results = event.results;
      final index = event.resultIndex ?? 0;
      if (results != null && results.length > index) {
        final transcriptResult = results[index];
        final transcriptAlternative = transcriptResult.item(0);
        final transcript = transcriptAlternative.transcript ?? '';
        _onResult?.call(transcript);
      }
    });

    _recognition?.onEnd.listen((_) {
      _isListening = false;
    });

    try {
      _recognition?.start();
      _isListening = true;
      return true;
    } catch (e) {
      print("Error starting recognition: $e");
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      _recognition?.stop();
    } catch (e) {
      print("Error stopping recognition: $e");
    }
    _isListening = false;
  }

  bool get isListening => _isListening;
}
