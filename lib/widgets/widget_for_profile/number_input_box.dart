import 'package:flutter/material.dart';
import 'number_input_field.dart';

class NumberInputBox extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? errorText;
  final int maxValue;

  const NumberInputBox({
    super.key,
    required this.labelText,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.maxValue = 999,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          constraints: const BoxConstraints(
            minWidth: 80,
            maxWidth: 150,
            minHeight: 40,
            maxHeight: 80,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: NumberInputField(
                      controller: controller,
                      onChanged: onChanged,
                      maxValue: maxValue,
                    ),
                  ),
                  Text(
                    labelText.endsWith('Fat (%)') ? '%' : 'KG',
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                  child: Text(
                    errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
