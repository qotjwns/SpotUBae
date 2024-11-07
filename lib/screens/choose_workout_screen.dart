import 'package:flutter/material.dart';
import '../widgets/button_widget.dart';
import 'chatbot_screen.dart';

class ChooseWorkoutScreen extends StatelessWidget {
  const ChooseWorkoutScreen({super.key});

  void _navigateToChatBot(BuildContext context, String workoutType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatBotScreen(workoutType: workoutType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("운동 선택"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ButtonWidget(
                  label: "CHEST",
                  onPressed: () {
                    _navigateToChatBot(context, "CHEST");
                  },
                  width: 150,
                  height: 50,
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                  label: "BACK",
                  onPressed: () {
                    _navigateToChatBot(context, "BACK");
                  },
                  width: 150,
                  height: 50,
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                  label: "SHOULDER",
                  onPressed: () {
                    _navigateToChatBot(context, "SHOULDER");
                  },
                  width: 150,
                  height: 50,
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                  label: "LEGS",
                  onPressed: () {
                    _navigateToChatBot(context, "LEGS");
                  },
                  width: 150,
                  height: 50,
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                  label: "ARMS",
                  onPressed: () {
                    _navigateToChatBot(context, "ARMS");
                  },
                  width: 150,
                  height: 50,
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                  label: "ABS",
                  onPressed: () {
                    _navigateToChatBot(context, "ABS");
                  },
                  width: 150,
                  height: 50,
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                  label: "CARDIO",
                  onPressed: () {
                    _navigateToChatBot(context, "CARDIO");
                  },
                  width: 150,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
