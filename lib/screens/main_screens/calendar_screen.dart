import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/exercise_log.dart';
import '../../services/exercise_log_storage_service.dart';
import '../logs/diet_log_screen.dart';
import '../logs/exercise_log_detail_screen.dart';

// 만약 ConsumedFood 클래스가 별도의 파일에 있다면 임포트
// import '../../models/consumed_food.dart';

// 없으면 클래스 정의 추가
class ConsumedFood {
  final String name;
  final double carbs;
  final double protein;
  final double fat;
  final double quantity; // 단위: 그램 (섭취량)

  ConsumedFood({
    required this.name,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.quantity,
  });

  // JSON 직렬화 메서드
  Map<String, dynamic> toJson() => {
    'name': name,
    'carbs': carbs,
    'protein': protein,
    'fat': fat,
    'quantity': quantity,
  };

  factory ConsumedFood.fromJson(Map<String, dynamic> json) {
    return ConsumedFood(
      name: json['name'],
      carbs: json['carbs'],
      protein: json['protein'],
      fat: json['fat'],
      quantity: json['quantity'],
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final ExerciseLogStorageService _logStorageService =
  ExerciseLogStorageService();
  ExerciseLog? _selectedDayExerciseLog;

  // 식단 로그 관련 변수
  Map<String, Map<String, List<ConsumedFood>>> _dietLogsByDate = {};
  Map<String, List<ConsumedFood>>? _selectedDayDietLog;

  @override
  void initState() {
    super.initState();
    _loadExerciseLogForSelectedDay();
    _loadDietLogForSelectedDay();
  }

  void _loadExerciseLogForSelectedDay() async {
    ExerciseLog? log =
    await _logStorageService.loadExerciseLogByDate(_selectedDay);
    setState(() {
      _selectedDayExerciseLog = log;
    });
  }

  void _loadDietLogForSelectedDay() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('dietLogs');
    if (data != null) {
      Map<String, dynamic> jsonData = jsonDecode(data);
      setState(() {
        _dietLogsByDate = jsonData.map((date, meals) {
          return MapEntry(
            date,
            (meals as Map<String, dynamic>).map((meal, foods) {
              List<ConsumedFood> consumedFoods = (foods as List<dynamic>)
                  .map((food) => ConsumedFood.fromJson(food))
                  .toList();
              return MapEntry(meal, consumedFoods);
            }),
          );
        }).cast<String, Map<String, List<ConsumedFood>>>();

        String dateKey = _selectedDay.toIso8601String().split('T')[0];
        _selectedDayDietLog = _dietLogsByDate[dateKey];
      });
    } else {
      setState(() {
        _selectedDayDietLog = null;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _loadExerciseLogForSelectedDay();
    _loadDietLogForSelectedDay();
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Row(
              children: [
                // 운동 기록 섹션
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Workout Log',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: _selectedDayExerciseLog != null &&
                            _selectedDayExerciseLog!.exercises.isNotEmpty
                            ? ListView.builder(
                          itemCount:
                          _selectedDayExerciseLog!.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise =
                            _selectedDayExerciseLog!.exercises[index];
                            return ListTile(
                              title: Text(
                                exercise.name,
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ExerciseLogDetailScreen(
                                          exercise: exercise,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                            : const Center(
                          child: Text('No workout log for this day'),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // 식단 기록 섹션
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Diet Log',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: _selectedDayDietLog != null
                            ? ListView(
                          children: [
                            _buildMealSection('Breakfast'),
                            _buildMealSection('Lunch'),
                            _buildMealSection('Dinner'),
                          ],
                        )
                            : Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) => DietLogScreen(
                                    selectedDay: _selectedDay,
                                  ),
                                ),
                              )
                                  .then((_) {
                                // 돌아왔을 때 데이터 새로고침
                                _loadDietLogForSelectedDay();
                              });
                            },
                            child: const Text('Add Diet'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String meal) {
    final foods = _selectedDayDietLog![meal];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        children: [
          // 식사명 표시
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              meal,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // 섭취한 음식 목록 표시
          if (foods != null && foods.isNotEmpty)
            ...foods.map((consumed) {
              return ListTile(
                title: Text(consumed.name),
                subtitle: Text(
                    'Amount: ${consumed.quantity.toStringAsFixed(1)}g\nCarbs: ${consumed.carbs.toStringAsFixed(1)}g, Protein: ${consumed.protein.toStringAsFixed(1)}g, Fat: ${consumed.fat.toStringAsFixed(1)}g'),
              );
            }).toList()
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No foods added.'),
            ),
        ],
      ),
    );
  }
}
