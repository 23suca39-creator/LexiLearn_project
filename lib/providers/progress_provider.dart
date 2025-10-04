import 'package:flutter/material.dart';

class ProgressEntry {
  final String contentId;
  final double progress;
  final double accuracy;
  final double score;
  final DateTime date;

  ProgressEntry({
    required this.contentId,
    required this.progress,
    required this.accuracy,
    required this.score,
    required this.date,
  });
}

class ProgressProvider extends ChangeNotifier {
  final List<ProgressEntry> _history = [];
  final Map<String, double> _progressMap = {};

  List<ProgressEntry> get progressList => List.unmodifiable(_history);

  double get averageAccuracy {
    if (_history.isEmpty) return 0;
    return _history.map((e) => e.accuracy).reduce((a, b) => a + b) / _history.length;
  }

  double get bestScore {
    if (_history.isEmpty) return 0;
    return _history.map((e) => e.score).reduce((a, b) => a > b ? a : b);
  }

  int get quizCount => _history.length;

  double getProgress(String contentId) => _progressMap[contentId] ?? 0;

  void addProgress(ProgressEntry entry) {
    _history.add(entry);
    _progressMap[entry.contentId] = entry.progress;
    notifyListeners();
  }

  void resetProgress() {
    _history.clear();
    _progressMap.clear();
    notifyListeners();
  }
}
