import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/custom_content.dart';

class CustomContentService {
  final String baseUrl = "https://api.example.com/contents"; // replace with actual API URL

  Future<List<CustomContent>> fetchContents() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CustomContent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load content');
    }
  }
}
