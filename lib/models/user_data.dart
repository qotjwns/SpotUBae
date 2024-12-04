class UserData {
  final DateTime date;
  double weight;
  double bodyFat;

  UserData({
    required this.date,
    required this.weight,
    required this.bodyFat,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
      bodyFat: (json['bodyFat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'bodyFat': bodyFat,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      date: DateTime.parse(map['date']),
      weight: (map['weight'] as num).toDouble(),
      bodyFat: (map['bodyFat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'bodyFat': bodyFat,
    };
  }
}
