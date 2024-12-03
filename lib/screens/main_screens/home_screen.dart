// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_app/screens/make_routine_screens/targeted_area_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/program_user_data.dart';
import '../program_screen/program_screen.dart';
import '../../services/user_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void _addOrEditGoal(String goalType, [String? currentGoal]) {
    TextEditingController goalController =
        TextEditingController(text: currentGoal);

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
          child: Consumer< UserDataService>(
            builder:
                (context, userDataService, child) {
                  String? currentProgramType = userDataService.currentProgramType;
                  ProgramUserData? currentProgramData;
                  if (currentProgramType == 'Bulking') {
                    currentProgramData = userDataService.bulkingProgramData;
                  } else if (currentProgramType == 'Cutting') {
                    currentProgramData = userDataService.cuttingProgramData;
                  }
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TargetedAreaScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      minimumSize: Size(200, 70),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 텍스트 스타일
                    ),
                    child: Text("Start Workout"),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),
                  const Text(
                    "Set Your Goals",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  // "Your Goal" 카드 추가
                  Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: currentProgramData != null
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Your Goal (${currentProgramType!})',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Goal Weight: ${currentProgramData.goalWeight} kg',
                            style: const TextStyle(fontSize: 25,
                              fontWeight: FontWeight.bold,),
                          ),
                          Text(
                            'Goal Body Fat: ${currentProgramData.goalBodyFat}%',
                            style: const TextStyle(fontSize: 25,
                              fontWeight: FontWeight.bold,),
                          ),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Start Bulking/Cutting program\n           '
                                'to reach your Goal!',
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Push yourself to the limit!',
                            style: const TextStyle(fontSize: 20,
                            fontWeight: FontWeight.bold,),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'GO TO THE F\'CKING GYM',
                            style: const TextStyle(fontSize: 10,
                              fontWeight: FontWeight.bold,),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // 간격 추가
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          // Bulking 선택 시 흰색, 아니면 검은색
                          minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.4,
                              50), // 버튼 크기 설정
                        ),
                        onPressed: () async {
                          // 프로그램 타입 설정
                          await userDataService.setCurrentProgramType('Bulking');
                          // ProgramScreen으로 이동

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProgramScreen(programType: 'Bulking'),
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
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.4, 50),
                        ),
                        onPressed: () async {
                          await userDataService.setCurrentProgramType('Cutting');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProgramScreen(programType: 'Cutting'),
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
