import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/exercise.dart';
import '../models/exercise_log.dart';
import '../services/routine_storage_service.dart';
import '../services/exercise_log_storage_service.dart'; // 추가
import '../widgets/widget_for_make_routine/exercise_card.dart';

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
  ExerciseLogStorageService(); // 추가
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
        _exercises = widget.initialExercises!;
      });
    } else {
      List<Exercise> loadedExercises = await _storageService.loadRoutine();
      setState(() {
        if (loadedExercises.isEmpty) {
          _exercises.add(Exercise(
            name: "새 운동",
            sets: [],
            recentRecord: '20kg x 10회',
            recommendedRecord: '25kg x 10회',
          ));
        } else {
          _exercises.addAll(loadedExercises);
        }
      });
    }
  }

  void _addExercise() {
    setState(() {
      _exercises.add(Exercise(
        name: "새 운동",
        sets: [],
        recentRecord: '20kg x 10회',
        recommendedRecord: '25kg x 10회',
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
    await _saveExerciseLog(); // 운동 기록 저장

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모든 운동이 저장되었습니다!')),
    );

    // 홈 화면으로 이동
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _saveExerciseLog() async {
    DateTime now = DateTime.now();
    DateTime dateOnly = DateTime(now.year, now.month, now.day);

    ExerciseLog log = ExerciseLog(
      date: dateOnly,
      exercises: _exercises,
    );
    await _logStorageService.saveExerciseLog(log);
    print("운동 기록이 저장되었습니다: ${log.toJson()}");
  }

  Future<void> _saveExercise(int index) async {
    await _storageService.saveRoutine(_exercises);
  }

  void _updateSets(int index, List<Map<String, int>> sets) {
    setState(() {
      _exercises[index] = Exercise(
        name: _exercises[index].name,
        sets: sets,
        recentRecord: _exercises[index].recentRecord,
        recommendedRecord: _exercises[index].recommendedRecord,
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
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Exercise movedExercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, movedExercise);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          'My Routine',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 30),
            onPressed: _saveAllExercises, // 저장 후 홈 화면으로 이동
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exercises.length,
              onReorder: _onReorder,
              buildDefaultDragHandles: false, // 커스텀 드래그 핸들을 사용하기 위해 false로 설정
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                return Dismissible(
                  key: ValueKey(exercise), // 각 아이템에 고유한 키 부여
                  background: Container(color: Colors.red),
                  onDismissed: (_) => _removeExercise(index),
                  child: ExerciseCard(
                    exercise: exercise,
                    onDelete: () => _removeExercise(index),
                    onSetsUpdated: (sets) => _updateSets(index, sets),
                    onSave: () => _saveExercise(index),),
                );
              },
            ),
          ),
          // 타이머 위젯
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_timerDuration == const Duration(minutes: 0)) ...[
                      // 초기 상태: 타이머가 설정되지 않았을 때
                      ElevatedButton(
                        onPressed: _showTimerPicker,
                        child: const Text("Timer 설정"),
                      ),
                    ] else ...[
                      // 타이머가 설정된 후 표시
                      Text(
                        _isTimerRunning
                            ? "남은 시간: ${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}"
                            : "설정된 시간: ${_timerDuration.inMinutes}:${(_timerDuration.inSeconds % 60).toString().padLeft(2, '0')}",
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
                            child: Text(_isTimerRunning ? "중지" : "시작"),
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
                            child: const Text("설정"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}