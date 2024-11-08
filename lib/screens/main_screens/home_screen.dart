import 'package:flutter/material.dart';
import 'package:group_app/screens/targeted_area_screen.dart';
import '../../widgets/table_cell_content.dart';
import '../../widgets/button_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String? _dailyGoal;
  String? _weeklyGoal;
  String? _monthlyGoal;

  void _addGoal(String goalType) {
    TextEditingController _goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$goalType 추가'),
        content: TextField(
          controller: _goalController,
          decoration: const InputDecoration(hintText: '목표를 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (goalType == '오늘의 목표') {
                  _dailyGoal = _goalController.text;
                } else if (goalType == '주간 목표') {
                  _weeklyGoal = _goalController.text;
                } else if (goalType == '월간 목표') {
                  _monthlyGoal = _goalController.text;
                }
              });
              Navigator.of(context).pop();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, // 폰트 크기 조정
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ButtonWidget(
                label: "운동 선택하기",
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TargetedAreaScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Table(
                border: TableBorder.all(
                  width: 2,
                  color: Colors.grey.shade400,
                  style: BorderStyle.solid,
                ),
                children: [
                  TableRow(
                    children: [
                      TableCellContent(
                        text: '오늘의 목표',
                        goal: _dailyGoal,
                        onAddGoal: () => _addGoal('오늘의 목표'),
                      ),
                      TableCellContent(
                        text: '주간 목표',
                        goal: _weeklyGoal,
                        onAddGoal: () => _addGoal('주간 목표'),
                      ),
                      TableCellContent(
                        text: '월간 목표',
                        goal: _monthlyGoal,
                        onAddGoal: () => _addGoal('월간 목표'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}