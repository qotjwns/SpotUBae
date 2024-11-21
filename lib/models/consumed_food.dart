// lib/models/consumed_food.dart

class ConsumedFood {
  final String name;
  final double carbs;
  final double protein;
  final double fat;
  final double quantity; // 단위: 그램 (섭취량)

  ConsumedFood({
    required this.name,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.quantity,
  });

  // JSON 직렬화 메서드
  Map<String, dynamic> toJson() => {
    'name': name,
    'carbs': carbs,
    'protein': protein,
    'fat': fat,
    'quantity': quantity,
  };

  factory ConsumedFood.fromJson(Map<String, dynamic> json) {
    return ConsumedFood(
      name: json['name'],
      carbs: (json['carbs'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
    );
  }
}
