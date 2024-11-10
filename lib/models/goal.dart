// lib/models/goal.dart

class Goal {
  final String type; // "daily", "weekly", "monthly"
  final String? value;
  final DateTime? setDate;

  Goal({
    required this.type,
    this.value,
    this.setDate,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      type: json['type'],
      value: json['value'],
      setDate: json['setDate'] != null ? DateTime.parse(json['setDate']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    'setDate': setDate?.toIso8601String(),
  };
}
