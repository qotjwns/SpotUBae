// lib/widgets/height_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeightInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final String? Function(String?) validator;

  const HeightInputField({
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
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
      validator: validator,
    );
  }
}