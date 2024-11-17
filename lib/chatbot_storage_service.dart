// ChatBotStorageService.dart
import 'dart:convert';
import 'dart:io';
import 'package:group_app/storage_service.dart';
import 'models/message.dart';

class ChatBotStorageService {
  final StorageService _storageService = StorageService();

  // 운동 종목을 불러오는 메서드
  Future<List<String>> loadExercisesFromDownload(String workoutType) async {
    return await _storageService.loadExercisesFromDownload(workoutType);
  }

  // 메시지 저장 메서드
  Future<void> saveMessages(String workoutType, List<Message> messages) async {
    await _storageService.saveMessages(workoutType, messages);
  }

  // 메시지 불러오기 메서드
  Future<List<Message>> loadMessages(String workoutType) async {
    return await _storageService.loadMessages(workoutType);
  }
}
