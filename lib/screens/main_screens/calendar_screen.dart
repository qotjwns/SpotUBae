import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // 추가
import '../../models/exercise_log.dart'; // 추가
import '../../services/exercise_log_storage_service.dart'; // 추가
import '../logs/diet_log_screen.dart';
import '../logs/exercise_log_detail_screen.dart'; // 운동 기록 상세 화면 추가

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final ExerciseLogStorageService _logStorageService = ExerciseLogStorageService();
  ExerciseLog? _selectedDayExerciseLog;

  @override
  void initState() {
    super.initState();
    _loadExerciseLogForSelectedDay();
  }

  void _loadExerciseLogForSelectedDay() async {
    ExerciseLog? log =
    await _logStorageService.loadExerciseLogByDate(_selectedDay);
    setState(() {
      _selectedDayExerciseLog = log;
    });
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
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadExerciseLogForSelectedDay();
            },
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
                              title: Text(exercise.name),
                              subtitle: Text(
                                  'Sets: ${exercise.sets.length}'),
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
                            : Center(
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
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DietLogScreen(
                                      selectedDay: _selectedDay),
                                ),
                              );
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
}