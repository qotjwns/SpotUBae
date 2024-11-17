import 'package:flutter/material.dart';
import 'package:group_app/widgets/button_widget.dart';
import '../../models/message.dart';
import '../../services/api_service.dart';
import '../../storage_service.dart';
import '../workout_selection_screen.dart';


class ChatBotScreen extends StatefulWidget {
  final String workoutType;  // 운동 부위 (예: chest, back, shoulder 등)

  const ChatBotScreen({super.key, required this.workoutType});

  @override
  ChatBotScreenState createState() => ChatBotScreenState();
}

class ChatBotScreenState extends State<ChatBotScreen> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final StorageService _storageService = StorageService();
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
    _loadExercises();  // 운동 종목을 불러오는 함수 호출
  }

  Future<void> _loadMessages() async {
    List<Message> loadedMessages = await _storageService.loadMessages(widget.workoutType);
    setState(() {
      _messages.addAll(loadedMessages);
    });

    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  Future<void> _loadExercises() async {
    // 운동 부위에 맞는 운동 종목을 불러오기
    List<String> loadedExercises = await _storageService.loadExercisesFromDownload(widget.workoutType);

    if (loadedExercises.isNotEmpty) {
      setState(() {
        _messages.add(Message(
          role: 'assistant',
          content: "Loaded exercises: ${loadedExercises.join(", ")}",
          timestamp: DateTime.now(),
        ));
      });
    } else {
      setState(() {
        _messages.add(Message(
          role: 'assistant',
          content: "$widget.workoutType 운동 종목 파일이 존재하지 않습니다.",
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = Message(
      content: '${widget.workoutType} Welcome to the Chatbot! Ask some workout-related questions.',
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

      handleWorkoutResponse(botResponse, widget.workoutType);  // 운동 종목 처리
    } catch (e) {
      if (mounted) {
        setState(() {
          _addErrorMessage('Problem with the chatbot response: $e');
        });
      }
    }
  }

  void handleWorkoutResponse(String response, String workoutType) async {
    final StorageService storageService = StorageService();

    // 운동 종목 추출
    List<String> matchingExercises = storageService.extractMatchingExercises(response);

    if (matchingExercises.isNotEmpty) {
      // 겹치는 운동 종목 저장
      await storageService.saveExercisesToDownload(matchingExercises, workoutType);
      print("$workoutType 운동 종목이 성공적으로 저장되었습니다.");
    } else {
      print("$workoutType 운동 종목 추출 실패! 응답 내용: $response");
    }

    // recommendation 운동 종목 저장
    if (workoutType == "recommendation") {
      // recommendation 운동 종목을 별도로 저장할 경우
      await storageService.saveExercisesToDownload(matchingExercises, "recommendation");
      print("recommendation 운동 종목이 성공적으로 저장되었습니다.");
    }
  }

  void _saveMessages() {
    _storageService.saveMessages(widget.workoutType, _messages);  // 운동 부위별로 메시지 저장
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
          return ButtonWidget(
            onPressed: () => _sendPredefinedMessage(message),
            label: message,
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
      'Chatting reset',
      'Are you sure you want to delete all your chat?',
    );

    if (confirm) {
      await _storageService.deleteMessages(widget.workoutType);
      setState(() {
        _messages.clear();
        _addWelcomeMessage();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chatting has been reset.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.workoutType} Chatbot'),
        actions: [
          IconButton(onPressed: _resetChat, icon: Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.fitness_center),
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
}
