import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../../models/exercise.dart';
import '../logs/exercise_log.dart';
import '../../services/routine_storage_service.dart';
import '../../services/exercise_log_storage_service.dart';
import '../../widgets/widget_for_make_routine/exercise_card.dart';

class MakeMyRoutineScreen extends StatefulWidget {
  final List<Exercise>?
  initialExercises; //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  const MakeMyRoutineScreen({super.key, this.initialExercises});

  @override
  State<MakeMyRoutineScreen> createState() => _MakeMyRoutineScreenState();
}

class _MakeMyRoutineScreenState extends State<MakeMyRoutineScreen> {
  List<Exercise> _exercises = [];
  final RoutineStorageService _storageService = RoutineStorageService();
  final ExerciseLogStorageService _logStorageService =
  ExerciseLogStorageService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _timerDuration = const Duration(minutes: 1);
  bool _isTimerRunning = false;
  Duration _remainingTime = const Duration();

  // 기본 시간 변수 추가
  Duration _defaultWorkoutTime = const Duration(minutes: 5);
  Duration _defaultBreakTime = const Duration(minutes: 1);

  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  Future<void> _loadRoutine() async {
    if (widget.initialExercises != null && widget.initialExercises!.isNotEmpty) {
      setState(() {
        _exercises = List<Exercise>.from(widget.initialExercises!);
      });
    } else {
      List<Exercise> loadedExercises = await _storageService.loadRoutine();
      setState(() {
        if (loadedExercises.isEmpty) {
          _exercises.add(Exercise(
            id: UniqueKey().toString(),
            name: "New Workout",
            sets: [],
            notes: null,
            isCardio: _isCardioExercise("New Workout"),
          ));
        } else {
          _exercises = loadedExercises;
        }
      });
    }
  }


  void _addExercise(String name) {
    setState(() {
      _exercises.add(Exercise(
        id: UniqueKey().toString(),
        name: name,
        sets: [],
        notes: null,
        isCardio: _isCardioExercise(name), // isCardio 설정
      ));
    });
  }


  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveAllExercises() async {
    await _storageService.saveRoutine(_exercises);
    await _saveExerciseLog();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All exercises have been saved!')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _saveExerciseLog() async {
    DateTime now = DateTime.now();
    DateTime dateOnly = DateTime(now.year, now.month, now.day);
    DateTime timestamp = now;

    ExerciseLog log = ExerciseLog(
      date: dateOnly,
      timestamp: timestamp,
      exercises: _exercises,
    );
    await _logStorageService.saveExerciseLog(log);
  }

