// lib/widgets/buttons_row.dart

import 'package:flutter/material.dart';
import 'animated_elevated_button.dart';

class ButtonsRow extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onReset;

  const ButtonsRow({
    super.key,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Save and Calculate 버튼
        AnimatedElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
          ),
          child: const Text('Save and Calculate'),
        ),
        // Reset 버튼
        AnimatedElevatedButton(
          onPressed: onReset,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.black,
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}