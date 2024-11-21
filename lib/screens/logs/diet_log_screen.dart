// lib/screens/logs/diet_log_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/meal_log.dart'; // MealLog 임포트
import '../../models/consumed_food.dart'; // ConsumedFood 임포트
import '../../services/food_service.dart'; // FoodService 임포트

class DietLogScreen extends StatefulWidget {
  final DateTime selectedDay;

  const DietLogScreen({super.key, required this.selectedDay});

  @override
  DietLogScreenState createState() => DietLogScreenState();
}

class DietLogScreenState extends State<DietLogScreen> {
  Map<String, Map<String, MealLog>> _dietLogsByDate = {};
  final FoodService _foodService = FoodService();

  Map<String, MealLog> get _dietLogs {
    String dateKey = _getDateKey(widget.selectedDay);
    if (!_dietLogsByDate.containsKey(dateKey)) {
      _dietLogsByDate[dateKey] = {
        'Breakfast': MealLog(),
        'Lunch': MealLog(),
        'Dinner': MealLog(),
      };
    }
    return _dietLogsByDate[dateKey]!;
  }

  @override
  void initState() {
    super.initState();
    _loadDietLogs();
  }

  String _getDateKey(DateTime date) {
    return date.toIso8601String().split('T')[0]; // 'YYYY-MM-DD' 형식
  }

  Future<void> _saveDietLogs() async {
    final prefs = await SharedPreferences.getInstance();
    String data = jsonEncode(_dietLogsByDate.map((date, meals) {
      return MapEntry(
        date,
        meals.map((meal, log) {
          return MapEntry(
            meal,
            log.toJson(),
          );
        }),
      );
    }));
    await prefs.setString('dietLogs', data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diet logs saved successfully')),
    );
  }

