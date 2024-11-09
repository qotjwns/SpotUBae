import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseListItem extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onDelete;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.index,
    required this.onDelete,
  });

  @override
  _ExerciseListItemState createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  void _addSet() {
    final weightText = _weightController.text.trim();
    final repsText = _repsController.text.trim();

    if (weightText.isEmpty || repsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('무게와 횟수를 입력해주세요.')),
      );
      return;
    }

    final weight = int.tryParse(weightText);
    final reps = int.tryParse(repsText);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 무게와 횟수를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      widget.exercise.sets.add({'weight': weight, 'reps': reps});
      _weightController.clear();
      _repsController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 운동 이름과 삭제 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.exercise.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 최근 기록 및 추천 기록
            Row(
              children: [
                Chip(
                  label: Text("최근: ${widget.exercise.recentRecord}"),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text("추천: ${widget.exercise.recommendedRecord}"),
                  backgroundColor: Colors.blue[100],
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            // 세트 추가 입력 필드와 버튼
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '무게 (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '횟수',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _addSet,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 추가된 세트 리스트 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.exercise.sets.map((set) {
                final weight = set['weight'] ?? 0;
                final reps = set['reps'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '세트: $weight kg x $reps 회',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
