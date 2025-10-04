import 'package:flutter/material.dart';
import '../services/web_scraper.dart';

class ArticleScreen extends StatefulWidget {
  final String url;
  const ArticleScreen({Key? key, required this.url}) : super(key: key);

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final WebScraperService _scraper = WebScraperService();
  String? _articleText;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      final text = await _scraper.fetchArticleText(widget.url);
      setState(() {
        _articleText = text;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _articleText = 'Error loading content.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Text(
                  _articleText ?? '',
                  style: const TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontSize: 18,
                  ),
                ),
              ),
      ),
    );
  }
}
