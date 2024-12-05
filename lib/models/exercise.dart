// models/exercise.dart

class Exercise {
  final String id;
  final String name;
  final List<Map<String, dynamic>> sets; // 'reps', 'weight', 'workoutTime', 'breakTime'
  final String? notes;
  final bool isCardio; // 운동 유형 플래그
  final int? workoutTime; // Cardio 운동 시간
  final int? breakTime; // 쉬는 시간

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    this.notes,
    this.isCardio = false,
    this.workoutTime,
    this.breakTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sets': sets,
    'notes': notes,
    'isCardio': isCardio,
    'workoutTime': workoutTime,
    'breakTime': breakTime,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw Exception("Exercise 'id' is null");
    }
    if (json['name'] == null) {
      throw Exception("Exercise 'name' is null");
    }

    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: json['sets'] != null
          ? List<Map<String, dynamic>>.from(
        (json['sets'] as List).map(
              (set) => Map<String, dynamic>.from(set),
        ),
      )
          : [],
      notes: json['notes'] as String?,
      isCardio: json['isCardio'] as bool? ?? false,
      workoutTime: json['workoutTime'] as int?,
      breakTime: json['breakTime'] as int?,
    );
  }
}
