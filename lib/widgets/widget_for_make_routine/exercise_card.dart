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

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onDelete,
    required this.onSetsUpdated,
    required this.onSave,
  });

  @override
  ExerciseCardState createState() => ExerciseCardState();
}

class ExerciseCardState extends State<ExerciseCard> {
  late List<Map<String, int>> sets;

  @override
  void initState() {
    super.initState();
    sets = List<Map<String, int>>.from(widget.exercise.sets);
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
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.black),
                      onPressed: widget.onSave,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
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
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.black),
                  onPressed: _removeSet,
                ),
                Text(
                  "세트 수: ${sets.length}",
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.black),
                  onPressed: _addSet,
                ),
              ],
            ),
            Column(
              children: List.generate(sets.length, (index) {
                final set = sets[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
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
                              '${set['reps']} 회',
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
