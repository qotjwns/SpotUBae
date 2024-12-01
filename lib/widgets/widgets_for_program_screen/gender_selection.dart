// lib/widgets/gender_selection.dart

import 'package:flutter/material.dart';

class GenderSelection extends StatelessWidget {
  final String selectedGender;
  final Function(String?) onChanged;

  const GenderSelection({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Gender: '),
        Expanded(
          child: ListTile(
            title: const Text('Male'),
            leading: Radio<String>(
              value: 'male',
              groupValue: selectedGender,
              onChanged: onChanged,
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Female'),
            leading: Radio<String>(
              value: 'female',
              groupValue: selectedGender,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}