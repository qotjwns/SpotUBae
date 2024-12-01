// lib/widgets/macro_results_display.dart

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
          crossAxisAlignment: CrossAxisAlignment.center, // Center elements within the card
          children: [
            Text(
              'Daily Calorie Intake',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20.0, // 텍스트 크기 조정
                fontWeight: FontWeight.bold, // 텍스트 두께 조정
              ),
              textAlign: TextAlign.center, // Center the text
            ),
            const SizedBox(height: 10),
            Text(
              'Calories: ${dailyCalories.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center, // Center the text
            ),
            Text(
              'Carbs: ${carbs.toStringAsFixed(1)} g',
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center, // Center the text
            ),
            Text(
              'Protein: ${protein.toStringAsFixed(1)} g',
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center, // Center the text
            ),
            Text(
              'Fat: ${fat.toStringAsFixed(1)} g',
              style: const TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center, // Center the text
            ),
          ],
        ),
      ),
    );
  }
}