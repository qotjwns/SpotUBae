class ProgramUserData {
  int age;
  String gender;
  double currentWeight;
  double height;
  double currentBodyFat;
  double goalWeight;
  double goalBodyFat;
  String programType; // final 제거하여 mutable로 변경, OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com
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

  factory ProgramUserData.fromMap(Map<String, dynamic> map) {
    return ProgramUserData(
      age: map['age'],
      gender: map['gender'],
      currentWeight: map['currentWeight'],
      height: map['height'],
      currentBodyFat: map['currentBodyFat'],
      goalWeight: map['goalWeight'],
      goalBodyFat: map['goalBodyFat'],
      programType: map['programType'],
      dailyCarbs: map['dailyCarbs'],
      dailyProtein: map['dailyProtein'],
      dailyFat: map['dailyFat'],
    );
  }
}
