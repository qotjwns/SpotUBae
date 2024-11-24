// lib/formatters/max_value_formatter.dart

import 'package:flutter/services.dart';

class MaxValueInputFormatter extends TextInputFormatter {
  final double maxValue;

  MaxValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      if (newValue.text.isEmpty) {
        return newValue;
      }

      final double value = double.parse(newValue.text);
      if (value > maxValue) {
        return oldValue;
      }
    } catch (e) {
      // 파싱 에러 시, 입력을 거부
      return oldValue;
    }

    return newValue;
  }
}
