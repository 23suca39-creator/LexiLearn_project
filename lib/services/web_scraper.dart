// lib/services/web_scraper.dart
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class WebScraperService {
  Future<String> fetchArticleText(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      // Extract the desired part, e.g., main article or first <p>
      final content = document.querySelector('article') ?? document.querySelector('p');
      return content?.text.trim() ?? '';
    } else {
      throw Exception('Failed to load content');
    }
  }
}
