// models/exercise_log.dart

import 'exercise.dart';

class ExerciseLog {
  final DateTime date;
  final DateTime timestamp; // 로그 저장 시각
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
      // timestamp가 없을 경우 date 필드로 기본값 설정
      timestamp = DateTime.parse(json['date']).toLocal();
      print("경고: ExerciseLog 'timestamp'가 null입니다. 'date'를 기본값으로 설정합니다. JSON: $json");
    }

    List<Exercise> exercises = [];
    for (var e in json['exercises']) {
      try {
        exercises.add(Exercise.fromJson(e));
      } catch (e) {
        print('유효하지 않은 Exercise 항목을 건너뜁니다: $e. Exercise JSON: $e');
      }
    }

    return ExerciseLog(
      date: DateTime.parse(json['date']).toLocal(),
      exercises: exercises,
      timestamp: timestamp,
    );
  }
}
