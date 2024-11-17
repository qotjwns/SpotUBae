import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

import 'models/message.dart';

class StorageService {
  static const platform = MethodChannel('com.example.group_app/download_path');  // MethodChannel 설정

  List<String> chestWorkouts = [
    "Barbell Bench Press",
    "Incline Barbell Press",
    "Decline Barbell Press",
    "Dumbbell Bench Press",
    "Dumbbell Fly",
    "Dumbbell Pullovers",
    "Cable Fly",
    "Cable Crossovers",
    "Push-up",
    "Dip",
    "Chest Press Machine",
    "Pec Deck Machine",
    "Medicine Ball Push-ups",
    "Chest Dip"
  ];

  // 운동 종목을 추출하는 메서드
  List<String> extractMatchingExercises(String response) {
    List<String> matchingExercises = [];

    for (var workout in chestWorkouts) {
      if (response.toLowerCase().contains(workout.toLowerCase().trim())) {
        matchingExercises.add(workout);
      }
    }

    return matchingExercises;
  }



  // 다운로드 디렉터리 경로를 가져오는 메서드
  Future<String> getDownloadDirectory() async {
    try {
      // 네이티브(Android)에서 다운로드 디렉터리 경로를 가져옴
      final String downloadDir = await platform.invokeMethod('getDownloadDirectory');
      return downloadDir;
    } catch (e) {
      return '';
    }
  }

  // 운동 종목을 파일에 저장하는 메서드
  Future<void> saveExercisesToDownload(List<String> exercises, String workoutType) async {
    try {
      final downloadDir = await getDownloadDirectory();
      if (downloadDir.isEmpty) {
        print("다운로드 디렉터리 경로를 가져올 수 없습니다.");
        return;
      }

      // 운동 부위(workoutType)에 맞는 파일 이름 설정
      final file = File('$downloadDir/recommended_workouts_$workoutType.json');
      final jsonContent = jsonEncode(exercises);
      await file.writeAsString(jsonContent);

      print("$workoutType 운동 종목이 성공적으로 저장되었습니다: ${file.path}");
    } catch (e) {
      print("운동 종목 저장 중 오류 발생: $e");
    }
  }



  // 저장된 운동 종목 불러오기 (운동 부위별로 불러오기)
  // 운동 종목을 불러오는 메서드
  Future<List<String>> loadExercisesFromDownload(String workoutType) async {
    try {
      final downloadDir = await getDownloadDirectory();
      if (downloadDir.isEmpty) {
        print("다운로드 디렉터리 경로를 가져올 수 없습니다.");
        return [];
      }

      // 운동 부위별로 파일 경로 설정
      final file = File('$downloadDir/recommended_workouts_$workoutType.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(content);
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
      final downloadDir = await getDownloadDirectory();  // 다운로드 디렉터리 경로 얻기
      if (downloadDir.isEmpty) {
        print("다운로드 디렉터리 경로를 가져올 수 없습니다.");
        return;
      }

      final file = File('$downloadDir/messages_$workoutType.json');  // 운동 부위별로 파일 경로 설정
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
      final downloadDir = await getDownloadDirectory();  // 다운로드 디렉터리 경로 얻기
      if (downloadDir.isEmpty) {
        print("다운로드 디렉터리 경로를 가져올 수 없습니다.");
        return [];
      }

      final file = File('$downloadDir/messages_$workoutType.json');
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
      final downloadDir = await getDownloadDirectory();  // 다운로드 디렉터리 경로 얻기
      if (downloadDir.isEmpty) {
        print("다운로드 디렉터리 경로를 가져올 수 없습니다.");
        return;
      }

      final file = File('$downloadDir/messages_$workoutType.json');  // 운동 부위별로 파일 경로 설정
      if (await file.exists()) {
        await file.delete();  // 파일 삭제
        print("Messages for $workoutType deleted successfully.");
      } else {
        print("No message file found for $workoutType.");
      }
    } catch (e) {
      print("Error deleting messages: $e");
    }
  }
}
