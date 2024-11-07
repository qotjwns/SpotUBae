import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/message.dart';

class ChatBotStorageService {
  Future<String> _getFilePath(String workoutType) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/chatbot_$workoutType.json';
  }

  Future<void> saveMessages(String workoutType, List<Message> messages) async {
    final filePath = await _getFilePath(workoutType);
    final file = File(filePath);

    List<Map<String, dynamic>> jsonMessages =
        messages.map((msg) => msg.toJson()).toList();

    await file.writeAsString(jsonEncode(jsonMessages));
  }

  Future<List<Message>> loadMessages(String workoutType) async {
    try {
      final filePath = await _getFilePath(workoutType);
      final file = File(filePath);

      if (!await file.exists()) {
        return [];
      }

      String contents = await file.readAsString();
      List<dynamic> jsonData = jsonDecode(contents);

      return jsonData.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteMessages(String workoutType) async {
    final filePath = await _getFilePath(workoutType);
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
