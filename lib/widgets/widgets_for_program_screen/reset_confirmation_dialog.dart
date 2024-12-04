
import 'package:flutter/material.dart';

class ResetConfirmationDialog extends StatelessWidget {
  const ResetConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Information'),
      content: const Text('Are you sure you want to reset all the information? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),           child: const Text('Confirm'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),           child: const Text('Cancel'),
        ),
      ],
    );
  }
}