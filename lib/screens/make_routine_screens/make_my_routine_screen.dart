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
  final List<Exercise>? initialExercises; // 초기 운동 리스트

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

  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  Future<void> _loadRoutine() async {
    if (widget.initialExercises != null &&
        widget.initialExercises!.isNotEmpty) {
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
          ));
        } else {
          _exercises.addAll(loadedExercises);
        }
      });
    }
  }

  // 운동 추가 메서드 수정: 이름을 매개변수로 받음
  void _addExercise(String name) {
    setState(() {
      _exercises.add(Exercise(
        id: UniqueKey().toString(),
        name: name,
        sets: [],
        notes: null,
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveAllExercises() async {
    print('Saving all exercises...');
    await _storageService.saveRoutine(_exercises);
    print('Routine saved.');
    await _saveExerciseLog(); // 운동 기록 저장
    print('Exercise log saved.');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All exercises have been saved!')),
    );

    // 홈 화면으로 이동
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
    print('Saving exercise log for $dateOnly...');
    await _logStorageService.saveExerciseLog(log);
    print("Exercise log has been saved: ${log.toJson()}");
  }

  void _updateSets(int index, List<Map<String, int>> sets) {
    setState(() {
      _exercises[index] = Exercise(
        id: _exercises[index].id,
        // 기존 ID 유지
        name: _exercises[index].name,
        sets: sets,
        notes: _exercises[index].notes,
      );
    });
  }

  // 타이머 관련 메서드들
  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _remainingTime = _timerDuration;
    });
    _countDown();
  }

  void _cancelTimer() {
    setState(() {
      _isTimerRunning = false;
      _remainingTime = _timerDuration;
    });
  }

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
  }

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('sounds/timer_end.mp3'));
  }

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
  }

  // 드래그 앤 드롭 순서 변경을 처리하는 메서드
  void _onReorder(int oldIndex, int newIndex) {
    // "Add" 버튼은 마지막 인덱스이므로, 이를 포함하지 않도록 조건 설정
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
      );
    });
  }

  // 뒤로가기 버튼과 저장 버튼에서 동일한 AlertDialog를 표시하는 메서드
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
              Navigator.of(context).pop('exit'); // 저장하지 않고 나가기
            },
            child: const Text('Exit without Saving'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop('save'); // 저장 후 나가기
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
      return false; // _saveAllExercises가 이미 네비게이션을 처리하므로 추가 팝을 막음
    } else if (result == 'exit') {
      // 저장하지 않고 나가기: 캘린더 저장 없이 홈 화면으로 이동
      Navigator.of(context).popUntil((route) => route.isFirst);
      return false; // 추가 팝을 막음
    } else {
      return false; // 취소, 네비게이션 막음
    }
  }

  // 운동 이름을 입력받는 Dialog 표시 메서드
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
                // 저장 버튼을 눌렀을 때 동일한 AlertDialog 표시
                final result = await _showExitConfirmationDialog();
                if (result) {
                  // 사용자가 'Exit without Saving'을 선택한 경우 추가 동작이 필요하면 여기에 구현
                  // 현재는 아무 작업도 하지 않음
                }
              },
            ),
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
                              // ExerciseCard에 키 제거
                              exercise: exercise,
                              onDelete: () => _removeExercise(index),
                              onSetsUpdated: (sets) => _updateSets(index, sets),
                              onSave: () async {
                                // ExerciseCard 내부에서도 동일한 AlertDialog 표시
                                await _showExitConfirmationDialog();
                              },
                              onNotesUpdated: (notes) =>
                                  _updateNotes(index, notes), // 메모 업데이트 콜백 추가
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
