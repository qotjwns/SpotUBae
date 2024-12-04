
import 'package:flutter/material.dart';

class MacroResultsDisplay extends StatelessWidget {
  final double dailyCalories;
  final double carbs;
  final double protein;
  final double fat;

  const MacroResultsDisplay({
    super.key,
    required this.dailyCalories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,           children: [
            Text(
              'Daily Calorie Intake',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20.0,                 fontWeight: FontWeight.bold,               ),
              textAlign: TextAlign.center,             ),
            const SizedBox(height: 10),
            Text(
              'Calories: ${dailyCalories.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,             ),
            Text(
              'Carbs: ${carbs.toStringAsFixed(1)} g',
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,             ),
            Text(
              'Protein: ${protein.toStringAsFixed(1)} g',
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,             ),
            Text(
              'Fat: ${fat.toStringAsFixed(1)} g',
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,             ),
          ],
        ),
      ),
    );
  }
}