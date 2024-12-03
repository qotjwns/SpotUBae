// lib/screens/logs/diet_log_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/message.dart';
import '../../models/program_user_data.dart';
import '../../services/api_service.dart';
import '../../models/consumed_food.dart'; // ConsumedFood import
import '../../services/food_service.dart';
import '../../widgets/widget_for_diet_log_screen/serving_size_dialog.dart';
import 'package:provider/provider.dart';
import '../program_screen/program_screen.dart';
import 'meal_log.dart'; // MealLog import
import '../../services/user_data_service.dart';

class DietLogScreen extends StatefulWidget {
  final DateTime selectedDay;

  const DietLogScreen({super.key, required this.selectedDay});

  @override
  DietLogScreenState createState() => DietLogScreenState();
}

class DietLogScreenState extends State<DietLogScreen> {
  // Change to Map<String, List<MealLog>> format
  Map<String, List<MealLog>> _dietLogsByDate = {};
  final FoodService _foodService = FoodService();

  List<MealLog> get _mealLogs {
    String dateKey = _getDateKey(widget.selectedDay);
    if (!_dietLogsByDate.containsKey(dateKey)) {
      _dietLogsByDate[dateKey] = [
        MealLog(), // First meal
        MealLog(), // Second meal
        MealLog(), // Third meal
      ];
    }
    return _dietLogsByDate[dateKey]!;
  }

  // **Added: Variable to store ChatBot response**
  String _chatBotResponse = '';
  bool _isFeedbackExpanded = false; // Feedback expansion state

  // Variables to store program data
  ProgramUserData? _currentProgramData;
  String? _currentProgramType; // Current program type

  // 챗봇 피드백을 초기화하는 함수 (앱 실행 시 체크)
  void _initializeChatBotFeedback() async {
    final prefs = await SharedPreferences.getInstance();

    // 앱 실행 시, 저장된 챗봇 피드백을 가져온다
    final storedResponse = prefs.getString('chatBotResponse_${_getDateKey(widget.selectedDay)}');

    // MealLog에 음식이 하나라도 있으면 피드백을 표시, 아니면 초기화
    bool isAnyMealWithFood = _mealLogs.any((mealLog) => mealLog.foods.isNotEmpty);

    if (isAnyMealWithFood) {
      // 음식이 있다면 이전에 저장된 챗봇 피드백을 로드
      setState(() {
        _chatBotResponse = storedResponse ?? '';  // 저장된 피드백을 불러오기
        _isFeedbackExpanded = false;  // 피드백 닫기
      });
    } else {
      // MealLog에 음식이 없으면 챗봇 피드백 초기화
      setState(() {
        _chatBotResponse = '';  // 피드백 초기화
        _isFeedbackExpanded = false;  // 피드백 닫기
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeChatBotFeedback();  // 앱 실행 시 챗봇 피드백 초기화
  }

  /// Load program data
  Future<void> _loadProgramData() async {
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    await userDataService.loadProgramUserData(); // Load program data

    // Determine the currently active program type.
    // Assuming either 'Bulking' or 'Cutting' is set.
    _currentProgramType = userDataService.currentProgramType;

    if (_currentProgramType == 'Bulking') {
      _currentProgramData = userDataService.bulkingProgramData;
    } else if (_currentProgramType == 'Cutting') {
      _currentProgramData = userDataService.cuttingProgramData;
    } else {
      _currentProgramData = null;
    }

    setState(() {}); // Update UI
  }

  /// Load ChatBot response
  Future<void> _loadChatBotResponse() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedResponse = prefs.getString('chatBotResponse_${_getDateKey(widget.selectedDay)}');
    if (savedResponse != null) {
      setState(() {
        _chatBotResponse = savedResponse;
      });
    }
  }

  String _getDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0]; // Format 'YYYY-MM-DD'
  }

  Future<void> _saveDietLogs() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(_dietLogsByDate.map((date, meals) {
      return MapEntry(
        date,
        meals.map((mealLog) => mealLog.toJson()).toList(),
      );
    }));
    await prefs.setString('dietLogs', data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diet logs saved successfully')),
    );

