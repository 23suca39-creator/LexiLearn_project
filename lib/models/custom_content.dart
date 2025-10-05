import 'package:hive/hive.dart';

part 'custom_content.g.dart';

@HiveType(typeId: 1)
class CustomContent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String fullText;

  CustomContent({
    required this.id,
    required this.title,
    required this.description,
    required this.fullText,
  });

  factory CustomContent.fromJson(Map<String, dynamic> json) {
    return CustomContent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fullText: json['fullText'] ?? '',
    );
  }
}
