import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {
  List<String> chestWorkouts = [
    "Barbell Bench Press",
    "Incline Barbell Press",
    "Incline Dumbbell Press",
    "Decline Barbell Press",
    "Dumbbell Bench Press",
    "Dumbbell Fly",
    "Dumbbell Pullover",
    "Cable Fly",
    "Chest Fly",
    "Cable Crossovers",
    "Push-up",
    "Dip",
    "Chest Press Machine",
    "Pec Deck Machine",
    "Medicine Ball Push-ups",
    "Chest Dips",
    "Bench Press"
  ];

  List<String> backWorkouts = [
    "Deadlift",
    "Pull-up",
    "Lat Pulldown",
    "Seated Row",
    "T-bar Row",
    "Superman",
    "Bent-Over Row",
    "Bent-Over Barbell Row",
    "Single-Arm Dumbbell Row",
    "Inverted Row",
    "Cable Row",
    "Machine Assisted Pull-up",
    "Chest-Supported Row",
    "Wide-Grip Seated Cable Row",
    "Straight-Arm Pulldown"
  ];

  List<String> shoulderWorkouts = [
    "Overhead Press",
    "Lateral Raise",
    "Front Raise",
    "Arnold Press",
    "Rear Delt Fly",
    "Upright Row",
    "Face Pull",
    "Cable Lateral Raise",
    "Dumbbell Shoulder Press",
    "Barbell Overhead Press",
    "Seated Dumbbell Press",
    "Standing Military Press",
    "Machine Shoulder Press",
    "Plate Front Raise",
    "Incline Bench Rear Delt Raise",
    "Cable Rear Delt Fly",
    "Single-Arm Cable Lateral Raise",
    "Dumbbell Reverse Fly",
  ];

  List<String> legWorkouts = [
    "Squat",
    "Leg Press",
    "Lunges",
    "Leg Curl",
    "Leg Extension",
    "Deadlift",
    "Bulgarian Split Squat",
    "Hack Squat",
    "Front Squat",
    "Sumo Squat",
    "Romanian Deadlift",
    "Glute Bridge",
    "Hip Thrust",
    "Calf Raise",
    "Goblet Squat",
    "Single-Leg Deadlift",
    "Seated Leg Curl",
    "Standing Calf Raise",
    "Smith Machine Squat",
    "Kettlebell Swing",
  ];

  List<String> armsWorkouts = [
    "Bicep Curl",
    "Tricep Pushdown",
    "Hammer Curl",
    "Overhead Tricep Extension",
    "Preacher Curl",
    "Skull Crushers",
    "Concentration Curl",
    "Cable Curl",
    "Close-Grip Bench Press",
    "Dumbbell Kickback",
    "EZ-Bar Curl",
    "Tricep Dips",
    "Zottman Curl",
    "Reverse Curl",
    "Incline Dumbbell Curl",
    "Cable Overhead Tricep Extension",
    "Spider Curl",
    "Single-Arm Cable Curl",
    "Bench Dips",
    "Barbell Curl",
  ];

  List<String> absWorkouts = [
    "Crunches",
    "Plank",
    "Leg Raises",
    "Bicycle Crunches",
    "Russian Twists",
    "Hanging Leg Raises",
    "Mountain Climbers",
    "Flutter Kicks",
    "V-Ups",
    "Reverse Crunch",
    "Side Plank",
    "Toe Touches",
    "Cable Crunch",
    "Swiss Ball Crunch",
    "Ab Wheel Rollout",
  ];

  List<String> cardioWorkouts = [
    "Running",
    "Cycling",
    "Jump Rope",
    "Burpees",
    "Mountain Climbers",
    "High Knees",
    "Boxing",
    "Swimming",
    "Jumping Jacks",
    "Sprints",
    "Treadmill Incline Walking",
  ];

  List<String> recommendationWorkouts = [];

  List<String> getWorkoutsByCategory(String category) {
    switch (category.toLowerCase()) {
      case "chest":
        return chestWorkouts;
      case "back":
        return backWorkouts;
      case "shoulder":
        return shoulderWorkouts;
      case "legs":
        return legWorkouts;
      case "arms":
        return armsWorkouts;
      case "abs":
        return absWorkouts;
      case "cardio":
        return cardioWorkouts;
      case "recommendation":
        return recommendationWorkouts;
      default:
        return [];
    }
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  List<String> extractMatchingExercises(
      String response, String workoutCategory) {
    List<String> matchingExercises = [];
    List<String> categoryWorkouts = getWorkoutsByCategory(workoutCategory);
    categoryWorkouts.sort((a, b) => b.length.compareTo(a.length));

    // 응답 텍스트 정규화
    String normalizedResponse = _normalizeText(response);

    for (var workout in categoryWorkouts) {
      String normalizedWorkout = _normalizeText(workout);

      if (normalizedWorkout.endsWith('s')) {
        normalizedWorkout =
            normalizedWorkout.substring(0, normalizedWorkout.length - 1);
      }
      RegExp regExp =
          RegExp(r'\b' + RegExp.escape(normalizedWorkout) + r's?\b');

      if (regExp.hasMatch(normalizedResponse)) {
        matchingExercises.add(workout);
        print("Matched Workout: $workout");
        normalizedResponse = normalizedResponse.replaceAll(regExp, '');
      }
    }
    return matchingExercises;
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  Future<String> getApplicationDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      return '';
    }
  }

  Future<void> setExercisesToDownload(
      List<String> exercises, String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        return;
      }
      final file = File('$appDir/recommended_workouts_$workoutType.json');
      final jsonContent = jsonEncode(exercises);
      await file.writeAsString(jsonContent);
    } catch (e) {
      print(e);
    }
  }

  Future<void> addExercisesToDownload(
      List<String> exercises, String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        return;
      }

      final file = File('$appDir/recommended_workouts_$workoutType.json');
      List<String> existingExercises = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(content);
        existingExercises = jsonData.map((e) => e.toString()).toList();
      }
      final newExercises =
          exercises.where((e) => !existingExercises.contains(e)).toList();
      existingExercises.addAll(newExercises);

      final jsonContent = jsonEncode(existingExercises);
      await file.writeAsString(jsonContent);
    } catch (e) {
      print(e);
    }
  }

  Future<List<String>> loadExercisesFromDownload(String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        return [];
      }

      final file = File('$appDir/recommended_workouts_$workoutType.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(content);
        return jsonData.map((e) => e.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMessages(String workoutType, List<Message> messages) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        return;
      }

      final file = File('$appDir/messages_$workoutType.json');
      final jsonContent = jsonEncode(messages.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonContent);
    } catch (e) {
      print(e);
    }
  }

  Future<List<Message>> loadMessages(String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        return [];
      }

      final file = File('$appDir/messages_$workoutType.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(content);
        return jsonData.map((e) => Message.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteMessages(String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        return;
      }

      final file = File('$appDir/messages_$workoutType.json');
      if (await file.exists()) {
        await file.delete();
      } else {}
    } catch (e) {
      print(e);
    }
  }

  Future<void> addNewWorkouts(
      String workoutType, List<String> newWorkouts) async {
    List<String> currentWorkouts = getWorkoutsByCategory(workoutType);

    for (var workout in newWorkouts) {
      if (!currentWorkouts.contains(workout)) {
        currentWorkouts.add(workout);
      }
    }

    print("Updated $workoutType workouts: $currentWorkouts");
  }

  Future<List<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('bookmarkedWorkouts') ?? [];
  }

  Future<void> saveBookmarks(List<String> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarkedWorkouts', bookmarks);
  }

  Future<void> initializeWorkouts() async {
    final appDir = await getApplicationDirectory();
    if (appDir.isEmpty) {
      return;
    }

    Map<String, List<String>> allWorkouts = {
      "recommendation": recommendationWorkouts,
      "chest": chestWorkouts,
      "back": backWorkouts,
      "shoulder": shoulderWorkouts,
      "legs": legWorkouts,
      "arms": armsWorkouts,
      "abs": absWorkouts,
      "cardio": cardioWorkouts,
    };

    for (String category in allWorkouts.keys) {
      final file = File('$appDir/recommended_workouts_$category.json');
      try {
        final jsonContent = jsonEncode(allWorkouts[category]);
        await file.writeAsString(jsonContent);
      } catch (e) {
        print(e);
      }
    }
  }
}
