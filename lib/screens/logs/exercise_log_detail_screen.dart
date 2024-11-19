import 'package:flutter/material.dart';
import '../../models/exercise.dart';

class ExerciseLogDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseLogDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              exercise.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: exercise.sets.length,
                itemBuilder: (context, index) {
                  final set = exercise.sets[index];
                  return ListTile(
                    title: Text(
                        'Set ${index + 1}: ${set['weight']} kg x ${set['reps']} reps'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
