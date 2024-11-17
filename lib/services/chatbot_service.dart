import 'package:group_app/storage_service.dart';

import '../models/message.dart';  // StorageService 임포트

class ChatBotStorageService {
  final StorageService _storageService = StorageService(); // StorageService 인스턴스 사용

  // 운동 종목을 불러오는 메서드 (StorageService의 메서드 활용)
  Future<List<String>> loadExercisesFromDownload(String workoutType) async {
    // StorageService의 loadExercisesFromDownload 메서드를 호출하여 운동 종목 불러오기
    return await _storageService.loadExercisesFromDownload(workoutType);
  }

  // 메시지 저장 메서드
  Future<void> saveMessages(String workoutType, List<Message> messages) async {
    // 저장 로직
  }

  // 메시지 불러오기 메서드
  Future<List<Message>> loadMessages(String workoutType) async {
    // 불러오기 로직
    return [];
  }
}
