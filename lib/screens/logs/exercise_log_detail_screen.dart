// lib/screens/logs/exercise_log_detail_screen.dart

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
  // 챗봇 피드백 저장 변수
  String _chatBotFeedback = '';
  bool _isLoading = false; // 로딩 상태
  bool _isFeedbackFetched = false; // 피드백 요청 여부 플래그

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFeedbackFetched) {
      _fetchChatBotFeedback();
      _isFeedbackFetched = true;
    }
  }

  /// 챗봇 피드백 요청 메서드
  Future<void> _fetchChatBotFeedback() async {
    setState(() {
      _isLoading = true;
    });


    final userDataService = Provider.of<UserDataService>(context, listen: false);

    // 프로필 데이터 리스트에서 최신 데이터 가져오기
    if (userDataService.profileUserDataList.isEmpty) {
      _showSnackBar('프로필 화면에서 몸무게와 체지방률을 입력해 주세요.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final latestUserData = userDataService.profileUserDataList.last;
    final weight = latestUserData.weight;
    final bodyFat = latestUserData.bodyFat;

    // 운동 세부 정보 구성
    String exerciseDetails = '';
    for (int i = 0; i < widget.exercise.sets.length; i++) {
      final set = widget.exercise.sets[i];
      exerciseDetails +=
      'Set ${i + 1}: ${set['weight']} kg x ${set['reps']} reps\n';
    }

    // 챗봇에게 보낼 프롬프트 구성
    String prompt = '''
다음 정보를 바탕으로 운동에 대한 피드백을 제공해주세요:

몸무게: $weight kg
체지방률: $bodyFat%

운동 정보:
${widget.exercise.name}
$exerciseDetails

이 운동이 사용자의 목표에 얼마나 도움이 되는지, 개선할 점이 있는지 피드백을 부탁드립니다.
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
      _showSnackBar('챗봇 피드백을 가져오는 중 오류가 발생했습니다: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 스낵바 표시 메서드
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 챗봇 피드백 표시 위젯
  Widget _buildChatBotFeedback() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chatBotFeedback.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.grey[80],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _chatBotFeedback,
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
        title: Text(
          widget.exercise.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 운동 이름만 표시 (description 제거)
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

          // 세트 리스트
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

          // 챗봇 피드백 표시
          _buildChatBotFeedback(),
        ],
      ),
    );
  }
}
