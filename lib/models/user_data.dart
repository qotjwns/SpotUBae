class UserData {
  final DateTime date;
  final int weight;
  final int bodyFat;

  UserData({
    required this.date,
    required this.weight,
    required this.bodyFat,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weight': weight,
        'bodyFat': bodyFat,
      };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        date: DateTime.parse(json['date']),
        weight: json['weight'],
        bodyFat: json['bodyFat'],
      );
}
