// lib/widgets/exercise_list_item.dart
import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onDelete;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
        ),
        title: Text(exercise.name),
        subtitle: Text('${exercise.sets} 세트 x ${exercise.reps} 회'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}