  void _updateSets(int index, List<Map<String, dynamic>> sets) {
    setState(() {
      _exercises[index] = Exercise(
        id: _exercises[index].id,
        name: _exercises[index].name,
        sets: sets,
        notes: _exercises[index].notes,
        isCardio: _exercises[index].isCardio, // isCardio 유지
      );
    });
  }


  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _remainingTime = _timerDuration;
    });
    _countDown();
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  void _cancelTimer() {
    setState(() {
      _isTimerRunning = false;
      _remainingTime = _timerDuration;
    });
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  void _countDown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_remainingTime > const Duration(seconds: 1) && _isTimerRunning) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
        _countDown();
      } else if (_isTimerRunning) {
        setState(() {
          _isTimerRunning = false;
        });
        _playSound();
      }
    });
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('sounds/timer_end.mp3'));
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  void _showTimerPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 250,
        child: CupertinoTimerPicker(
          initialTimerDuration: _timerDuration,
          mode: CupertinoTimerPickerMode.ms,
          onTimerDurationChanged: (Duration newDuration) {
            setState(() {
              _timerDuration = newDuration;
              _remainingTime = newDuration;
            });
          },
        ),
      ),
    );
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex >= _exercises.length || newIndex > _exercises.length) return;

    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Exercise movedExercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, movedExercise);
    });
  }

  void _updateNotes(int index, String? newNotes) {
    setState(() {
      _exercises[index] = Exercise(
        id: _exercises[index].id,
        name: _exercises[index].name,
        sets: _exercises[index].sets,
        notes: newNotes,
        isCardio: _exercises[index].isCardio, // isCardio 유지
      );
    });
  }

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Do you want to exit?'),
        content: const Text('Do you want to save the changes?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop('exit');
            },
            child: const Text('Exit without Saving'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop('save');
            },
            child: const Text('Save and Exit'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop('cancel'); // 취소
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result == 'save') {
      await _saveAllExercises();
      return false;
    } else if (result == 'exit') {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return false;
    } else {
      return false;
    }
  }

  Future<void> _showAddExerciseDialog() async {
    String exerciseName = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Exercise Name'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter exercise name',
            ),
            onChanged: (value) {
              exerciseName = value;
            },
            onSubmitted: (value) {
              exerciseName = value;
              Navigator.of(context).pop();
            },
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
                if (exerciseName.trim().isNotEmpty) {
                  Navigator.of(context).pop(); // 입력 완료
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (exerciseName.trim().isNotEmpty) {
      _addExercise(exerciseName.trim());
    }
  }

  bool _isCardioExercise(String exerciseName) {
    List<String> cardioExercises = [
      "Running",
      "Cycling",
      "Jump Rope",
      "Burpees",
      "Mountain Climbers",
      "High Knees",
      "Boxing",
      "Swimming",
      "Jumping Jacks",
      "Sprints",
      "Treadmill Incline Walking",
      // 추가적인 Cardio 운동 이름들
    ];

    return cardioExercises.contains(exerciseName);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: const Text(
            'My Routine',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.save, size: 30),
                onPressed: () async {
                  await _showExitConfirmationDialog();
                }),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _exercises.length + 1,
                // 운동 리스트 + "Add" 버튼
                onReorder: _onReorder,
                buildDefaultDragHandles: false,
                // 커스텀 드래그 핸들을 사용하기 위해 false로 설정
                itemBuilder: (context, index) {
                  if (index < _exercises.length) {
                    final exercise = _exercises[index];
                    return Dismissible(
                      key: ValueKey('dismissible_${exercise.id}'),
                      // 최상위 위젯에만 고유 키 사용
                      direction: DismissDirection.endToStart,
                      // 왼쪽으로 슬라이드만 허용
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) => _removeExercise(index),
                      child: Row(
                        // key는 Dismissible에만 설정, Row에는 제거
                        children: [
                          // 드래그 핸들 추가
                          ReorderableDragStartListener(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.drag_handle),
                            ),
                          ),
                          Expanded(
                            child: ExerciseCard(
                              exercise: exercise,
                              onDelete: () => _removeExercise(index),
                              onSetsUpdated: (sets) => _updateSets(index, sets),
                              onSave: () async {
                                await _showExitConfirmationDialog();
                              },
                              onNotesUpdated: (notes) => _updateNotes(index, notes),
                              isCardio: exercise.isCardio, // isCardio 전달
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // "Add New Workout" 버튼
                    return Padding(
                      key: const ValueKey('add_button'), // "Add" 버튼에 고유 키 설정
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: _showAddExerciseDialog, // 버튼 눌렀을 때 Dialog 표시
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Workout'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50), // 버튼 높이 설정
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            // 타이머 위젯
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_timerDuration == const Duration(minutes: 0)) ...[
                        // 초기 상태: 타이머가 설정되지 않았을 때
                        ElevatedButton(
                          onPressed: _showTimerPicker,
                          child: const Text("Set Timer"),
                        ),
                      ] else ...[
                        // 타이머가 설정된 후 표시
                        Text(
                          _isTimerRunning
                              ? "Remaining Time: ${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}"
                              : "Set Time: ${_timerDuration.inMinutes}:${(_timerDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            // 타이머 시작/취소 버튼
                            ElevatedButton(
                              onPressed:
                              _isTimerRunning ? _cancelTimer : _startTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                _isTimerRunning ? Colors.red : Colors.green,
                                minimumSize: const Size(50, 36),
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: Text(_isTimerRunning ? "Stop" : "Start"),
                            ),
                            const SizedBox(width: 8),
                            // 시간 설정 버튼
                            ElevatedButton(
                              onPressed: _showTimerPicker,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(50, 36),
                                padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text("Set"),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}