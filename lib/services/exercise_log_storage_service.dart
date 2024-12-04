import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/logs/exercise_log.dart';

class ExerciseLogStorageService {
  static const String exerciseLogKey = 'exercise_logs';

  Future<void> saveExerciseLog(ExerciseLog log) async {
    final prefs = await SharedPreferences.getInstance();
    List<ExerciseLog> currentLogs = await loadAllExerciseLogs();

    currentLogs
        .add(log); //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

    String jsonString =
        json.encode(currentLogs.map((log) => log.toJson()).toList());
    await prefs.setString(exerciseLogKey, jsonString);
  }

  Future<List<ExerciseLog>> loadAllExerciseLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsJson = prefs.getString(exerciseLogKey);
    if (logsJson != null) {
      List<dynamic> jsonData = json.decode(logsJson);
      return jsonData.map((json) => ExerciseLog.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<ExerciseLog>> loadExerciseLogsByDate(DateTime date) async {
    List<ExerciseLog> allLogs = await loadAllExerciseLogs();
    return allLogs.where((log) => isSameDate(log.date, date)).toList();
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