    // **Added: Request diet feedback from ChatBot**
    await _requestChatBotFeedback();
  }

  Future<void> _requestChatBotFeedback() async {
    bool isAnyMealWithFood = _mealLogs.any((mealLog) => mealLog.foods.isNotEmpty);
    if (!isAnyMealWithFood) {
      // MealLog에 음식이 없으면 피드백을 요청하지 않음
      if (mounted) {
        setState(() {
          _chatBotResponse = '';  // 피드백 초기화
        });
      }
      return;
    }

    // User Data 및 MealLog 정보를 사용해 챗봇 피드백 요청
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    if (userDataService.profileUserDataList.isEmpty) {
      _showSnackBar('Please enter your weight and body fat in the Profile screen.');
      return;
    }

    final latestUserData = userDataService.profileUserDataList.last;
    final weight = latestUserData.weight;
    final bodyFat = latestUserData.bodyFat;

    // Compose diet information based on remaining food items
    String dietDescription = '';
    for (int i = 0; i < _mealLogs.length; i++) {
      final meal = _mealLogs[i];
      if (meal.foods.isEmpty) continue;  // Skip empty meals
      dietDescription += 'Meal ${i + 1}:\n';
      for (var food in meal.foods) {
        dietDescription += '- ${food.name}: ${food.quantity}g\n';
      }
    }

    String prompt = 'Please provide feedback on the following diet based on the information below:\n'
        'Weight: $weight kg\n'
        'Body Fat: $bodyFat%\n'
        'Today\'s Diet:\n$dietDescription\n'
        'How balanced is this diet? Are there any improvements you can suggest?';

    final apiService = Provider.of<ApiService>(context, listen: false);
    String response;
    try {
      response = await apiService.sendMessage([
        Message(role: 'system', content: 'You are a helpful assistant.'),
        Message(role: 'user', content: prompt),
      ]);
    } catch (e) {
      response = 'An error occurred while communicating with the ChatBot: $e';
    }

    // Only update UI if widget is still mounted
    if (mounted) {
      setState(() {
        _chatBotResponse = response;
        _isFeedbackExpanded = false;
      });

      // 저장된 피드백을 SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chatBotResponse_${_getDateKey(widget.selectedDay)}', response);
    }
  }

  /// Load diet logs
  Future<void> _loadDietLogs() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('dietLogs');
    if (data != null) {
      print('Loading dietLogs: $data'); // Debugging output
      try {
        Map<String, dynamic> jsonData = jsonDecode(data);
        setState(() {
          _dietLogsByDate = jsonData.map((date, meals) {
            return MapEntry(
              date,
              List<MealLog>.from(
                (meals as List<dynamic>).map((mealJson) => MealLog.fromJson(mealJson)),
              ),
            );
          }).cast<String, List<MealLog>>();
        });
      } catch (e) {
        debugPrint('Error decoding diet logs: $e');
        setState(() {
          _dietLogsByDate = {};
        });
      }
    }
  }

  /// Add food to a specific meal
  Future<void> _addDiet(int mealIndex) async {
    final bool? isAdd = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(_getMealName(mealIndex)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Did you have a meal?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true); // Select 'Yes'
                    },
                    child: const Text('Yes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false); // Select 'No'
                    },
                    child: const Text('No'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[200]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (isAdd != null && isAdd) {
      _openFoodSelection(mealIndex);
    }
  }

  String _getMealName(int mealIndex) {
    switch (mealIndex) {
      case 0:
        return 'Meal 1';
      case 1:
        return 'Meal 2';
      case 2:
        return 'Meal 3';
      default:
        return 'Meal ${mealIndex + 1}';
    }
  }

  void _openFoodSelection(int mealIndex) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        String searchQuery = '';
        List<Map<String, dynamic>> searchResults = [];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search Food',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) async {
                      setState(() {
                        searchQuery = value;
                      });

                      if (searchQuery.isNotEmpty) {
                        try {
                          final results = await _foodService.searchFoods(searchQuery);
                          setState(() {
                            searchResults = results;
                          });
                        } catch (e) {
                          _showErrorDialog(e.toString());
                        }
                      } else {
                        setState(() {
                          searchResults = [];
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: searchResults.isEmpty
                      ? const Center(child: Text('No results found.'))
                      : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (BuildContext listContext, int index) {
                      final food = searchResults[index];
                      return ListTile(
                        leading: Image.network(food['photo']),
                        title: Text(food['food_name']),
                        onTap: () async {
                          Navigator.pop(sheetContext); // Close BottomSheet
                          final nutrients = await _foodService.getFoodNutrients(food['food_name']);
                          _showQuantitySliderDialog(mealIndex, nutrients);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuantitySliderDialog(int mealIndex, Map<String, dynamic> food) async {
    double servingSize = 1.0; // Default value

    final updatedServingSize = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ServingSizeDialog(
          foodName: food['food_name'],
          initialServingSize: servingSize,
        );
      },
    );

    if (updatedServingSize != null) {
      _addFoodToMeal(mealIndex, food, updatedServingSize);
    }
  }

  void _addFoodToMeal(int mealIndex, Map<String, dynamic> food, double servingSize) {
    final double servingWeightGrams = (food['serving_weight_grams'] as num).toDouble();
    final double quantityInGrams = servingWeightGrams * servingSize;

    final consumedFood = ConsumedFood(
      name: food['food_name'],
      carbsPerServing: (food['carbs'] as num).toDouble(),
      proteinPerServing: (food['protein'] as num).toDouble(),
      fatPerServing: (food['fat'] as num).toDouble(),
      carbs: (food['carbs'] as num).toDouble() * servingSize,
      protein: (food['protein'] as num).toDouble() * servingSize,
      fat: (food['fat'] as num).toDouble() * servingSize,
      quantity: quantityInGrams, // Store in grams
      servingWeightGrams: servingWeightGrams, // Store serving size
    );

    setState(() {
      _mealLogs[mealIndex].foods.add(consumedFood);
    });
  }

  /// Delete food from diet log
  void _removeFoodFromDietLog(int mealIndex, int foodIndex) {
    setState(() {
      _mealLogs[mealIndex].foods.removeAt(foodIndex);

      // Check if the meal is empty after removal
      if (_mealLogs[mealIndex].foods.isEmpty) {
        // If all food items are removed from the meal, we don't request feedback
        _chatBotResponse = '';  // Reset the feedback if the meal is empty
        _isFeedbackExpanded = false;
      }
    });
  }

  /// Edit food in diet log
  void _editFoodInDietLog(int mealIndex, int foodIndex) async {
    final consumedFood = _mealLogs[mealIndex].foods[foodIndex];
    double servingSize = consumedFood.quantity / consumedFood.servingWeightGrams;

    // Clamp servingSize to stay within slider range
    servingSize = servingSize.clamp(0.5, 3.0).toDouble();

    // Await the updated servingSize from the dialog
    final updatedServingSize = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ServingSizeDialog(
          foodName: consumedFood.name,
          initialServingSize: servingSize,
        );
      },
    );

    if (updatedServingSize != null) {
      setState(() {
        // Update the ConsumedFood object
        _mealLogs[mealIndex].foods[foodIndex] = ConsumedFood(
          name: consumedFood.name,
          carbsPerServing: consumedFood.carbsPerServing,
          proteinPerServing: consumedFood.proteinPerServing,
          fatPerServing: consumedFood.fatPerServing,
          carbs: consumedFood.carbsPerServing * updatedServingSize,
          protein: consumedFood.proteinPerServing * updatedServingSize,
          fat: consumedFood.fatPerServing * updatedServingSize,
          quantity: consumedFood.servingWeightGrams * updatedServingSize,
          servingWeightGrams: consumedFood.servingWeightGrams, // Maintain
        );
      });
    }
  }

  /// Calculate total nutrients for the day
  Map<String, double> _calculateTotalNutrients() {
    double totalCarbs = 0.0;
    double totalProtein = 0.0;
    double totalFat = 0.0;

    for (var log in _mealLogs) {
      for (var consumed in log.foods) {
        totalCarbs += consumed.carbs;
        totalProtein += consumed.protein;
        totalFat += consumed.fat;
      }
    }

    return {
      'carbs': totalCarbs,
      'protein': totalProtein,
      'fat': totalFat,
    };
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext errorContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(errorContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Add a new meal
  void _addNewMeal() {
    setState(() {
      _mealLogs.add(MealLog());
    });
  }

  /// Remove a meal
  void _removeMeal(int mealIndex) {
    setState(() {
      _mealLogs.removeAt(mealIndex);
    });
  }

  /// Display ChatBot response (with summary and expand functionality)
  Widget _buildChatBotResponse() {
    if (_chatBotResponse.isEmpty) {
      return const SizedBox.shrink();
    }

    // Limit feedback to 3 lines using Text widget's maxLines and overflow
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.lightGreen[50],
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ChatBot Diet Feedback',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _isFeedbackExpanded
                  ? Text(
                _chatBotResponse,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              )
                  : Text(
                _chatBotResponse,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              if (_chatBotResponse.split('\n').length > 3)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFeedbackExpanded = !_isFeedbackExpanded;
                    });
                  },
                  child: Text(
                    _isFeedbackExpanded ? '...Collapse' : '...More',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show SnackBar
  void _showSnackBar(String message) {
    if (!mounted) return; // Check if the widget is mounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalNutrients = _calculateTotalNutrients();

    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Log - ${widget.selectedDay.toLocal()}'.split(' ')[0]),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDietLogs,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Nutrients Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Total Nutrient Intake Card
                  Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Nutrient Intake',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Carbs: ${totalNutrients['carbs']!.toStringAsFixed(1)}g',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Protein: ${totalNutrients['protein']!.toStringAsFixed(1)}g',
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Fat: ${totalNutrients['fat']!.toStringAsFixed(1)}g',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between cards
                  // Program Targets Card
                  Expanded(
                    child: Card(
                      color: Colors.lightBlue[50],
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _currentProgramData == null
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No Program Set',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Please add a Bulking or Cutting program to see your daily intake targets.',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: 80, // Adjust button width
                                  height: 40, // Adjust button height
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Navigate to Bulking program screen
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProgramScreen(programType: 'Bulking'),
                                        ),
                                      );
                                      _loadProgramData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Bulk'),
                                  ),
                                ),
                                // Cutting button
                                SizedBox(
                                  width: 80, // Adjust button width
                                  height: 40, // Adjust button height
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Navigate to Cutting program screen
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProgramScreen(programType: 'Cutting'),
                                        ),
                                      );
                                      _loadProgramData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Text('Cut'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_currentProgramData!.programType} Program Targets',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Carbs: ${_currentProgramData!.dailyCarbs.toStringAsFixed(1)}g',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Protein: ${_currentProgramData!.dailyProtein.toStringAsFixed(1)}g',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Fat: ${_currentProgramData!.dailyFat.toStringAsFixed(1)}g',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Meal Cards
            ..._mealLogs.asMap().entries.map((entry) {
              final index = entry.key;
              final mealLog = entry.value;

              return Dismissible(
                key: Key('meal_$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _removeMeal(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_getMealName(index)} deleted')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        // Meal name and add button
                        ListTile(
                          title: Text(
                            _getMealName(index),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add, color: Colors.blue),
                            onPressed: () => _addDiet(index),
                          ),
                        ),
                        // Food list
                        if (mealLog.foods.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: mealLog.foods.length,
                            itemBuilder: (context, foodIndex) {
                              final food = mealLog.foods[foodIndex];
                              return ListTile(
                                title: Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Amount: ${food.quantity.toStringAsFixed(1)}g\n'
                                      'Carbs: ${food.carbs.toStringAsFixed(1)}g\n'
                                      'Protein: ${food.protein.toStringAsFixed(1)}g\n'
                                      'Fat: ${food.fat.toStringAsFixed(1)}g',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.black),
                                      onPressed: () {
                                        _editFoodInDietLog(index, foodIndex);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _removeFoodFromDietLog(index, foodIndex);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'No foods added.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            // Add Meal button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton.icon(
                onPressed: _addNewMeal,
                icon: const Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                ),
                label: const Text('Add Meal'),
              ),
            ),
            // **Added: Display ChatBot response (Feedback Card)**
            _buildChatBotResponse(),
          ],
        ),
      ),
    );
  }
}
