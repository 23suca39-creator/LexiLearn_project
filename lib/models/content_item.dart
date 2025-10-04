import 'package:hive/hive.dart';

part 'content_item.g.dart';

@HiveType(typeId: 0)
class ContentItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String preview;

  @HiveField(4)
  final String fullText;

  @HiveField(5)
  final String url;

  ContentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.preview,
    required this.fullText,
    required this.url,
  });
}
