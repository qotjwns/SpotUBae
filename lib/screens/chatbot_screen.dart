import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/chat_bot_storage_service.dart';
import 'make_my_routine_screen.dart';

class ChatBotScreen extends StatefulWidget {
  final String workoutType;

  const ChatBotScreen({super.key, required this.workoutType});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
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
    'for expert'
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(
        apiKey: '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');
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
      content: '${widget.workoutType} 챗봇에 오신 것을 환영합니다! 운동 관련 질문을 해보세요.',
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
                  child: const Text('예'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: const Text('아니오'),
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

  void _navigateToMakeMyRoutine() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MakeMyRoutineScreen(),
      ),
    );
  }
  void _resetChat() async {
    bool confirm = await _showConfirmationDialog(
      context,
      '채팅 초기화',
      '채팅 내용을 모두 삭제하시겠습니까?',
    );

    if (confirm) {
      await _storageService.deleteMessages(widget.workoutType);
      setState(() {
        _messages.clear();
        _addWelcomeMessage();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅이 초기화되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workoutType} 챗봇'),
        actions: [
          IconButton(onPressed: _resetChat, icon: Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: _navigateToMakeMyRoutine,
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
}
