import 'package:flutter/material.dart';

class PredefinedWorkoutsScreen extends StatelessWidget {
  PredefinedWorkoutsScreen({super.key});

  // 미리 입력된 운동 종목 리스트
  final List<String> predefinedWorkouts = [
    "Push-up",
    "Pull-up",
    "Deadlift",
    "Squat",
    "Bench Press",
    "Dumbbell Press",
    "Cable Fly",
    "Lat Pulldown"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("미리 입력된 운동 종목"),
      ),
      body: ListView.builder(
        itemCount: predefinedWorkouts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(predefinedWorkouts[index]),
          );
        },
      ),
    );
  }
}
