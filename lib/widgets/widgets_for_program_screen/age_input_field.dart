// lib/widgets/age_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AgeInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final String? Function(String?) validator;

  const AgeInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
      validator: validator,
    );
  }
}