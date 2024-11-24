// lib/models/consumed_food.dart

class ConsumedFood {
  final String name;
  final double carbsPerServing;
  final double proteinPerServing;
  final double fatPerServing;
  final double carbs;
  final double protein;
  final double fat;
  final double quantity; // 그램 단위
  final double servingWeightGrams; // 1회 제공량 그램 단위

  ConsumedFood({
    required this.name,
    required this.carbsPerServing,
    required this.proteinPerServing,
    required this.fatPerServing,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.quantity,
    required this.servingWeightGrams,
  });

  factory ConsumedFood.fromJson(Map<String, dynamic> json) {
    return ConsumedFood(
      name: json['name'],
      carbsPerServing: (json['carbsPerServing'] as num).toDouble(),
      proteinPerServing: (json['proteinPerServing'] as num).toDouble(),
      fatPerServing: (json['fatPerServing'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      servingWeightGrams: (json['servingWeightGrams'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'carbsPerServing': carbsPerServing,
      'proteinPerServing': proteinPerServing,
      'fatPerServing': fatPerServing,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'quantity': quantity,
      'servingWeightGrams': servingWeightGrams,
    };
  }
}
