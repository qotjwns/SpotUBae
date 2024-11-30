// widgets/widget_for_make_routine/exercise_card.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../screens/chatbot/chatbot_screen.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final ValueChanged<List<Map<String, int>>> onSetsUpdated; // 세트 업데이트 콜백
  final ValueChanged<String> onNotesUpdated; // 메모 업데이트 콜백 추가

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onDelete,
    required this.onSetsUpdated,
    required this.onSave,
    required this.onNotesUpdated, // 메모 업데이트 콜백 전달
  });

  @override
  ExerciseCardState createState() => ExerciseCardState();
}

class ExerciseCardState extends State<ExerciseCard> {
  late List<Map<String, int>> sets;
  late String? notes; // 메모 상태 변수

  @override
  void initState() {
    super.initState();
    sets = List<Map<String, int>>.from(widget.exercise.sets);
    notes = widget.exercise.notes;
  }

  void _addSet() {
    setState(() {
      sets.add({'weight': 0, 'reps': 0});
    });
    widget.onSetsUpdated(sets); // 세트가 추가될 때마다 업데이트
  }

  void _removeSet() {
    if (sets.isNotEmpty) {
      setState(() {
        sets.removeLast();
      });
      widget.onSetsUpdated(sets); // 세트가 삭제될 때마다 업데이트
    }
  }

  Future<void> _showPicker({
    required BuildContext context,
    required int initialValue,
    required int minValue,
    required int maxValue,
    required int interval,
    required Function(int) onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 40,
            scrollController: FixedExtentScrollController(
                initialItem: (initialValue - minValue) ~/ interval),
            onSelectedItemChanged: (index) {
              onSelected(minValue + index * interval);
            },
            children: List<Widget>.generate(
              ((maxValue - minValue) ~/ interval) + 1,
                  (index) => Center(child: Text('${minValue + index * interval}')),
            ),
          ),
        );
      },
    );
  }

  // 메모 편집 다이얼로그 표시 메서드
  Future<void> _editNotes() async {
    String updatedNotes = notes ?? '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add/Edit Notes'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Please enter a note',
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 저장
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    setState(() {
      notes = updatedNotes.trim().isEmpty ? null : updatedNotes.trim();
    });
    widget.onNotesUpdated(notes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(widget.exercise.id), // 고유 ID 사용
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 드래그 핸들과 상단 행
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 드래그 핸들과 텍스트를 감싸는 Expanded
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.exercise.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
                        ),
                      ),
                    ],
                  ),
                ),
                // 아이콘 버튼들
                Row(
                  mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.question_mark,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatBotScreen(
                                workoutType: widget.exercise.name),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Notes 표시 및 편집 버튼
            Row(
              children: [
                Expanded(
                  child: notes != null
                      ? GestureDetector(
                    onTap: _editNotes, // 메모 수정
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
                    onTap: _editNotes, // 메모 추가
                    child: Row(
                      children: const [
                        Icon(Icons.note_add, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Add notes...',
                          style: TextStyle(
                              fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.black),
                  onPressed: _removeSet,
                ),
                Text(
                  "Number of Sets: ${sets.length}",
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.black),
                  onPressed: _addSet,
                ),
              ],
            ),
            // 세트 리스트
            Column(
              children: List.generate(sets.length, (index) {
                final set = sets[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      // 세트 번호 표시 추가
                      Text(
                        "Set ${index + 1}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await _showPicker(
                              context: context,
                              initialValue: set['weight']!,
                              minValue: 0,
                              maxValue: 300,
                              interval: 5,
                              onSelected: (value) {
                                setState(() {
                                  sets[index]['weight'] = value;
                                });
                                widget.onSetsUpdated(sets); // 무게가 변경될 때마다 업데이트
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${set['weight']} kg',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await _showPicker(
                              context: context,
                              initialValue: set['reps']!,
                              minValue: 0,
                              maxValue: 30,
                              interval: 1,
                              onSelected: (value) {
                                setState(() {
                                  sets[index]['reps'] = value;
                                });
                                widget.onSetsUpdated(sets); // 횟수가 변경될 때마다 업데이트
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${set['reps']} reps',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
