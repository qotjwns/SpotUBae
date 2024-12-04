import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'package:provider/provider.dart';

class HowToChatbot extends StatefulWidget {
  final String workoutType;

  const HowToChatbot({super.key, required this.workoutType});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<HowToChatbot> {
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

  bool _isInit =
      false; // 초기화 여부 확인, OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _storageService = Provider.of<StorageService>(context);
      _apiService = ApiService(
          apiKey: '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');
      _loadMessages();
      _isInit = true;
    }
  }

  Future<void> _loadMessages() async {
    List<Message> loadedMessages =
        await _storageService.loadMessages(widget.workoutType.toLowerCase());
    setState(() {
      _messages.addAll(loadedMessages);
    });
  }

  void _sendPredefinedMessage(String messageContent) {
    final userMessage = Message(
      role: 'user',
      content: "$messageContent ${widget.workoutType}. How can i do?",
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _addErrorMessage('Please check your internet connection.');
        });
      }
    }
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  void _saveMessages() {
    _storageService.saveMessages(widget.workoutType.toLowerCase(), _messages);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_capitalize(widget.workoutType)} Chatbot'),
        actions: [
          IconButton(onPressed: _resetChat, icon: const Icon(Icons.refresh)),
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
