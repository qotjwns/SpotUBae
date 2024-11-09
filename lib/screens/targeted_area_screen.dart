import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        toolbarHeight: 80,
        title: const Text(
          "Select body part",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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
                _buildWorkoutCard(context, "CHEST", FontAwesomeIcons.dumbbell, cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "BACK", FontAwesomeIcons.dumbbell, cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "SHOULDER", FontAwesomeIcons.dumbbell, cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "LEGS", FontAwesomeIcons.running, cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "ARMS", FontAwesomeIcons.handRock, cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "ABS", FontAwesomeIcons.bullseye, cardWidth),
                const SizedBox(height: 24),
                _buildWorkoutCard(context, "CARDIO", FontAwesomeIcons.heartbeat, cardWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, String label, IconData icon, double width) {
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
              FaIcon(icon, size: 24), // 아이콘 크기 축소
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

