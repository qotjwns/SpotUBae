// widgets/widget_for_make_routine/exercise_list_item.dart

import 'package:flutter/material.dart';
import '../../models/exercise.dart';

class ExerciseListItem extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onDelete;
  final ValueChanged<List<Map<String, int>>> onSetsUpdated;
  final ValueChanged<String?> onNotesUpdated; // 메모 업데이트 콜백 추가

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.index,
    required this.onDelete,
    required this.onSetsUpdated,
    required this.onNotesUpdated, // 메모 업데이트 콜백 전달
  });

  @override
  ExerciseListItemState createState() => ExerciseListItemState();
}

class ExerciseListItemState extends State<ExerciseListItem> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  late String? notes;

  @override
  void initState() {
    super.initState();
    notes = widget.exercise.notes;
  }

  void _addSet() {
    final weightText = _weightController.text.trim();
    final repsText = _repsController.text.trim();

    if (weightText.isEmpty || repsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('무게와 반복 횟수를 입력해주세요.')),
      );
      return;
    }

    final weight = int.tryParse(weightText);
    final reps = int.tryParse(repsText);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 무게와 반복 횟수를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      widget.exercise.sets.add({'weight': weight, 'reps': reps});
      _weightController.clear();
      _repsController.clear();
    });

    widget.onSetsUpdated(widget.exercise.sets);
  }

  Future<void> _editNotes() async {
    String updatedNotes = notes ?? '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('메모 추가/수정'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '메모를 입력하세요',
            ),
            controller: TextEditingController(text: updatedNotes),
            onChanged: (value) {
              updatedNotes = value;
            },
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 취소
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 저장
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    setState(() {
      notes = updatedNotes.trim().isEmpty ? null : updatedNotes.trim();
    });
    widget.onNotesUpdated(notes);
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 메모 표시 및 편집 버튼
            Row(
              children: [
                Expanded(
                  child: notes != null
                      ? GestureDetector(
                    onTap: _editNotes,
                    child: Row(
                      children: [
                        const Icon(Icons.note, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notes!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.edit, color: Colors.blue, size: 16),
                      ],
                    ),
                  )
                      : GestureDetector(
                    onTap: _editNotes,
                    child: Row(
                      children: const [
                        Icon(Icons.note_add, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '메모 추가',
                          style:
                          TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                      labelText: '반복 횟수',
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
                    'Set: $weight kg x $reps Reps',
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
