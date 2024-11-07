import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../constants/api_constants.dart';

class ApiService {
  final String apiKey;

  ApiService({required this.apiKey});

  Future<String> sendMessage(List<Message> messages) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': ApiConstants.modelName,
        'messages': messages.map((msg) => msg.toApiJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}
