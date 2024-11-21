// lib/models/meal_log.dart

import 'consumed_food.dart';

/// 특정 끼니의 로그를 나타내는 클래스
class MealLog {
  bool isSkipped;
  List<ConsumedFood> foods;

  MealLog({this.isSkipped = false, List<ConsumedFood>? foods})
      : foods = foods ?? [];

  Map<String, dynamic> toJson() => {
    'isSkipped': isSkipped,
    'foods': foods.map((food) => food.toJson()).toList(),
  };

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      isSkipped: json['isSkipped'] ?? false,
      foods: (json['foods'] as List<dynamic>?)
          ?.map((food) => ConsumedFood.fromJson(food))
          .toList() ??
          [],
    );
  }
}
