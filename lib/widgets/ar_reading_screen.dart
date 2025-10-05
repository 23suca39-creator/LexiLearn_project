import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class ARReadingScreen extends StatefulWidget {
  final String text;
  ARReadingScreen({required this.text});
  
  @override
  State<ARReadingScreen> createState() => _ARReadingScreenState();
}

class _ARReadingScreenState extends State<ARReadingScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = "No cameras available";
          _isLoading = false;
        });
        return;
      }
      
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );
      
      await _controller?.initialize();
      
      if (mounted) {
        setState(() {
          _isReady = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Camera error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('AR Reading Guide'),
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera background
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text('Initializing Camera...', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            )
          else if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  SizedBox(height: 20),
                  Text(_error!, style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            )
          else if (_isReady && _controller != null)
            CameraPreview(_controller!)
          else
            Container(color: Colors.black),

          // SUPER BRIGHT, CLEAR AR Text Overlay
          if (_isReady || _error == null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  // PURE WHITE BACKGROUND - NO TRANSPARENCY
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade700, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 0),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(28),
                child: Column(
                  children: [
                    // Header with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.auto_stories, color: Colors.white, size: 32),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Read Aloud',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // MAIN TEXT - SUPER CLEAR AND BOLD
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 32,              // EXTRA BIG
                          fontWeight: FontWeight.w800, // EXTRA BOLD
                          color: Colors.black,       // PURE BLACK
                          height: 1.8,              // EXTRA SPACING BETWEEN LINES
                          letterSpacing: 1.5,       // SPACING BETWEEN LETTERS
                          wordSpacing: 3.0,         // SPACING BETWEEN WORDS
                          fontFamily: 'OpenDyslexic', // DYSLEXIC FONT
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // AR Guide Instructions - MORE VISIBLE
          if (_isReady)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.phone_android, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Hold your device steady and read the text above aloud',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
