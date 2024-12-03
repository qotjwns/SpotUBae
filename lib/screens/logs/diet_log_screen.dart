// lib/screens/logs/diet_log_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/message.dart';
import '../../models/program_user_data.dart';
import '../../services/api_service.dart';
import '../../models/consumed_food.dart'; // ConsumedFood 임포트
import '../../services/food_service.dart';
import '../../widgets/widget_for_diet_log_screen/serving_size_dialog.dart';
import 'package:provider/provider.dart';
import '../program_screen/program_screen.dart';
import 'meal_log.dart'; // MealLog 임포트
import '../../services/user_data_service.dart';


class DietLogScreen extends StatefulWidget {
  final DateTime selectedDay;

  const DietLogScreen({super.key, required this.selectedDay});

  @override
  DietLogScreenState createState() => DietLogScreenState();
}

class DietLogScreenState extends State<DietLogScreen> {
  // Map<String, List<MealLog>> 형태로 변경
  Map<String, List<MealLog>> _dietLogsByDate = {};
  final FoodService _foodService = FoodService();

  List<MealLog> get _mealLogs {
    String dateKey = _getDateKey(widget.selectedDay);
    if (!_dietLogsByDate.containsKey(dateKey)) {
      _dietLogsByDate[dateKey] = [
        MealLog(), // 첫 번째 끼니
        MealLog(), // 두 번째 끼니
        MealLog(), // 세 번째 끼니
      ];
    }
    return _dietLogsByDate[dateKey]!;
  }

  // **추가: 챗봇 응답 저장 변수**
  String _chatBotResponse = '';

  // 프로그램 데이터를 저장할 변수
  ProgramUserData? _currentProgramData;
  String? _currentProgramType; // 현재 프로그램 타입

