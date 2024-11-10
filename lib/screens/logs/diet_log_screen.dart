import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DietLogScreen extends StatefulWidget {
  final DateTime selectedDay;

  const DietLogScreen({Key? key, required this.selectedDay}) : super(key: key);

  @override
  _DietLogScreenState createState() => _DietLogScreenState();
}

class _DietLogScreenState extends State<DietLogScreen> {
  final Map<String, Map<String, double>> _dietLogs = {
    '아침': {'carbs': 0, 'protein': 0, 'fat': 0},
    '점심': {'carbs': 0, 'protein': 0, 'fat': 0},
    '저녁': {'carbs': 0, 'protein': 0, 'fat': 0},
  };

  String getFormattedDate(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date); // 날짜 형식을 YYYY.MM.DD로 변환
  }

  void _selectNutrient(String meal, String nutrient) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: ['쌀밥', '빵', '면', '닭가슴살', '두부'].map((food) {
            return ListTile(
              title: Text(food),
              onTap: () {
                Navigator.pop(context);
                _showQuantityDialog(meal, nutrient, food);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showQuantityDialog(String meal, String nutrient, String food) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$food ${nutrient == 'carbs' ? '탄수화물' : nutrient == 'protein' ? '단백질' : '지방'} (g)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '그램(g)을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(controller.text) ?? 0;
              setState(() {
                _dietLogs[meal]![nutrient] = (_dietLogs[meal]![nutrient] ?? 0) + weight;
              });
              Navigator.of(context).pop();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Log - ${getFormattedDate(widget.selectedDay)}'),
      ),
      body: ListView(
        children: _dietLogs.entries.map((entry) {
          final meal = entry.key;
          final nutrients = entry.value;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$meal:',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    NutrientButton(
                      label: '탄수화물: ${nutrients['carbs']!.toStringAsFixed(1)}g',
                      onTap: () => _selectNutrient(meal, 'carbs'),
                    ),
                    NutrientButton(
                      label: '단백질: ${nutrients['protein']!.toStringAsFixed(1)}g',
                      onTap: () => _selectNutrient(meal, 'protein'),
                    ),
                    NutrientButton(
                      label: '지방: ${nutrients['fat']!.toStringAsFixed(1)}g',
                      onTap: () => _selectNutrient(meal, 'fat'),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NutrientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const NutrientButton({required this.label, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label),
      ),
    );
  }
}
