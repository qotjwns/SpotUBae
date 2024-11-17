import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';

class RoutineStorageService {
  static const String routineKey = 'my_routine';

  Future<void> saveRoutine(List<Exercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonExercises =
    exercises.map((e) => e.toJson()).toList();
    await prefs.setString(routineKey, json.encode(jsonExercises));
  }

  Future<List<Exercise>> loadRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    final String? routineJson = prefs.getString(routineKey);
    if (routineJson != null) {
      List<dynamic> jsonData = json.decode(routineJson);
      return jsonData.map((json) => Exercise.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<void> clearRoutine() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(routineKey);
  }
}
