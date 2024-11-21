// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/meal_log.dart'; // MealLog 임포트
import '../../models/consumed_food.dart'; // ConsumedFood 임포트
import '../../models/exercise_log.dart';
import '../../services/exercise_log_storage_service.dart';
import '../logs/diet_log_screen.dart';
import '../logs/exercise_log_detail_screen.dart';

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

  Map<String, Map<String, MealLog>> _dietLogsByDate = {};
  Map<String, MealLog>? _selectedDayDietLog;

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
            (meals as Map<String, dynamic>).map((meal, log) {
              return MapEntry(
                meal,
                MealLog.fromJson(log),
              );
            }),
          );
        }).cast<String, Map<String, MealLog>>();

        String dateKey = _selectedDay.toIso8601String().split('T')[0];
        _selectedDayDietLog = _dietLogsByDate[dateKey];
      });
    } else {
      setState(() {
        _dietLogsByDate = {};
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

  void _navigateToDietLogScreen() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => DietLogScreen(selectedDay: _selectedDay),
      ),
    )
        .then((_) {
      // 돌아왔을 때 데이터 새로고침
      _loadDietLogForSelectedDay();
    });
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
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                String dateKey = _getDateKey(date);
                if (_dietLogsByDate.containsKey(dateKey)) {
                  final mealLogs = _dietLogsByDate[dateKey]!;
                  List<Widget> indicators = [];
                  mealLogs.forEach((meal, log) {
                    if (log.isSkipped) {
                      // Do not show marker for skipped meals
                      // Alternatively, you can show a different marker if needed
                    } else if (log.foods.isNotEmpty) {
                      indicators.add(
                        const Icon(Icons.check, color: Colors.green, size: 12),
                      );
                    }
                  });
                  if (indicators.isNotEmpty) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: indicators,
                    );
                  }
                }
                return null;
              },
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Row(
              children: [
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
                            ? _buildFilteredDietLogSections()
                            : Center(
                          child: ElevatedButton(
                            onPressed: _navigateToDietLogScreen,
                            child: const Text('Add/Edit Diet'),
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

  String _getDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0]; // 'YYYY-MM-DD' 형식
  }

  /// Builds the diet log sections excluding skipped meals
  Widget _buildFilteredDietLogSections() {
    // List of meals to display
    final List<String> meals = ['Breakfast', 'Lunch', 'Dinner'];

    // Filter out the meals that are skipped
    final List<String> displayedMeals = meals.where((meal) {
      final mealLog = _selectedDayDietLog![meal];
      return mealLog != null && !mealLog.isSkipped;
    }).toList();

    if (displayedMeals.isEmpty) {
      // If all meals are skipped
      return Center(
        child: ElevatedButton(
          onPressed: _navigateToDietLogScreen,
          child: const Text('Add/Edit Diet'),
        ),
      );
    }

    return ListView(
      children: displayedMeals.map((meal) => _buildMealSection(meal)).toList(),
    );
  }

  Widget _buildMealSection(String meal) {
    final mealLog = _selectedDayDietLog![meal]!;
    final foods = mealLog.foods;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal name and edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: _navigateToDietLogScreen,
                ),
              ],
            ),
            // Foods list
            foods.isNotEmpty
                ? Column(
              children: foods.map((consumed) {
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 2.0),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // Food name
                      Text(
                        consumed.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Nutrient information
                      Text(
                        'Amount: ${consumed.quantity.toStringAsFixed(1)}g\n'
                            'Carbs: ${consumed.carbs.toStringAsFixed(1)}g\n'
                            'Protein: ${consumed.protein.toStringAsFixed(1)}g\n'
                            'Fat: ${consumed.fat.toStringAsFixed(1)}g',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
                : const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'No foods added.',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