  @override
  void initState() {
    super.initState();
    _loadDietLogs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProgramData();
    });
  }


  /// 프로그램 데이터 로드
  Future<void> _loadProgramData() async {
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    await userDataService.loadProgramUserData(); // 프로그램 데이터 로드

    // 현재 활성화된 프로그램 타입을 결정합니다.
    // 'Bulking' 또는 'Cutting' 중 하나가 설정되어 있다고 가정합니다.
    _currentProgramType = userDataService.currentProgramType;

    if (_currentProgramType == 'Bulking') {
      _currentProgramData = userDataService.bulkingProgramData;
    } else if (_currentProgramType == 'Cutting') {
      _currentProgramData = userDataService.cuttingProgramData;
    } else {
      _currentProgramData = null;
    }

    setState(() {}); // UI 업데이트
  }

  String _getDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0]; // 'YYYY-MM-DD' 형식
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

    // **추가: 챗봇에게 식단 피드백 요청**
    await _requestChatBotFeedback();
  }

  /// 챗봇에게 식단 피드백 요청
  Future<void> _requestChatBotFeedback() async {
    print('_requestChatBotFeedback called'); // 디버깅용 출력

    // **사용자의 최신 몸무게와 체지방률 가져오기**
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    if (userDataService.profileUserDataList.isEmpty) {
      _showSnackBar('Please enter your weight and body fat in the Profile screen.');
      print('User data list is empty'); // 디버깅용 출력
      return;
    }

    final latestUserData = userDataService.profileUserDataList.last;
    final weight = latestUserData.weight;
    final bodyFat = latestUserData.bodyFat;
    print('Latest User Data - Weight: $weight kg, Body Fat: $bodyFat%'); // 디버깅용 출력

    // **식단 정보 구성**
    String dietDescription = '';
    for (int i = 0; i < _mealLogs.length; i++) {
      final meal = _mealLogs[i];
      dietDescription += 'Meal ${i + 1}:\n';
      for (var food in meal.foods) {
        dietDescription += '- ${food.name}: ${food.quantity}g\n';
      }
    }
    print('Diet Description:\n$dietDescription'); // 디버깅용 출력

    // **챗봇에게 보낼 프롬프트 구성**
    String prompt = 'Based on the following information:\n'
        'Weight: $weight kg\n'
        'Body Fat: $bodyFat%\n'
        'Today\'s Diet:\n$dietDescription\n'
        'Please provide feedback on this diet. How balanced is it? Are there any improvements you can suggest?';
    print('Prompt to ChatBot: $prompt'); // 디버깅용 출력

    // **ApiService를 통해 프롬프트 전송 및 응답 받기**
    final apiService = Provider.of<ApiService>(context, listen: false);
    String response;
    try {
      response = await apiService.sendMessage([
        Message(role: 'system', content: 'You are a helpful assistant.'),
        Message(role: 'user', content: prompt),
      ]);
      print('Parsed ChatBot Response: $response'); // 디버깅용 출력
    } catch (e) {
      response = '챗봇과의 통신 중 오류가 발생했습니다: $e';
      print('Error in sendMessage: $e'); // 디버깅용 출력
    }

    // **응답을 상태에 저장하여 화면에 표시**
    setState(() {
      _chatBotResponse = response;
      print('_chatBotResponse set to: $_chatBotResponse'); // 디버깅용 출력
    });
  }


  /// 식단 로그 로드
  Future<void> _loadDietLogs() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('dietLogs');
    if (data != null) {
      print('Loading dietLogs: $data'); // 디버깅용 출력
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

  /// 특정 끼니에 음식 추가
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
                      Navigator.of(dialogContext).pop(true); // 'Yes' 선택
                    },
                    child: const Text('Yes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false); // 'No' 선택
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
                          Navigator.pop(sheetContext); // BottomSheet 닫기
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
    double servingSize = 1.0; // 기본값

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
      quantity: quantityInGrams, // 그램 단위로 저장
      servingWeightGrams: servingWeightGrams, // 1회 제공량 저장
    );

    setState(() {
      _mealLogs[mealIndex].foods.add(consumedFood);
    });
  }

  /// 음식 삭제
  void _removeFoodFromDietLog(int mealIndex, int foodIndex) {
    setState(() {
      _mealLogs[mealIndex].foods.removeAt(foodIndex);
    });
  }

  /// 음식 수정
  void _editFoodInDietLog(int mealIndex, int foodIndex) async {
    final consumedFood = _mealLogs[mealIndex].foods[foodIndex];
    double servingSize = consumedFood.quantity / consumedFood.servingWeightGrams;

    // servingSize가 Slider의 범위를 벗어나지 않도록 클램핑
    servingSize = servingSize.clamp(0.5, 3.0).toDouble();

    // 다이얼로그에서 수정된 servingSize를 반환받기 위해 await 사용
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
        // ConsumedFood 객체를 업데이트
        _mealLogs[mealIndex].foods[foodIndex] = ConsumedFood(
          name: consumedFood.name,
          carbsPerServing: consumedFood.carbsPerServing,
          proteinPerServing: consumedFood.proteinPerServing,
          fatPerServing: consumedFood.fatPerServing,
          carbs: consumedFood.carbsPerServing * updatedServingSize,
          protein: consumedFood.proteinPerServing * updatedServingSize,
          fat: consumedFood.fatPerServing * updatedServingSize,
          quantity: consumedFood.servingWeightGrams * updatedServingSize,
          servingWeightGrams: consumedFood.servingWeightGrams, // 유지
        );
      });
    }
  }

  /// 하루 총 영양소 계산
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

  /// 에러 다이얼로그 표시
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

  /// 끼니 추가
  void _addNewMeal() {
    setState(() {
      _mealLogs.add(MealLog());
    });
  }

  /// 끼니 삭제
  void _removeMeal(int mealIndex) {
    setState(() {
      _mealLogs.removeAt(mealIndex);
    });
  }

  /// 챗봇 응답 표시
  Widget _buildChatBotResponse() {
    if (_chatBotResponse.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.lightGreen[50],
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _chatBotResponse,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인
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
            // 총 영양소 카드
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Total Nutrient Intake 카드
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
                  const SizedBox(width: 16), // 카드 간 간격
                  // Program Targets 카드
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
                                  width: 80, // 버튼의 너비 조절
                                  height: 40, // 버튼의 높이 조절
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Bulking 프로그램 화면으로 이동
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
                                // Cutting 버튼
                                SizedBox(
                                  width: 80, // 버튼의 너비 조절
                                  height: 40, // 버튼의 높이 조절
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Cutting 프로그램 화면으로 이동
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
            // 끼니 카드들
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
                        // 식사명과 추가 버튼
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
                        // 음식 목록
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
            // **추가: 챗봇 응답 표시**
            _buildChatBotResponse(),
            // 끼니 추가 버튼
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
          ],
        ),
      ),
    );
  }
}
