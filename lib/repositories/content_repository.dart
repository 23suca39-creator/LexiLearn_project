import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/content_item.dart';



class ContentRepository {
  static const String contentBoxName = 'contentBox';

  final String storyweaverUrl = 'https://storyweaver.org.in/api/v1/books';
  final String gutendexUrl = 'https://gutendex.com/books?languages=en';
  final String exampleNewApiUrl = 'https://exampleapi.com/api/content';

  Future<List<ContentItem>> loadCachedContent() async {
    var box = await Hive.openBox<ContentItem>(contentBoxName);
    return box.values.toList();
  }


  // Save content to local cache
 Future<void> saveLocalFilePath(String path) async {
  var box = await Hive.openBox('localFiles');
  await box.add(path);
}
Future<List<String>> loadLocalFiles() async {
  var box = await Hive.openBox('localFiles');
  return List<String>.from(box.values);
}


  // Fetch Storyweaver content

  Future<void> cacheContent(List<ContentItem> contents) async {
    var box = await Hive.openBox<ContentItem>(contentBoxName);
    await box.clear();
    for (var content in contents) {
      await box.put(content.id, content);
    }
  }

  Future<List<ContentItem>> fetchStoryweaverBooks() async {
  final response = await http.get(Uri.parse(storyweaverUrl));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<dynamic> results = data['results'];
    return results.map((json) => ContentItem(
      id: json['id'].toString(),
      title: json['title'],
      category: 'Stories',
      preview: json['description'] ?? '',
      fullText: json['contents']?.toString() ?? '',
      url: '',
    )).toList();
  }
  throw Exception('Failed to load Storyweaver content');
}

Future<List<ContentItem>> fetchGutendexBooks() async {
  final response = await http.get(Uri.parse(gutendexUrl));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<dynamic> results = data['results'];
    return results.map((json) => ContentItem(
      id: json['id'].toString(),
      title: json['title'],
      category: 'Articles',
      preview: (json['bookshelves'] as List?)?.join(', ') ?? '',
      fullText: '',
      url: '',
    )).toList();
  }
  throw Exception('Failed to load Gutendex content');
}

Future<List<ContentItem>> fetchNewApiContent() async {
  final response = await http.get(Uri.parse(exampleNewApiUrl));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<dynamic> results = data['results'];
    return results.map((json) => ContentItem(
      id: json['id'].toString(),
      title: json['title'] ?? 'No Title',
      category: 'NewSource',
      preview: json['description'] ?? '',
      fullText: json['content'] ?? '',
      url: json['thumbnail'] ?? '',
    )).toList();
  }
  throw Exception('Failed to load new API content');
}

  Future<List<ContentItem>> loadCommonLit() async {
    return [];
  }

  Future<List<ContentItem>> loadReadWorks() async {
    return [];
  }

  Future<List<ContentItem>> fetchAndCacheAllContent() async {
    List<ContentItem> allContents = [];
    try {
      final storyweaver = await fetchStoryweaverBooks();
      final gutendex = await fetchGutendexBooks();
      final newApiContent = await fetchNewApiContent();
      final commonLit = await loadCommonLit();
      final readWorks = await loadReadWorks();

      allContents = [
        ...storyweaver,
        ...gutendex,
        ...newApiContent,
        ...commonLit,
        ...readWorks,
      ];

      await cacheContent(allContents);
    } catch (e) {
      allContents = await loadCachedContent();
    }
    return allContents;
  }
}











