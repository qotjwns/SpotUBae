// chat_bot_screen.dart

import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../make_routine_screens/workout_selection_screen.dart';
import 'package:provider/provider.dart';

class ChatBotScreen extends StatefulWidget {
  final String workoutType;  // 운동 부위 (예: chest, back, shoulder 등)

  const ChatBotScreen({super.key, required this.workoutType});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late ApiService _apiService;

  bool _isLoading = false;

  final List<String> _predefinedMessages = [
    'for beginner',
    'for pre-intermediate',
    'for intermediate',
    'for upper-intermediate',
    'for expert'
  ];

  late StorageService _storageService;

  bool _isInit = false; // 초기화 여부 확인

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _storageService = Provider.of<StorageService>(context);
      _apiService = ApiService(
          apiKey: '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'); // 실제 API 키로 대체하세요
      _loadMessages();
      _isInit = true;
    }
  }

  Future<void> _loadMessages() async {
    List<Message> loadedMessages = await _storageService.loadMessages(widget.workoutType.toLowerCase());
    setState(() {
      _messages.addAll(loadedMessages);
    });
  }


  void _sendPredefinedMessage(String messageContent) {
    final userMessage = Message(
      role: 'user',
      content:
      "A set of events for $messageContent ${widget.workoutType} exercise routines, repeat the number of repetitions, and just summarize the break time. Take out what you don't need in the middle, note, introduction",
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();
    _saveMessages();

    _callChatBotAPI();
  }

  void _callChatBotAPI() async {
    try {
      final botResponse = await _apiService.sendMessage(_messages);
      if (mounted) {
        setState(() {
          final botMessage = Message(
            role: 'assistant',
            content: botResponse,
            timestamp: DateTime.now(),
          );
          _messages.add(botMessage);
          _isLoading = false;
        });
      }

      handleWorkoutResponse(botResponse, widget.workoutType.toLowerCase());  // 운동 종목 처리
    } catch (e) {
      if (mounted) {
        setState(() {
          _addErrorMessage('There was a problem with the chatbot response: $e');
        });
      }
    }
  }

  void handleWorkoutResponse(String response, String workoutType) async {
    // 운동 종목 추출
    List<String> matchingExercises = _storageService.extractMatchingExercises(response, workoutType);

    if (matchingExercises.isNotEmpty) {
      // 운동 종목 저장 (해당 부위) - append
      await _storageService.addExercisesToDownload(matchingExercises, workoutType);
      print("$workoutType 운동 종목이 성공적으로 추가되었습니다.");

      // recommendation 운동 종목 저장 (항상 "recommendation"으로 저장) - append
      await _storageService.addExercisesToDownload(matchingExercises, "recommendation");
      print("recommendation 운동 종목이 성공적으로 추가되었습니다.");
    } else {
      print("$workoutType 운동 종목 추출 실패! 응답 내용: $response");
    }
  }

  void _saveMessages() {
    _storageService.saveMessages(widget.workoutType.toLowerCase(), _messages);  // 운동 부위별로 메시지 저장
  }

  void _addErrorMessage(String error) {
    final errorMessage = Message(
      role: 'assistant',
      content: error,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(errorMessage);
    });

    _saveMessages();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildPredefinedMessages() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _predefinedMessages.map((message) {
          return ElevatedButton(
            onPressed: () => _sendPredefinedMessage(message),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
            ),
            child: Text(message),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessage(Message message) {
    return Align(
      alignment:
      message.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
          message.role == 'user' ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.role == 'user' ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToWorkoutSelectionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WorkoutSelectionScreen(),
      ),
    );
  }

  void _resetChat() async {
    bool confirm = await _showConfirmationDialog(
      context,
      'Reset Chat',
      'Do you want to delete all chat messages?',
    );

    if (confirm) {
      await _storageService.deleteMessages(widget.workoutType.toLowerCase());
      setState(() {
        _messages.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat has been reset.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_capitalize(widget.workoutType)} Workout Chatbot'),
        actions: [
          IconButton(onPressed: _resetChat, icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _navigateToWorkoutSelectionScreen,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          _buildPredefinedMessages(),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}
