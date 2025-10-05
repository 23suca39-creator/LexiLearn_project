import 'package:flutter/material.dart';
import '../repositories/content_repository.dart';
import '../services/custom_content_service.dart';
import '../models/custom_content.dart';

class CustomContentScreen extends StatefulWidget {
  const CustomContentScreen({super.key});

  @override
  State<CustomContentScreen> createState() => _CustomContentScreenState();
}

class _CustomContentScreenState extends State<CustomContentScreen> {
  final CustomContentService _service = CustomContentService();
  final ContentRepository _repository = ContentRepository();

  late Future<List<CustomContent>> _futureContents;

  @override
  void initState() {
    super.initState();
    _futureContents = _loadContents();
  }

  Future<List<CustomContent>> _loadContents() async {
    try {
      final contents = await _service.fetchContents();
      await _repository.saveContents(contents);
      return contents;
    } catch (_) {
      return await _repository.getCachedContents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Content Library')),
      body: FutureBuilder<List<CustomContent>>(
        future: _futureContents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final contents = snapshot.data;
          if (contents == null || contents.isEmpty) {
            return const Center(child: Text('No content available'));
          }
          return ListView.builder(
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final content = contents[index];
              return ListTile(
                title: Text(content.title),
                subtitle: Text(content.description),
                onTap: () {
                  // Navigate to details or content reader screen if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
