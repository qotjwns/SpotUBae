import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../services/api_service.dart';
import '../../models/message.dart';
import '../../services/user_data_service.dart';

class ExerciseLogDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseLogDetailScreen({super.key, required this.exercise});

  @override
  ExerciseLogDetailScreenState createState() => ExerciseLogDetailScreenState();
}

class ExerciseLogDetailScreenState extends State<ExerciseLogDetailScreen> {
  String _chatBotFeedback = '';
  bool _isLoading = false; // 로딩 상태
  bool _isFeedbackFetched = false; // 피드백 요청 여부
  bool _isFeedbackExpanded = false; // 피드백 확장 상태
  bool _isSetDataMissing = false; // 세트 수와 무게가 없는지 확인하는 플래그
  String _feedbackError = ''; // 피드백 오류 메시지 저장
  //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFeedbackFetched) {
      _checkMissingSetData();
      if (!_isSetDataMissing) {
        _fetchChatBotFeedback();
      }
      _isFeedbackFetched = true;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  int _convertToSeconds(dynamic time) {
    if (time is int) {
      // 이미 초 단위라면 그대로 반환
      return time;
    } else if (time is Map<String, dynamic>) {
      // Map 형태인 경우 분과 초를 초 단위로 변환
      final minutes = time['minutes'] ?? 0;
      final seconds = time['seconds'] ?? 0;
      return (minutes * 60) + seconds;
    } else {
      throw ArgumentError('Invalid time format: $time');
    }
  }


  void _checkMissingSetData() {
    bool hasMissingSetData = false;
    if (widget.exercise.isCardio) {
      for (var set in widget.exercise.sets) {
        if (set['workoutTime'] == null || set['breakTime'] == null) {
          hasMissingSetData = true;
          break;
        }
      }
    } else {
      for (var set in widget.exercise.sets) {
        if (set['weight'] == null || set['reps'] == null || set['breakTime'] == null) {
          hasMissingSetData = true;
          break;
        }
      }
    }

    setState(() {
      _isSetDataMissing = hasMissingSetData;
      _feedbackError = _isSetDataMissing
          ? 'Please enter the required data for each set.'
          : '';
    });
  }

  // 챗봇 피드백 요청 메서드
  Future<void> _fetchChatBotFeedback() async {
    if (_isSetDataMissing) {
      return;
    }

    setState(() {
      _isLoading = true;
      _feedbackError = '';
    });

    final userDataService =
    Provider.of<UserDataService>(context, listen: false);

    if (userDataService.profileUserDataList.isEmpty) {
      setState(() {
        _feedbackError =
        'Please enter your weight and body fat percentage in the profile screen.';
        _isLoading = false;
      });
      return;
    }

    final latestUserData = userDataService.profileUserDataList.last;
    final weight = latestUserData.weight;
    final bodyFat = latestUserData.bodyFat;

    String exerciseDetails = '';
    for (int i = 0; i < widget.exercise.sets.length; i++) {
      final set = widget.exercise.sets[i];
      if (widget.exercise.isCardio) {
        exerciseDetails +=
        'Set ${i + 1}: ${_formatTime(_convertToSeconds(set['workoutTime']))} x Break Time: ${_formatTime(_convertToSeconds(set['breakTime']))}\n';
      } else {
        exerciseDetails +=
        'Set ${i + 1}: ${set['weight']} kg x ${set['reps']} reps x Break Time: ${_formatTime(_convertToSeconds(set['breakTime']))}\n';
      }
    }

    // 챗봇 요청을 위한 프롬프트 생성
    String prompt = '''
Please provide feedback based on the following information:

Weight: $weight kg
Body Fat: $bodyFat%

Exercise Info:
${widget.exercise.name}
$exerciseDetails

Please provide feedback on how this exercise contributes to the user's goals and any improvements they could make.
''';

    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      String response = await apiService.sendMessage([
        Message(role: 'system', content: 'You are a fitness assistant.'),
        Message(role: 'user', content: prompt),
      ]);

      setState(() {
        _chatBotFeedback = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _feedbackError = 'Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  String _summarizeFeedback(String feedback) {
    final lines = feedback.split('\n');
    if (lines.length > 5) {
      return lines.take(5).join('\n') + '...';
    }
    return feedback;
  }

  Widget _buildChatBotFeedback() {
    if (_isLoading) {
      // 로딩 중일 때
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.blue[50],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ChatBot Workout Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Creating feedback...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_feedbackError.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.orange[100],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _feedbackError,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_chatBotFeedback.isEmpty) {
      return const SizedBox.shrink();
    }

    String feedbackToDisplay = _isFeedbackExpanded
        ? _chatBotFeedback
        : _summarizeFeedback(_chatBotFeedback);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.green[50],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ChatBot Workout Feedback',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feedbackToDisplay,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (_chatBotFeedback.split('\n').length > 5)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFeedbackExpanded = !_isFeedbackExpanded; // 확장/축소 전환
                    });
                  },
                  child: Text(
                    _isFeedbackExpanded ? 'Collapse' : 'Show More',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoFeedbackMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.orange[100],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _isSetDataMissing
                ? 'Please set the required data for each set before viewing feedback.'
                : 'Please enter your weight and body fat percentage in the profile screen.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
        backgroundColor: Colors.transparent, // 배경 투명
        elevation: 0, // 그림자 제거
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 운동 이름 표시
          Text(
            widget.exercise.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 세트 목록 표시
          ...widget.exercise.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return Card(
              elevation: 3,
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  'Set ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: widget.exercise.isCardio
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Time: ${_formatTime(_convertToSeconds(set['workoutTime']))}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Break Time: ${_formatTime(_convertToSeconds(set['breakTime']))}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${set['weight']} kg x ${set['reps']} reps',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Break Time: ${_formatTime(_convertToSeconds(set['breakTime']))}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.fitness_center,
                  color: Colors.black,
                ),
              ),
            );
          }),
          if (_isSetDataMissing)
            _buildNoFeedbackMessage()
          else
            _buildChatBotFeedback(),
        ],
      ),
    );
  }
}
