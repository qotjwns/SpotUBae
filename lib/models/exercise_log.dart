import 'exercise.dart';

class ExerciseLog {
  final DateTime date;
  final List<Exercise> exercises;

  ExerciseLog({required this.date, required this.exercises});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
    );
  }
}