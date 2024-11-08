import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/api_service.dart';
import '../../services/chat_bot_storage_service.dart';
import 'message_bubble.dart';
import 'predefined_messages.dart';

class ChatBotScreen extends StatefulWidget {
  final String workoutType;

  const ChatBotScreen({super.key, required this.workoutType});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ChatBotStorageService _storageService = ChatBotStorageService();
  late ApiService _apiService;

  bool _isLoading = false;

  final List<String> _predefinedMessages = [
    'for beginner',
    'for pre-intermediate',
    'for intermediate',
    'for upper-intermediate',
    'for expert',
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiKey: 'YOUR_API_KEY'); // 실제 API 키는 안전하게 관리하세요.
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    List<Message> loadedMessages =
    await _storageService.loadMessages(widget.workoutType);
    setState(() {
      _messages.addAll(loadedMessages);
    });

    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = Message(
      content:
      '${widget.workoutType} 챗봇에 오신 것을 환영합니다! 운동 관련 질문을 해보세요.',
      timestamp: DateTime.now(),
      role: 'assistant',
    );

    setState(() {
      _messages.add(welcomeMessage);
    });

    _saveMessages();
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
      final botMessage = Message(
        role: 'assistant',
        content: botResponse,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(botMessage);
      });

      _saveMessages();
      _scrollToBottom();
    } catch (e) {
      _addErrorMessage('챗봇 응답에 문제가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveMessages() {
    _storageService.saveMessages(widget.workoutType, _messages);
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


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          PredefinedMessages(
            predefinedMessages: _predefinedMessages,
            onMessageSelected: _sendPredefinedMessage,
          ),
        ],
      ),
    );
  }
}