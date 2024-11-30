// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_app/screens/make_routine_screens/targeted_area_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../widgets/button_widget.dart';
import '../../services/goal_manage_service.dart';
import '../../widgets/goal_card.dart';
import '../program_screen/program_screen.dart';
import '../../services/program_user_data_service.dart';

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
        toolbarHeight: 120, // AppBar의 높이 설정
        centerTitle: true, // 제목을 중앙에 배치
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0), // 제목을 아래로 내리기 위한 상단 패딩
          child: Row(
            mainAxisSize: MainAxisSize.min, // Row의 크기를 자식 위젯에 맞게 축소
            mainAxisAlignment: MainAxisAlignment.center, // Row 내부 위젯을 중앙에 정렬
            children: [
              Text(
                'SpotU',
                style: TextStyle(
                  fontSize: 50, // 텍스트 크기 조정
                  fontWeight: FontWeight.bold, // 텍스트 두께 조정
                ),
              ),
              SizedBox(width: 20), // 텍스트와 아이콘 사이 간격
              FaIcon(
                FontAwesomeIcons.dumbbell,
                size: 40, // 아이콘 크기 조정
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer2<GoalManageService, ProgramUserDataService>(
            builder: (context, goalManageService, programUserDataService, child)  {
              String? selectedProgramType = programUserDataService.currentProgramType;

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
                  const SizedBox(height: 20), // 간격 추가
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.black, // Bulking 선택 시 흰색, 아니면 검은색
                          minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 50), // 버튼 크기 설정
                        ),
                        onPressed: () async {
                          // 프로그램 타입 설정
                          await programUserDataService.setProgramType('Bulking');
                          // ProgramScreen으로 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProgramScreen(programType: 'Bulking'),
                            ),
                          );
                        },
                        child: const Text(
                          "Bulking",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:Colors.green,
                          foregroundColor: Colors.black,
                          minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
                        ),
                        onPressed: () async {
                          // 프로그램 타입 설정
                          await programUserDataService.setProgramType('Cutting');
                          // ProgramScreen으로 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProgramScreen(programType: 'Cutting'),
                            ),
                          );
                        },
                        child: const Text(
                          "Cutting",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
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
