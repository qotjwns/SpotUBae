// lib/widgets/reset_confirmation_dialog.dart

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
          onPressed: () => Navigator.of(context).pop(true), // 'Confirm' 선택
          child: const Text('Confirm'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // 'Cancel' 선택
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}