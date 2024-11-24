// services/storage_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class StorageService {

  List<String> chestWorkouts = [
    "Barbell Bench Press", "Incline Barbell Press", "Incline Dumbbell Press",
    "Decline Barbell Press", "Dumbbell Bench Press", "Dumbbell Fly",
    "Dumbbell Pullover", "Cable Fly", "Chest Fly", "Cable Crossovers",
    "Push-up", "Dip", "Chest Press Machine", "Pec Deck Machine",
    "Medicine Ball Push-ups", "Chest Dips", "Bench Press"
  ];

  List<String> backWorkouts = [
    "Deadlift", "Pull-up", "Lat Pulldown", "Seated Row", "T-bar Row", "Superman",
    "Bent-Over Row", "Bent-Over Barbell Row", "Single-Arm Dumbbell Row", "Inverted Row",
    "Cable Row",  "Machine Assisted Pull-up", "Chest-Supported Row", "Wide-Grip Seated Cable Row", "Straight-Arm Pulldown"
  ];

  List<String> shoulderWorkouts = [
    "Overhead Press", "Lateral Raise", "Front Raise", "Arnold Press", "Rear Delt Fly",
    "Upright Row", "Face Pull", "Cable Lateral Raise", "Dumbbell Shoulder Press", "Barbell Overhead Press",
    "Seated Dumbbell Press", "Standing Military Press", "Machine Shoulder Press",
    "Plate Front Raise", "Incline Bench Rear Delt Raise", "Cable Rear Delt Fly",
    "Single-Arm Cable Lateral Raise", "Dumbbell Reverse Fly",
  ];

  List<String> legWorkouts = [
    "Squat", "Leg Press", "Lunges", "Leg Curl", "Leg Extension", "Deadlift",
    "Bulgarian Split Squat", "Hack Squat", "Front Squat",
    "Sumo Squat", "Romanian Deadlift", "Glute Bridge",
    "Hip Thrust", "Calf Raise", "Goblet Squat", "Single-Leg Deadlift",
    "Seated Leg Curl", "Standing Calf Raise", "Smith Machine Squat",
    "Kettlebell Swing",
  ];

  List<String> armsWorkouts = [
    "Bicep Curl", "Tricep Pushdown", "Hammer Curl", "Overhead Tricep Extension",
    "Preacher Curl", "Skull Crushers","Concentration Curl", "Cable Curl",
    "Close-Grip Bench Press", "Dumbbell Kickback", "EZ-Bar Curl",
    "Tricep Dips", "Zottman Curl", "Reverse Curl", "Incline Dumbbell Curl",
    "Cable Overhead Tricep Extension", "Spider Curl", "Single-Arm Cable Curl",
    "Bench Dips", "Barbell Curl",
  ];

  List<String> absWorkouts = [
    "Crunches", "Plank", "Leg Raises", "Bicycle Crunches", "Russian Twists",
    "Hanging Leg Raises",  "Mountain Climbers", "Flutter Kicks",
    "V-Ups", "Reverse Crunch", "Side Plank",
    "Toe Touches", "Cable Crunch", "Swiss Ball Crunch", "Ab Wheel Rollout",
  ];

  List<String> cardioWorkouts = [
    "Running", "Cycling", "Jump Rope", "Burpees", "Mountain Climbers",
    "High Knees", "Boxing", "Swimming", "Jumping Jacks", "Sprints", "Treadmill Incline Walking",
  ];

  List<String> recommendationWorkouts = [
  ];

  // 운동 부위에 맞는 운동 목록을 반환하는 메서드
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

  // 텍스트를 정규화하는 헬퍼 메서드
  String _normalizeText(String text) {
    return text.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ') // 알파벳, 숫자, 공백을 제외한 모든 문자를 공백으로 대체
        .replaceAll(RegExp(r'\s+'), ' ') // 여러 개의 공백을 하나로 대체
        .trim();
  }

  // 운동 종목을 추출하는 메서드
  List<String> extractMatchingExercises(String response, String workoutCategory) {
    List<String> matchingExercises = [];
    List<String> categoryWorkouts = getWorkoutsByCategory(workoutCategory);

    // 운동 종목 리스트를 길이가 긴 순서대로 정렬 (먼저 긴 종목명 매칭)
    categoryWorkouts.sort((a, b) => b.length.compareTo(a.length));

    // 응답 텍스트 정규화
    String normalizedResponse = _normalizeText(response);
    print("Normalized Response: $normalizedResponse"); // 디버깅용

    for (var workout in categoryWorkouts) {
      // 운동 이름 정규화
      String normalizedWorkout = _normalizeText(workout);

      // 운동 이름의 끝에 's'가 있으면 제거 (복수형 무시)
      if (normalizedWorkout.endsWith('s')) {
        normalizedWorkout = normalizedWorkout.substring(0, normalizedWorkout.length - 1);
      }

      // 복수형 처리: 운동 이름 끝에 's'가 있으면 허용
      RegExp regExp = RegExp(r'\b' + RegExp.escape(normalizedWorkout) + r's?\b');

      // 운동 이름이 응답에 포함되어 있는지 확인
      if (regExp.hasMatch(normalizedResponse)) {
        matchingExercises.add(workout);
        print("Matched Workout: $workout"); // 디버깅용

        // 이미 매칭된 부분을 제거하여 중복 매칭 방지
        normalizedResponse = normalizedResponse.replaceAll(regExp, '');
      }
    }

    return matchingExercises;
  }

  // 애플리케이션 문서 디렉토리 경로를 가져오는 메서드
  Future<String> getApplicationDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      print("애플리케이션 디렉토리 경로를 가져오는 중 오류 발생: $e");
      return '';
    }
  }

  // 운동 종목을 파일에 저장하는 메서드 - 덮어쓰기
  Future<void> setExercisesToDownload(List<String> exercises, String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        print("애플리케이션 디렉토리 경로를 가져올 수 없습니다.");
        return;
      }

      // 운동 부위(workoutType)에 맞는 파일 이름 설정 (소문자 사용)
      final file = File('$appDir/recommended_workouts_$workoutType.json');
      final jsonContent = jsonEncode(exercises);
      await file.writeAsString(jsonContent);

      print("$workoutType 운동 종목이 성공적으로 저장되었습니다: ${file.path}");
    } catch (e) {
      print("$workoutType 운동 종목 저장 중 오류 발생: $e");
    }
  }

  // 운동 종목을 파일에 추가하는 메서드 - 추가
  Future<void> addExercisesToDownload(List<String> exercises, String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        print("애플리케이션 디렉토리 경로를 가져올 수 없습니다.");
        return;
      }

      final file = File('$appDir/recommended_workouts_$workoutType.json');
      List<String> existingExercises = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(content);
        existingExercises = jsonData.map((e) => e.toString()).toList();
      }

      // 중복되지 않는 운동만 추가
      final newExercises = exercises.where((e) => !existingExercises.contains(e)).toList();
      existingExercises.addAll(newExercises);

      final jsonContent = jsonEncode(existingExercises);
      await file.writeAsString(jsonContent);

      print("$workoutType 운동 종목이 성공적으로 추가되었습니다: ${file.path}");
    } catch (e) {
      print("$workoutType 운동 종목 추가 중 오류 발생: $e");
    }
  }

  // 저장된 운동 종목 불러오기 (운동 부위별로 불러오기)
  Future<List<String>> loadExercisesFromDownload(String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        print("애플리케이션 디렉토리 경로를 가져올 수 없습니다.");
        return [];
      }

      // 운동 부위별로 파일 경로 설정
      final file = File('$appDir/recommended_workouts_$workoutType.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        print("로드된 $workoutType 운동 목록 내용: $content");  // 디버깅용
        List<dynamic> jsonData = jsonDecode(content);
        print("로드된 $workoutType 운동 목록: ${jsonData.toString()}");  // 디버깅용
        return jsonData.map((e) => e.toString()).toList();
      } else {
        print("$workoutType 운동 종목 파일이 존재하지 않습니다.");
        return [];
      }
    } catch (e) {
      print("운동 종목 불러오기 중 오류 발생: $e");
      return [];
    }
  }

  Future<void> saveMessages(String workoutType, List<Message> messages) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        print("애플리케이션 디렉토리 경로를 가져올 수 없습니다.");
        return;
      }

      final file = File('$appDir/messages_$workoutType.json');
      final jsonContent = jsonEncode(messages.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonContent);

      print("Messages for $workoutType saved successfully: ${file.path}");
    } catch (e) {
      print("Error saving messages: $e");
    }
  }

  // 메시지 불러오기 메서드
  Future<List<Message>> loadMessages(String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        print("애플리케이션 디렉토리 경로를 가져올 수 없습니다.");
        return [];
      }

      final file = File('$appDir/messages_$workoutType.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(content);

        // Message 객체로 변환하여 반환
        return jsonData.map((e) => Message.fromJson(e)).toList();
      } else {
        print("No message file found for $workoutType.");
        return [];
      }
    } catch (e) {
      print("Error loading messages: $e");
      return [];
    }
  }

  Future<void> deleteMessages(String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        print("애플리케이션 디렉토리 경로를 가져올 수 없습니다.");
        return;
      }

      final file = File('$appDir/messages_$workoutType.json');
      if (await file.exists()) {
        await file.delete();
        print("Messages for $workoutType deleted successfully.");
      } else {
        print("No message file found for $workoutType.");
      }
    } catch (e) {
      print("Error deleting messages: $e");
    }
  }

  // 운동 종목을 마스터 리스트에 추가하는 메서드 (필요시 사용)
  Future<void> addNewWorkouts(String workoutType, List<String> newWorkouts) async {
    List<String> currentWorkouts = getWorkoutsByCategory(workoutType);

    for (var workout in newWorkouts) {
      if (!currentWorkouts.contains(workout)) {
        currentWorkouts.add(workout);
      }
    }

    print("Updated $workoutType workouts: $currentWorkouts");
  }

  // 북마크된 운동 목록을 불러오는 메서드
  Future<List<String>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('bookmarkedWorkouts') ?? [];
  }

  // 북마크된 운동 목록을 저장하는 메서드
  Future<void> saveBookmarks(List<String> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarkedWorkouts', bookmarks);
  }

  // 모든 운동 데이터를 초기화하고 파일에 저장하는 메서드
  Future<void> initializeWorkouts() async {
    final appDir = await getApplicationDirectory();
    if (appDir.isEmpty) {
      print("애플리케이션 디렉토리 경로를 가져올 수 없습니다.");
      return;
    }

    // 각 카테고리에 대한 파일 경로 설정
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
        print("$category 운동 종목이 성공적으로 초기화되었습니다: ${file.path}");
      } catch (e) {
        print("$category 운동 종목 초기화 중 오류 발생: $e");
      }
    }
  }
}
