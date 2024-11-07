import 'package:flutter/material.dart';
import 'package:group_app/widgets/button_widget.dart';

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
        children: predefinedMessages.map((message) {
          return ButtonWidget(
            onPressed: () => onMessageSelected(message),
            label: message
          );
        }).toList(),
      ),
    );
  }
}