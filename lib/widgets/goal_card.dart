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

  void _showFullGoalDialog(BuildContext context) {
    if (goal == null || goal!.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goalType),
        content: SingleChildScrollView(
          child: Text(goal!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: ListTile(
        title: Text(goalType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: GestureDetector(
          onTap: () => _showFullGoalDialog(context),
          child: Text(
            goal ?? "No goal set",
            maxLines: 2, // 최대 2줄로 제한
            overflow: TextOverflow.ellipsis, // 넘치는 부분은 ...으로 표시
          ),
        ),
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
