// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_app/screens/targeted_area_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../widgets/button_widget.dart';
import '../../services/goal_manage_service.dart';
import '../../widgets/goal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void _addOrEditGoal(String goalType, [String? currentGoal]) {
    TextEditingController goalController = TextEditingController(text: currentGoal);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $goalType'),
        content: TextField(
          controller: goalController,
          decoration: const InputDecoration(hintText: 'Input your goal'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              String typeKey;
              if (goalType == "Today's Goal") {
                typeKey = 'daily';
              } else if (goalType == 'Weekly Goal') {
                typeKey = 'weekly';
              } else if (goalType == 'Monthly Goal') {
                typeKey = 'monthly';
              } else {
                typeKey = 'daily';
              }

              Provider.of<GoalManageService>(context, listen: false)
                  .setGoal(typeKey, goalController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SpotU',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(width: 20), // 텍스트와 아이콘 사이 간격
            FaIcon(
              FontAwesomeIcons.dumbbell,
              size: 40, // 아이콘 크기
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<GoalManageService>(
            builder: (context, goalManageService, child) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "TODAY's WORKOUT",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      todayDate,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 'Today's Goal'만 입력된 경우에만 버튼 위에 표시
                  if (goalManageService.dailyGoal != null)
                    GoalCard(
                      goalType: "Today's Goal",
                      goal: goalManageService.dailyGoal!.value,
                      onEdit: () => _addOrEditGoal("Today's Goal", goalManageService.dailyGoal!.value),
                      onReset: () => goalManageService.resetGoal('daily'), // 초기화 콜백
                    ),
                  const SizedBox(height: 30),
                  ButtonWidget(
                    label: "Start Workout",
                    width: MediaQuery.of(context).size.width * 0.8,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TargetedAreaScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                  const Divider(),
                  const SizedBox(height: 30),
                  const Text(
                    "Set Your Goals",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  // 일일 목표가 설정되지 않은 경우에만 표시
                  if (goalManageService.dailyGoal == null)
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: const Text("Today's Goal", style: TextStyle(fontWeight: FontWeight.bold),),
                        subtitle: const Text("No goal yet"),
                        trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _addOrEditGoal("Today's Goal"),
                            tooltip: 'Edit Today\'s Goal',
                        ),
                      ),
                    ),
                  // Weekly Goal
                  GoalCard(
                    goalType: "Weekly Goal",
                    goal: goalManageService.weeklyGoal?.value,
                    onEdit: () => _addOrEditGoal('Weekly Goal', goalManageService.weeklyGoal?.value),
                    onReset: () => goalManageService.resetGoal('weekly'), // 초기화 콜백
                  ),
                  // Monthly Goal
                  GoalCard(
                    goalType: "Monthly Goal",
                    goal: goalManageService.monthlyGoal?.value,
                    onEdit: () => _addOrEditGoal('Monthly Goal', goalManageService.monthlyGoal?.value),
                    onReset: () => goalManageService.resetGoal('monthly'), // 초기화 콜백
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
