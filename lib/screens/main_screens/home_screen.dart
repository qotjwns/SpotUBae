import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_app/screens/targeted_area_screen.dart';
import 'package:intl/intl.dart';
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

  bool get _allGoalsSet => _dailyGoal != null && _weeklyGoal != null && _monthlyGoal != null;

  void _addOrEditGoal(String goalType, [String? currentGoal]) {
    TextEditingController _goalController = TextEditingController(text: currentGoal);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $goalType'),
        content: TextField(
          controller: _goalController,
          decoration: const InputDecoration(hintText: 'Input your goal'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (goalType == "Today's Goal") {
                  _dailyGoal = _goalController.text;
                } else if (goalType == 'Weekly Goal') {
                  _weeklyGoal = _goalController.text;
                } else if (goalType == 'Monthly Goal') {
                  _monthlyGoal = _goalController.text;
                }
              });
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
        toolbarHeight: 100,
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
          child: Column(
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
              // 목표가 추가되면 Start Workout 버튼 위에 표시
              if (_dailyGoal != null || _weeklyGoal != null || _monthlyGoal != null)
                Column(
                  children: [
                    if (_dailyGoal != null)
                      GoalCard(
                        goalType: "Today's Goal",
                        goal: _dailyGoal,
                        onEdit: () => _addOrEditGoal("Today's Goal", _dailyGoal),
                      ),
                    if (_weeklyGoal != null)
                      GoalCard(
                        goalType: 'Weekly Goal',
                        goal: _weeklyGoal,
                        onEdit: () => _addOrEditGoal('Weekly Goal', _weeklyGoal),
                      ),
                    if (_monthlyGoal != null)
                      GoalCard(
                        goalType: 'Monthly Goal',
                        goal: _monthlyGoal,
                        onEdit: () => _addOrEditGoal('Monthly Goal', _monthlyGoal),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
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
              // 모든 목표가 설정되지 않은 경우에만 목표 설정 부분 표시
              if (!_allGoalsSet) ...[
                const Divider(),
                const SizedBox(height: 30),
                const Text(
                  "Set Your Goals",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                if (_dailyGoal == null)
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Today's Goal"),
                      subtitle: const Text("No goal yet"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditGoal("Today's Goal"),
                      ),
                    ),
                  ),
                if (_weeklyGoal == null)
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Weekly Goal"),
                      subtitle: const Text("No goal yet"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditGoal('Weekly Goal'),
                      ),
                    ),
                  ),
                if (_monthlyGoal == null)
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: const Text("Monthly Goal"),
                      subtitle: const Text("No goal yet"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditGoal('Monthly Goal'),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final String goalType;
  final String? goal;
  final VoidCallback onEdit;

  const GoalCard({
    required this.goalType,
    required this.goal,
    required this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(goalType, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(goal ?? "No goal set"),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit, // 목표 편집 가능하게 수정
        ),
      ),
    );
  }
}
