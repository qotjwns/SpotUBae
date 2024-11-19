import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
    "Bent-Over Row", "Bent-Over Barbell Row"
  ];

  List<String> shoulderWorkouts = [
    "Overhead Press", "Lateral Raise", "Front Raise", "Arnold Press"
  ];

  List<String> legWorkouts = [
    "Squat", "Leg Press", "Lunges", "Leg Curl", "Leg Extension"
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

  // 운동 종목을 파일에 저장하는 메서드
  Future<void> saveExercisesToDownload(List<String> exercises, String workoutType) async {
    try {
      final appDir = await getApplicationDirectory();
      if (appDir.isEmpty) {
        print("애플리케이션 디렉토리 경로를 가져올 수 없습니다.");
        return;
      }

      // 운동 부위(workoutType)에 맞는 파일 이름 설정
      final file = File('$appDir/recommended_workouts_$workoutType.json');
      final jsonContent = jsonEncode(exercises);
      await file.writeAsString(jsonContent);

      print("$workoutType 운동 종목이 성공적으로 저장되었습니다: ${file.path}");
    } catch (e) {
      print("운동 종목 저장 중 오류 발생: $e");
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
        List<dynamic> jsonData = jsonDecode(content);
        print("로드된 추천 운동 목록: ${jsonData.toString()}");  // 디버깅용
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
}
