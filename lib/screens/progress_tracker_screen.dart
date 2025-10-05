import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lexilearn/themes/themes.dart';

import '../providers/progress_provider.dart';

class ProgressTrackerScreen extends StatelessWidget {
  const ProgressTrackerScreen({super.key});

  // Simple AI-Coach-like dynamic next-level recommend: no ML, just rules.
  String _getNextLevelSuggestion(ProgressProvider provider) {
    // Baby-like if-else rules:
    double beginnerAvg = provider.getLevelAverage('Beginner');
    double intermediateAvg = provider.getLevelAverage('Intermediate');
    double advancedAvg = provider.getLevelAverage('Advanced');

    if (beginnerAvg >= 70 && intermediateAvg < 70) {
      return "Great job! Let's try Intermediate stories now.";
    } else if (intermediateAvg >= 70 && advancedAvg < 70) {
      return "Wow! You are ready for Advanced stories. Give them a try!";
    } else if (advancedAvg >= 70) {
      return "You finished every level—You are a MASTER reader!";
    } else {
      return "Keep going with Beginner stories for best results!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        final progressList = provider.progressList;

        if (progressList.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Progress Tracker')),
            body: const Center(child: Text('No progress data available')),
          );
        }

        // New: show baby-steps AI coach suggestion at top
        final String nextLevel = _getNextLevelSuggestion(provider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Progress Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  provider.resetProgress();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // AI coach-like dynamic suggestion (visible always)
              Padding(
                padding: const EdgeInsets.only(top: 18.0, left: 12, right: 12, bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    nextLevel,
                    style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600, color: Colors.blueGrey[900]
                    ),
                  ),
                ),
              ),
              // Score summary (average, best, total)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('Average', '${provider.averageAccuracy.toStringAsFixed(1)}%'),
                    _summaryItem('Best', '${provider.bestScore.toStringAsFixed(1)}%'),
                    _summaryItem('Total', '${provider.quizCount}'),
                  ],
                ),
              ),
              // Line chart of progress
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      borderData: FlBorderData(show: true),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, _) {
                              int index = value.toInt();
                              if (index < 0 || index >= progressList.length) {
                                return const SizedBox.shrink();
                              }
                              final date = progressList[index].date;
                              return Text('${date.month}/${date.day}');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 20),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          spots: progressList
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.accuracy))
                              .toList(),
                          barWidth: 3,
                          color: Colors.blue,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                          dotData: FlDotData(show: true),
                        )
                      ],
                      lineTouchData: LineTouchData(enabled: true),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}
