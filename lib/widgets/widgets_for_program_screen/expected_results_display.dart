// lib/widgets/expected_results_display.dart

import 'package:flutter/material.dart';

class ExpectedResultsDisplay extends StatelessWidget {
  final double? expectedWeight1Week;
  final double? expectedBodyFat1Week;
  final double? expectedWeight1Month;
  final double? expectedBodyFat1Month;

  const ExpectedResultsDisplay({
    super.key,
    required this.expectedWeight1Week,
    required this.expectedBodyFat1Week,
    required this.expectedWeight1Month,
    required this.expectedBodyFat1Month,
  });

  @override
  Widget build(BuildContext context) {
    if (expectedWeight1Week == null ||
        expectedBodyFat1Week == null ||
        expectedWeight1Month == null ||
        expectedBodyFat1Month == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center the entire Column
      children: [
        // Expected Results after 1 Week and 1 Month side by side
        Row(
          children: [
            // Expected after 1 Week
            Expanded(
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                    children: [
                      Text(
                        'Expected after 1 Week',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Weight: ${expectedWeight1Week!.toStringAsFixed(1)} kg'),
                      Text(
                        'Body Fat Percentage: ${expectedBodyFat1Week!.toStringAsFixed(1)} %',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Expected after 1 Month
            Expanded(
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                    children: [
                      Text(
                        'Expected after 1 Month',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Weight: ${expectedWeight1Month!.toStringAsFixed(1)} kg'),
                      Text(
                        'Body Fat Percentage: ${expectedBodyFat1Month!.toStringAsFixed(1)} %',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}