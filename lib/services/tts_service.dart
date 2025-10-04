import 'dart:html' as html;

class TextToSpeechService {
  final html.SpeechSynthesis? _synth = html.window.speechSynthesis;

  void speak(String text, {String lang = 'en-US', double rate = 0.8}) {
    _synth?.cancel();
    final utterance = html.SpeechSynthesisUtterance(text)
      ..lang = lang
      ..rate = rate;
    _synth?.speak(utterance);
  }

  void stop() {
    _synth?.cancel();
  }
}
