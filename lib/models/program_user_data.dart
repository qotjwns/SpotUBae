class ProgramUserData {
  final int age;
  final String gender;
  double currentWeight;
  final double height;
  double currentBodyFat;
  final double goalWeight;
  final double goalBodyFat;
  String
      programType; // final 제거하여 mutable로 변경, OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com
  double dailyCarbs;
  double dailyProtein;
  double dailyFat;

  ProgramUserData({
    required this.age,
    required this.gender,
    required this.currentWeight,
    required this.height,
    required this.currentBodyFat,
    required this.goalWeight,
    required this.goalBodyFat,
    required this.programType,
    required this.dailyCarbs,
    required this.dailyProtein,
    required this.dailyFat,
  });

  factory ProgramUserData.fromMap(Map<String, dynamic> map) {
    return ProgramUserData(
      age: map['age'] ?? 25,
      gender: map['gender'] ?? 'male',
      currentWeight: (map['currentWeight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      currentBodyFat: (map['currentBodyFat'] as num).toDouble(),
      goalWeight: (map['goalWeight'] as num).toDouble(),
      goalBodyFat: (map['goalBodyFat'] as num).toDouble(),
      programType: map['programType'] ?? 'Bulking',
      dailyCarbs: map['dailyCarbs'] != null
          ? (map['dailyCarbs'] as num).toDouble()
          : 0.0,
      dailyProtein: map['dailyProtein'] != null
          ? (map['dailyProtein'] as num).toDouble()
          : 0.0,
      dailyFat:
          map['dailyFat'] != null ? (map['dailyFat'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'currentWeight': currentWeight,
      'height': height,
      'currentBodyFat': currentBodyFat,
      'goalWeight': goalWeight,
      'goalBodyFat': goalBodyFat,
      'programType': programType,
      'dailyCarbs': dailyCarbs,
      'dailyProtein': dailyProtein,
      'dailyFat': dailyFat,
    };
  }
}
