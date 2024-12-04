import '../../models/exercise.dart';

class ExerciseLog {
  final DateTime date;
  final DateTime timestamp;
  final List<Exercise> exercises;

  ExerciseLog({
    required this.date,
    required this.timestamp,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    if (json['date'] == null) {
      throw Exception("ExerciseLog 'date' is null. JSON: $json");
    }
    if (json['exercises'] == null) {
      throw Exception("ExerciseLog 'exercises' is null. JSON: $json");
    }

    DateTime timestamp;
    if (json['timestamp'] != null) {
      timestamp = DateTime.parse(json['timestamp']).toLocal();
    } else {
      timestamp = DateTime.parse(json['date']).toLocal();
    }

    List<Exercise> exercises = [];
    for (var e in json['exercises']) {
      exercises.add(Exercise.fromJson(e));
    }

    return ExerciseLog(
      date: DateTime.parse(json['date']).toLocal(),
      exercises: exercises,
      timestamp: timestamp,
    );
  }
}
