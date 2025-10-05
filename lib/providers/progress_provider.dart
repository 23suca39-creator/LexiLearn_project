import 'package:flutter/material.dart';

class ProgressItem {
  final String id;          // Unique story/quiz/content id
  final String level;       // "Beginner", "Intermediate", "Advanced", etc.
  final double accuracy;    // 0.0 - 100.0
  final DateTime date;

  ProgressItem({
    required this.id,
    required this.level,
    required this.accuracy,
    required this.date,
  });
}

class ProgressProvider extends ChangeNotifier {
  final List<ProgressItem> _progressList = [];

  List<ProgressItem> get progressList => _progressList;

  void addProgress(ProgressItem item) {
    _progressList.add(item);
    notifyListeners();
  }

  double get averageAccuracy {
    if (_progressList.isEmpty) return 0.0;
    return _progressList.map((x) => x.accuracy).reduce((a, b) => a + b) / _progressList.length;
  }

  double get bestScore {
    if (_progressList.isEmpty) return 0.0;
    return _progressList.map((x) => x.accuracy).reduce((a, b) => a > b ? a : b);
  }

  int get quizCount => _progressList.length;

  double getLevelAverage(String level) {
    final levelItems = _progressList.where((x) => x.level == level).toList();
    if (levelItems.isEmpty) return 0.0;
    return levelItems.map((x) => x.accuracy).reduce((a, b) => a + b) / levelItems.length;
  }

  double getProgress(String id) {
    final items = _progressList.where((x) => x.id == id);
    if (items.isEmpty) return 0.0;
    return items.last.accuracy / 100;
  }

  void resetProgress() {
    _progressList.clear();
    notifyListeners();
  }
}
