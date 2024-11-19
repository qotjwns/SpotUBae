import 'package:flutter/material.dart';
import 'package:group_app/services/storage_service.dart';

class ChatbotRecommendedScreen extends StatefulWidget {
  const ChatbotRecommendedScreen({super.key});

  @override
  State<ChatbotRecommendedScreen> createState() => _ChatbotRecommendedScreenState();
}

class _ChatbotRecommendedScreenState extends State<ChatbotRecommendedScreen> {
  List<String> _recommendedWorkouts = [];
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadRecommendedWorkouts();
  }

  Future<void> _loadRecommendedWorkouts() async {
    // 'workoutType'을 전달하여 운동 부위별 데이터를 불러옵니다.
    String workoutType = 'chest'; // 예시: 운동 부위는 `chest`로 설정
    List<String> workouts = await _storageService.loadExercisesFromDownload(workoutType);
    setState(() {
      _recommendedWorkouts = workouts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("챗봇 추천 운동 종목"),
      ),
      body: _recommendedWorkouts.isNotEmpty
          ? ListView.builder(
        itemCount: _recommendedWorkouts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_recommendedWorkouts[index]),
          );
        },
      )
          : const Center(
        child: Text("추천된 운동 종목이 없습니다."),
      ),
    );
  }
}