  /// 식단 로그 로드
  Future<void> _loadDietLogs() async {
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
      });
    }
  }

  /// 특정 식사에 음식 추가
  Future<void> _addDiet(String meal) async {
    final bool? isSkipped = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('$meal 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('해당 끼니를 드셨나요?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false); // '예' 선택
                    },
                    child: const Text('예'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true); // '아니요' 선택
                    },
                    child: const Text('아니요'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (isSkipped != null) {
      if (isSkipped) {
        _markMealAsSkipped(meal);
      } else {
        _openFoodSelection(meal);
      }
    }
  }

  void _markMealAsSkipped(String meal) {
    setState(() {
      _dietLogs[meal]!.isSkipped = true;
      _dietLogs[meal]!.foods.clear(); // 기존 음식 목록 삭제
    });
  }

  void _openFoodSelection(String meal) {
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
                    itemBuilder:
                        (BuildContext listContext, int index) {
                      final food = searchResults[index];
                      return ListTile(
                        leading: Image.network(food['photo']),
                        title: Text(food['food_name']),
                        onTap: () async {
                          Navigator.pop(sheetContext); // BottomSheet 닫기
                          final nutrients =
                          await _foodService.getFoodNutrients(food['food_name']);
                          _showQuantitySliderDialog(meal, nutrients);
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

  /// 섭취량 선택 다이얼로그 표시
  void _showQuantitySliderDialog(String meal, Map<String, dynamic> food) {
    double servingSize = 1.0; // 기본값

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${food['food_name']} 섭취량 선택'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('인분 수: ${servingSize.toStringAsFixed(1)}'),
                  Slider(
                    value: servingSize,
                    min: 0.5,
                    max: 3.0,
                    divisions: 5,
                    label: '${servingSize.toStringAsFixed(1)} 인분',
                    onChanged: (value) {
                      setState(() {
                        servingSize = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    _addFoodToDietLog(meal, food, servingSize);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addFoodToDietLog(
      String meal, Map<String, dynamic> food, double servingSize) {
    final double quantityInGrams = food['serving_weight_grams'] * servingSize;

    final consumedFood = ConsumedFood(
      name: food['food_name'],
      carbs: (food['carbs'] as num).toDouble() * servingSize,
      protein: (food['protein'] as num).toDouble() * servingSize,
      fat: (food['fat'] as num).toDouble() * servingSize,
      quantity: quantityInGrams, // 그램 단위로 저장
    );

    setState(() {
      _dietLogs[meal]!.foods.add(consumedFood);
      _dietLogs[meal]!.isSkipped = false; // 음식 추가 시 skipped 상태 해제
    });
  }

  /// 음식 삭제
  void _removeFoodFromDietLog(String meal, int index) {
    setState(() {
      _dietLogs[meal]!.foods.removeAt(index);
      if (_dietLogs[meal]!.foods.isEmpty) {
        // 음식이 모두 삭제되면 skipped 상태로 설정
        _dietLogs[meal]!.isSkipped = true;
      }
    });
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

  /// 특정 음식 수정
  void _editFoodInDietLog(String meal, int index) {
    final consumedFood = _dietLogs[meal]!.foods[index];
    double servingSize = consumedFood.quantity / consumedFood.carbs;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${consumedFood.name} 수정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('인분 수: ${servingSize.toStringAsFixed(1)}'),
                  Slider(
                    value: servingSize,
                    min: 0.5,
                    max: 3.0,
                    divisions: 5,
                    label: '${servingSize.toStringAsFixed(1)} 인분',
                    onChanged: (value) {
                      setState(() {
                        servingSize = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _dietLogs[meal]!.foods[index] = ConsumedFood(
                        name: consumedFood.name,
                        carbs: (consumedFood.carbs * servingSize).toDouble(),
                        protein:
                        (consumedFood.protein * servingSize).toDouble(),
                        fat: (consumedFood.fat * servingSize).toDouble(),
                        quantity:
                        (consumedFood.quantity * servingSize).toDouble(),
                      );
                      _dietLogs[meal]!.isSkipped = false; // 수정 시 skipped 상태 해제
                    });
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('수정'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('취소'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 하루 총 영양소 계산
  Map<String, double> _calculateTotalNutrients() {
    double totalCarbs = 0.0;
    double totalProtein = 0.0;
    double totalFat = 0.0;

    _dietLogs.forEach((meal, log) {
      for (var consumed in log.foods) {
        totalCarbs += consumed.carbs;
        totalProtein += consumed.protein;
        totalFat += consumed.fat;
      }
    });

    return {
      'carbs': totalCarbs,
      'protein': totalProtein,
      'fat': totalFat,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totalNutrients = _calculateTotalNutrients();

    return Scaffold(
      appBar: AppBar(
        title:
        Text('Diet Log - ${widget.selectedDay.toLocal()}'.split(' ')[0]),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveDietLogs();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // 카드들을 가운데 정렬
          children: [
            // 하루 총 섭취량 표시
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Total Nutrient Intake',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Carbs: ${totalNutrients['carbs']!.toStringAsFixed(1)}g'),
                      Text(
                          'Protein: ${totalNutrients['protein']!.toStringAsFixed(1)}g'),
                      Text('Fat: ${totalNutrients['fat']!.toStringAsFixed(1)}g'),
                    ],
                  ),
                ),
              ),
            ),
            // 식사별 섭취한 음식 목록 표시
            ...['Breakfast', 'Lunch', 'Dinner'].map((meal) {
              final mealLog = _dietLogs[meal]!;
              final foods = mealLog.foods;
              return Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9, // 카드 너비 조절
                  child: Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        // 식사명 표시
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                meal,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (mealLog.isSkipped)
                                const Text(
                                  '음식을 안 먹었다',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                        // 섭취한 음식 목록 표시 또는 '음식을 안 먹었다' 표시
                        if (!mealLog.isSkipped)
                          foods.isNotEmpty
                              ? ListView.builder(
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemCount: foods.length,
                            itemBuilder:
                                (BuildContext context, int index) {
                              final consumed = foods[index];
                              return ListTile(
                                title: Text(
                                  consumed.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Amount: ${consumed.quantity.toStringAsFixed(1)}g\nCarbs: ${consumed.carbs.toStringAsFixed(1)}g, Protein: ${consumed.protein.toStringAsFixed(1)}g, Fat: ${consumed.fat.toStringAsFixed(1)}g',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.black),
                                      onPressed: () {
                                        _editFoodInDietLog(
                                            meal, index);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.black),
                                      onPressed: () {
                                        _removeFoodFromDietLog(
                                            meal, index);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                              : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '음식을 추가해주세요.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        // Add Food 버튼
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (mealLog.isSkipped) {
                                // skipped 상태일 경우, 다시 음식 추가 시 skipped 해제
                                setState(() {
                                  _dietLogs[meal]!.isSkipped = false;
                                });
                              }
                              _addDiet(meal);
                            },
                            icon: const Icon(Icons.add),
                            label: Text(mealLog.isSkipped
                                ? '음식 추가하기'
                                : 'Add Food'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
