// widgets/widget_for_make_routine/exercise_card.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_app/screens/chatbot/how_to_chatbot.dart';
import '../../models/exercise.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final ValueChanged<List<Map<String, dynamic>>> onSetsUpdated; // 타입 수정
  final ValueChanged<String?> onNotesUpdated; // Nullable로 수정
  final bool isCardio;


  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onDelete,
    required this.onSetsUpdated,
    required this.onSave,
    required this.onNotesUpdated,
    required this.isCardio,
  });

  @override
  ExerciseCardState createState() => ExerciseCardState();
}

class ExerciseCardState extends State<ExerciseCard> {
  late List<Map<String, dynamic>> sets;
  late String? notes; // 메모 상태 변수

  @override
  void initState() {
    super.initState();
    sets = List<Map<String, dynamic>>.from(widget.exercise.sets);
    notes = widget.exercise.notes;
  }

  void _addSet() {
    setState(() {
      if (widget.isCardio) {
        sets.add({
          'workoutTime': {'minutes': 0, 'seconds': 0},
          'breakTime': {'minutes': 0, 'seconds': 0},
        });
      } else {
        sets.add({
          'weight': 0,
          'reps': 0,
          'breakTime': {'minutes': 0, 'seconds': 0},
        });
      }
    });
    widget.onSetsUpdated(sets);
  }

  void _removeSet() {
    if (sets.isNotEmpty) {
      setState(() {
        sets.removeLast();
      });
      widget.onSetsUpdated(sets);
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


  Future<void> _showTimePicker({
    required BuildContext context,
    required Map<String, int> initialValue,
    required Function(int, int) onSelected,
  }) async {
    int selectedMinutes = initialValue['minutes'] ?? 0;
    int selectedSeconds = initialValue['seconds'] ?? 0;

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 250,
          child: Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                      initialItem: selectedMinutes),
                  onSelectedItemChanged: (value) {
                    selectedMinutes = value;
                  },
                  children: List<Widget>.generate(
                    60,
                        (index) => Center(child: Text('$index min')),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                      initialItem: selectedSeconds),
                  onSelectedItemChanged: (value) {
                    selectedSeconds = value;
                  },
                  children: List<Widget>.generate(
                    60,
                        (index) => Center(child: Text('$index sec')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    onSelected(selectedMinutes, selectedSeconds);
  }


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
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 저장
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.black, // 텍스트 색상 유지
                ),
              ),
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
      key: ValueKey(widget.exercise.id),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 운동 이름 및 아이콘 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.exercise.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // 아이콘 버튼들
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.question_mark,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HowToChatbot(
                                workoutType: widget.exercise.name),
                          ),
                        );
                      },
                      tooltip: 'How to perform this exercise',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete Exercise',
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
                        const Icon(Icons.edit,
                            color: Colors.blue, size: 16),
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
                          style:
                          TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            // 세트 추가/삭제 및 세트 수 표시
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.black),
                  onPressed: _removeSet,
                  tooltip: 'Remove Set',
                ),
                Text(
                  "Number of Sets: ${sets.length}",
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.black),
                  onPressed: _addSet,
                  tooltip: 'Add Set',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 헤더 행 추가
            if (sets.isNotEmpty) ...[
              Card(
                color: Colors.grey[200],
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Set',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.isCardio) ...[
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Workout Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Break Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Weight',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Reps',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Break Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            // 세트 리스트
            Column(
              children: List.generate(sets.length, (index) {
                final set = sets[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      // 세트 번호 표시
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Set ${index + 1}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.isCardio) ...[
                        // Cardio 운동: Workout Time
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () async {
                              await _showTimePicker(
                                context: context,
                                initialValue: set['workoutTime'],
                                onSelected: (minutes, seconds) {
                                  setState(() {
                                    sets[index]['workoutTime'] = {'minutes': minutes, 'seconds': seconds};
                                  });
                                  widget.onSetsUpdated(sets);
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
                                '${set['workoutTime']['minutes']} min ${set['workoutTime']['seconds']} sec',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Break Time
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () async {
                              await _showTimePicker(
                                context: context,
                                initialValue: set['breakTime'] ?? {'minutes': 0, 'seconds': 0},
                                onSelected: (minutes, seconds) {
                                  setState(() {
                                    sets[index]['breakTime'] = {'minutes': minutes, 'seconds': seconds};
                                  });
                                  widget.onSetsUpdated(sets);
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
                                '${set['breakTime']['minutes']} min ${set['breakTime']['seconds']} sec',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // 일반 운동: Weight 및 Reps
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () async {
                              await _showPicker(
                                context: context,
                                initialValue: set['weight'] ?? 0,
                                minValue: 0,
                                maxValue: 300,
                                interval: 5,
                                onSelected: (value) {
                                  setState(() {
                                    sets[index]['weight'] = value;
                                  });
                                  widget.onSetsUpdated(sets);
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
                          flex: 2,
                          child: GestureDetector(
                            onTap: () async {
                              await _showPicker(
                                context: context,
                                initialValue: set['reps'] ?? 0,
                                minValue: 0,
                                maxValue: 30,
                                interval: 1,
                                onSelected: (value) {
                                  setState(() {
                                    sets[index]['reps'] = value;
                                  });
                                  widget.onSetsUpdated(sets);
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
                        const SizedBox(width: 10),
                        // Break Time
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () async {
                              await _showTimePicker(
                                context: context,
                                initialValue: set['breakTime'] ?? {'minutes': 0, 'seconds': 0},
                                onSelected: (minutes, seconds) {
                                  setState(() {
                                    sets[index]['breakTime'] = {'minutes': minutes, 'seconds': seconds};
                                  });
                                  widget.onSetsUpdated(sets);
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
                                '${set['breakTime']['minutes']} min ${set['breakTime']['seconds']} sec',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
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