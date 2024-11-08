// lib/models/exercise.dart
class Exercise {
  final String name;
  final int sets;
  final int reps;

  Exercise({required this.name, required this.sets, required this.reps});

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets,
    'reps': reps,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
    );
  }
}