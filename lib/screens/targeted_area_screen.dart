import 'package:flutter/material.dart';
import 'chatbot/chatbot_screen.dart';

class TargetedAreaScreen extends StatelessWidget {
  const TargetedAreaScreen({super.key});

  void _navigateToChatBot(BuildContext context, String workoutType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatBotScreen(workoutType: workoutType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, // 기본 높이보다 크게 설정 (필요에 따라 조정)
        centerTitle: true, // 제목을 중앙에 배치
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0), // 제목을 아래로 내리기 위한 상단 패딩 (필요에 따라 조정)
          child: Text(
            'Select Body part',
            style: TextStyle(
              fontSize: 36, // 텍스트 크기 조정 (필요에 따라 조정)
              fontWeight: FontWeight.bold, // 텍스트 두께 조정
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Choose a body part to target in your workout",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // 각 카드의 높이를 줄이기 위한 변경 사항 적용
                _buildWorkoutCard(context, "CHEST", 'assets/images/chest.png', cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "BACK", 'assets/images/back.png', cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "SHOULDER", 'assets/images/shoulder.png', cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "LEGS", 'assets/images/legs.png', cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "ARMS", 'assets/images/arms.png', cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "ABS", 'assets/images/abs.png', cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "CARDIO", 'assets/images/cardio.png', cardWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, String label, String imagePath, double width) {
    return GestureDetector(
      onTap: () => _navigateToChatBot(context, label),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10), // 내부 패딩 축소
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 24, // 이미지 너비 조절
                height: 24, // 이미지 높이 조절
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18, // 텍스트 크기 축소
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16), // 화살표 아이콘 크기 축소
            ],
          ),
        ),
      ),
    );
  }
}
