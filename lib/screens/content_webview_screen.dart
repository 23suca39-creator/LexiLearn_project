import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContentWebViewScreen extends StatefulWidget {
  final String url;
  const ContentWebViewScreen({super.key, required this.url});

  @override
  State<ContentWebViewScreen> createState() => _ContentWebViewScreenState();
}

class _ContentWebViewScreenState extends State<ContentWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          // Inject OpenDyslexic font CSS
          _controller.runJavaScript('''
            var style = document.createElement('style');
            style.type = 'text/css';
            style.appendChild(document.createTextNode("@import url('https://cdn.jsdelivr.net/npm/@open-dyslexic/font@0.0.3/open-dyslexic.css'); body { font-family: 'OpenDyslexic', sans-serif !important; }"));
            document.head.appendChild(style);
          ''');
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reading')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
