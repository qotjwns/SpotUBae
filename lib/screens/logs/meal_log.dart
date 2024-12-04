import '../../models/consumed_food.dart';

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
