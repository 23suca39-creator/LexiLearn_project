import 'package:hive/hive.dart';

part 'progress_model.g.dart';

@HiveType(typeId: 0)
class ProgressModel {
  @HiveField(0)
  final double accuracy;

  @HiveField(1)
  final DateTime date;

  ProgressModel({required this.accuracy, required this.date});
}
