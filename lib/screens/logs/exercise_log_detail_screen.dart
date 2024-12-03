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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFeedbackFetched) {
      _checkMissingSetData(); // 세트 수와 무게가 없는지 확인
      if (!_isSetDataMissing) { // 세트 수와 무게가 모두 있는 경우에만 피드백 요청
        _fetchChatBotFeedback();
      }
      _isFeedbackFetched = true;
    }
  }

  // 세트 데이터 체크 메서드
  void _checkMissingSetData() {
    bool hasMissingSetData = false;

    // 세트 수와 무게가 누락된 경우 체크
    for (var set in widget.exercise.sets) {
      if (set['weight'] == null || set['reps'] == null) {
        hasMissingSetData = true;
        break;
      }
    }

    setState(() {
      _isSetDataMissing = hasMissingSetData; // 세트 데이터가 없으면 true
      _feedbackError = _isSetDataMissing
          ? 'Please enter both the number of sets and the weight.'
          : ''; // 세트 수와 무게가 없으면 에러 메시지
    });
  }

  // 챗봇 피드백 요청 메서드
  Future<void> _fetchChatBotFeedback() async {
    if (_isSetDataMissing) {
      return; // 세트 수와 무게가 없으면 피드백 요청을 하지 않음
    }

    setState(() {
      _isLoading = true;
      _feedbackError = ''; // 에러 메시지 초기화
    });

    final userDataService = Provider.of<UserDataService>(context, listen: false);

    // 사용자의 프로필 데이터가 없으면 에러 메시지 표시
    if (userDataService.profileUserDataList.isEmpty) {
      setState(() {
        _feedbackError = 'Please enter your weight and body fat percentage in the profile screen.';
        _isLoading = false;
      });
      return;
    }

    final latestUserData = userDataService.profileUserDataList.last;
    final weight = latestUserData.weight;
    final bodyFat = latestUserData.bodyFat;

    // 운동 세트 정보 구성
    String exerciseDetails = '';
    for (int i = 0; i < widget.exercise.sets.length; i++) {
      final set = widget.exercise.sets[i];
      exerciseDetails += 'Set ${i + 1}: ${set['weight']} kg x ${set['reps']} reps\n';
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
        _feedbackError = 'An error occurred while communicating with the ChatBot: $e';
        _isLoading = false;
      });
    }
  }

  /// 피드백 요약 메서드
  String _summarizeFeedback(String feedback) {
    final lines = feedback.split('\n');
    if (lines.length > 5) {
      return '${lines.take(5).join('\n')}';
    }
    return feedback;
  }

  /// 챗봇 피드백을 보여주는 위젯
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
      // 에러 메시지가 있으면 오류 메시지 카드 표시
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
      // 피드백이 없다면 빈 공간 반환
      return const SizedBox.shrink();
    }

    // 피드백이 있으면 요약 및 확장 기능 제공
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

  // 세트 수나 무게가 없으면 "No Feedback" 카드 표시
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
                ? 'Please set the number of sets and weight for the exercise before viewing feedback.'
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
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
                subtitle: Text(
                  '${set['weight']} kg x ${set['reps']} reps',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                trailing: const Icon(
                  Icons.fitness_center,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),

          // 세트 수나 무게가 없으면 No Feedback 메시지 표시
          if (_isSetDataMissing) _buildNoFeedbackMessage()
          else // 피드백 표시
            _buildChatBotFeedback(),

        ],
      ),
    );
  }
}
