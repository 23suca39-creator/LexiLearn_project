import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/content_item.dart';



class ContentRepository {
  static const String contentBoxName = 'contentBox';

  final String storyweaverUrl = 'https://storyweaver.org.in/api/v1/books';
  final String gutendexUrl = 'https://gutendex.com/books?languages=en';

  // Load content from local cache
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
  Future<List<ContentItem>> fetchStoryweaverBooks() async {
    final response = await http.get(Uri.parse(storyweaverUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((json) => ContentItem(
        id: json['id'].toString(),
        title: json['title'],
        description: json['description'] ?? '',
        type: 'Stories',
        thumbnailUrl: json['thumbnail_url'] ?? '',
        text: json['contents']?.toString() ?? '',
      )).toList();
    }
    throw Exception('Failed to load Storyweaver content');
  }

  // Fetch Gutendex content (Project Gutenberg)
  Future<List<ContentItem>> fetchGutendexBooks() async {
    final response = await http.get(Uri.parse(gutendexUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results = data['results'];
      return results.map((json) => ContentItem(
        id: json['id'].toString(),
        title: json['title'],
        description: (json['bookshelves'] as List?)?.join(', ') ?? '',
        type: 'Articles',
        thumbnailUrl: json['formats']?['image/jpeg'] ?? '',
        text: '', // full text not included by API, load separately if needed
      )).toList();
    }
    throw Exception('Failed to load Gutendex content');
  }

  // Placeholder: For CommonLit & ReadWorks, manually import content and load from local cache
  Future<List<ContentItem>> loadCommonLit() async {
    // Simulate loading from local JSON / backend
    return [];
  }

  Future<List<ContentItem>> loadReadWorks() async {
    // Simulate loading from local JSON / backend
    return [];
  }

  // Fetch all content and cache locally
  Future<List<ContentItem>> fetchAndCacheAllContent() async {
    List<ContentItem> allContents = [];
    try {
      final storyweaver = await fetchStoryweaverBooks();
      final gutendex = await fetchGutendexBooks();
      final commonLit = await loadCommonLit();
      final readWorks = await loadReadWorks();

      allContents = [...storyweaver, ...gutendex, ...commonLit, ...readWorks];
      await cacheContent(allContents);
    } catch (e) {
      // Use cached content if fetch fails
      allContents = await loadCachedContent();
    }
    return allContents;
  }
}











