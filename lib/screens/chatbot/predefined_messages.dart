import 'package:flutter/material.dart';

class PredefinedMessages extends StatelessWidget {
  final List<String> predefinedMessages;
  final Function(String) onMessageSelected;

  const PredefinedMessages({
    super.key,
    required this.predefinedMessages,
    required this.onMessageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: predefinedMessages.map((message) {
          return ElevatedButton(
            onPressed: () => onMessageSelected(message),
            child: Text(message),
          );
        }).toList(),
      ),
    );
  }
}