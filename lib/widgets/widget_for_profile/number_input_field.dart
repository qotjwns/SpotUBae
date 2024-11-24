// lib/widgets/widget_for_profile/number_input_field.dart

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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        LengthLimitingTextInputFormatter(6), // 최대 입력 길이 조절 (예: 999.99)
        MaxValueInputFormatter(maxValue.toDouble()),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      onChanged: onChanged,
      onEditingComplete: () {
        final text = controller.text;
        if (text.isNotEmpty) {
          final value = double.tryParse(text);
          if (value != null) {
            controller.text = value.toStringAsFixed(1); // 소수점 첫째 자리까지 표시
          }
        }
      },
    );
  }
}
