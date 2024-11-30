// lib/widgets/goal_card.dart

import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  final String goalType;
  final String? goal;
  final VoidCallback onEdit;
  final VoidCallback onReset; // 초기화 콜백 추가

  const GoalCard({
    required this.goalType,
    required this.goal,
    required this.onEdit,
    required this.onReset, // 초기화 콜백 추가
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: ListTile(
        title: Text(goalType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(goal ?? "No goal set"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit Goal',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onReset, // 초기화 버튼
              tooltip: 'Reset Goal',
            ),
          ],
        ),
      ),
    );
  }
}
