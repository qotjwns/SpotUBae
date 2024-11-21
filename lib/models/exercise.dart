// models/exercise.dart

import 'package:uuid/uuid.dart';

class Exercise {
  final String id;
  final String name;
  final List<Map<String, int>> sets; // 각 세트별로 무게와 횟수를 저장
  final String recentRecord; // 최근 기록
  final String recommendedRecord; // 추천 기록

  Exercise({
    String? id,
    required this.name,
    this.sets = const [],
    this.recentRecord = '0kg x 0회',
    this.recommendedRecord = '0kg x 0회',
  }) : id = id ?? const Uuid().v4();

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: (json['sets'] is List)
          ? (json['sets'] as List).map((set) {
        if (set is Map<String, dynamic>) {
          return {
            'weight': set['weight'] as int? ?? 0,
            'reps': set['reps'] as int? ?? 0,
          };
        } else {
          return {'weight': 0, 'reps': 0};
        }
      }).toList()
          : [],
      recentRecord: json['recentRecord'] as String? ?? '0kg x 0회',
      recommendedRecord: json['recommendedRecord'] as String? ?? '0kg x 0회',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'recentRecord': recentRecord,
      'recommendedRecord': recommendedRecord,
    };
  }
}
