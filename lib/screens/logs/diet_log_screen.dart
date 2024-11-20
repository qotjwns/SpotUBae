import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DietLogScreen extends StatefulWidget {
  final DateTime selectedDay;

  const DietLogScreen({super.key, required this.selectedDay});

  @override
  DietLogScreenState createState() => DietLogScreenState();
}

class DietLogScreenState extends State<DietLogScreen> {
  Map<String, Map<String, List<ConsumedFood>>> _dietLogsByDate = {};

  Map<String, List<ConsumedFood>> get _dietLogs {
    String dateKey = _getDateKey(widget.selectedDay);
    if (!_dietLogsByDate.containsKey(dateKey)) {
      _dietLogsByDate[dateKey] = {
        'Breakfast': [],
        'Lunch': [],
        'Dinner': [],
      };
    }
    return _dietLogsByDate[dateKey]!;
  }

  final String appId = '9b6fd567';
  final String appKey = '0354b40e9df9c5fbdfc2ae8159fcb963';

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
        meals.map((meal, foods) {
          return MapEntry(
            meal,
            foods.map((food) => food.toJson()).toList(),
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
            (meals as Map<String, dynamic>).map((meal, foods) {
              List<ConsumedFood> consumedFoods = (foods as List<dynamic>)
                  .map((food) => ConsumedFood.fromJson(food))
                  .toList();
              return MapEntry(meal, consumedFoods);
            }),
          );
        }).cast<String, Map<String, List<ConsumedFood>>>();
      });
    }
  }

  /// 음식 검색 함수
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final url = Uri.parse(
        'https://trackapi.nutritionix.com/v2/search/instant?query=$query');

    final response = await http.get(url, headers: {
      'x-app-id': appId,
      'x-app-key': appKey,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List commonFoods = data['common'];

      return commonFoods.map<Map<String, dynamic>>((food) {
        return {
          'food_name': food['food_name'],
          'photo': food['photo']['thumb'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load foods');
    }
  }

  /// 영양 정보 가져오기
  Future<Map<String, dynamic>> getFoodNutrients(String foodName) async {
    final url =
    Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients');

    final response = await http.post(url,
        headers: {
          'x-app-id': appId,
          'x-app-key': appKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({'query': foodName}));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final nutrients = data['foods'][0];

      return {
        'food_name': nutrients['food_name'],
        'serving_weight_grams': nutrients['serving_weight_grams'],
        'calories': nutrients['nf_calories'],
        'carbs': nutrients['nf_total_carbohydrate'],
        'protein': nutrients['nf_protein'],
        'fat': nutrients['nf_total_fat'],
      };
    } else {
      throw Exception('Failed to load nutrients');
    }
  }

  /// 특정 식사에 음식 추가
  void _addDiet(String meal) {
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
                          final results = await searchFoods(searchQuery);
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
                          final nutrients =
                          await getFoodNutrients(food['food_name']);
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
      carbs: food['carbs'] * servingSize,
      protein: food['protein'] * servingSize,
      fat: food['fat'] * servingSize,
      quantity: quantityInGrams, // 그램 단위로 저장
    );

    setState(() {
      _dietLogs[meal]!.add(consumedFood);
    });
  }

  /// 음식 삭제
  void _removeFoodFromDietLog(String meal, int index) {
    setState(() {
      _dietLogs[meal]!.removeAt(index);
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

  /// 하루 총 영양소 계산
  Map<String, double> _calculateTotalNutrients() {
    double totalCarbs = 0.0;
    double totalProtein = 0.0;
    double totalFat = 0.0;

    _dietLogs.forEach((meal, foods) {
      for (var consumed in foods) {
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
        title: Text('Diet Log - ${widget.selectedDay.toLocal()}'.split(' ')[0]),
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
              final foods = _dietLogs[meal]!;
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9, // 카드 너비 조절
                  child: Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        // 식사명 표시
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            meal,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // 섭취한 음식 목록 표시
                        if (foods.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: foods.length,
                            itemBuilder: (BuildContext context, int index) {
                              final consumed = foods[index];
                              return ListTile(
                                title: Text(consumed.name),
                                subtitle: Text(
                                    'Amount: ${consumed.quantity.toStringAsFixed(1)}g\nCarbs: ${consumed.carbs.toStringAsFixed(1)}g, Protein: ${consumed.protein.toStringAsFixed(1)}g, Fat: ${consumed.fat.toStringAsFixed(1)}g'),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _removeFoodFromDietLog(meal, index);
                                  },
                                ),
                              );
                            },
                          ),
                        // Add Food 버튼
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            onPressed: () => _addDiet(meal),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Food'),
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

/// 섭취한 음식을 나타내는 클래스
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

  // JSON 직렬화 메서드 추가
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
