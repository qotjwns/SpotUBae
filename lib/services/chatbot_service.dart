// lib/services/chatbot_service.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotService with ChangeNotifier {
  final String apiKey;

  ChatBotService({required this.apiKey});

  /// 챗봇에게 프롬프트를 보내고 응답을 받는 메서드
  Future<String> sendPrompt(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "gpt-4",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": prompt},
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return '챗봇과의 통신에 실패했습니다. 상태 코드: ${response.statusCode}';
      }
    } catch (e) {
      return '챗봇과의 통신 중 오류가 발생했습니다: $e';
    }
  }
}
