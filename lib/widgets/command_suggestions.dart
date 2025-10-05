import 'package:flutter/material.dart';

class CommandSuggestions extends StatelessWidget {
  final List<String> commands;
  const CommandSuggestions({required this.commands, super.key});

  @override
  Widget build(BuildContext context) {
    final dyslexiaFontFamily = 'OpenDyslexic, Arial Rounded, sans-serif';
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: commands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final command = commands[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Center(
                child: Text(
                  command,
                  style: TextStyle(
                    fontFamily: dyslexiaFontFamily,
                    fontSize: 16,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
