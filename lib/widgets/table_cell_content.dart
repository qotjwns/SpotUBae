// lib/widgets/table_cell_content.dart
import 'package:flutter/material.dart';

class TableCellContent extends StatelessWidget {
  final String text;
  final VoidCallback onAddGoal;
  final String? goal; // 추가된 목표를 표시하기 위한 필드

  const TableCellContent({
    super.key,
    required this.text,
    required this.onAddGoal,
    this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          goal != null
              ? Text(
            goal!,
            style: const TextStyle(fontSize: 16, color: Colors.blue),
          )
              : const Text(
            '목표를 추가해주세요',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAddGoal,
          ),
        ],
      ),
    );
  }
}
