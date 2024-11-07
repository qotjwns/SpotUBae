import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../formatters/max_value_formatter.dart';

class NumberInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final int maxValue;

  const NumberInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.maxValue = 999,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
        MaxValueInputFormatter(maxValue),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: onChanged,
    );
  }
}
