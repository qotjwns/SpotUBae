import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_log.dart';

class ExerciseLogStorageService {
  static const String exerciseLogKey = 'exercise_logs';

  Future<void> saveExerciseLog(ExerciseLog log) async {
    final prefs = await SharedPreferences.getInstance();
    List<ExerciseLog> currentLogs = await loadAllExerciseLogs();

    int existingIndex = currentLogs.indexWhere(
            (existingLog) => isSameDate(existingLog.date, log.date));
    if (existingIndex >= 0) {
      currentLogs[existingIndex] = log;
    } else {
      currentLogs.add(log);
    }

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

  Future<ExerciseLog?> loadExerciseLogByDate(DateTime date) async {
    List<ExerciseLog> allLogs = await loadAllExerciseLogs();
    return allLogs.firstWhere(
            (log) => isSameDate(log.date, date),
        orElse: () => ExerciseLog(date: date, exercises: []));
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}