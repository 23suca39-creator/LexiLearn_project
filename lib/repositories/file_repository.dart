import 'package:file_selector/file_selector.dart';

// Replace _pickAndSaveFile method:
Future<void> _pickAndSaveFile() async {
  final XFile? file = await openFile();
  if (file != null) {
    var path = file.path;
    var box = await Hive.openBox('localFiles');
    await box.add(path);
    _loadLocalFiles();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File added successfully!')),
    );
  }
}
