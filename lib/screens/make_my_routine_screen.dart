// lib/screens/make_my_routine_screen.dart
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/routine_storage_service.dart';
import '../widgets/exercise_input.dart';
import '../widgets/exercise_list_item.dart';


class MakeMyRoutineScreen extends StatefulWidget {
  const MakeMyRoutineScreen({super.key});

  @override
  State<MakeMyRoutineScreen> createState() => _MakeMyRoutineScreenState();
}

class _MakeMyRoutineScreenState extends State<MakeMyRoutineScreen> {
  final List<Exercise> _exercises = [];
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  final RoutineStorageService _storageService = RoutineStorageService();

  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutine() async {
    List<Exercise> loadedExercises = await _storageService.loadRoutine();
    setState(() {
      _exercises.addAll(loadedExercises);
    });
  }

  void _addExercise() {
    String exerciseName = _exerciseController.text.trim();
    String setsText = _setsController.text.trim();
    String repsText = _repsController.text.trim();

    if (exerciseName.isEmpty || setsText.isEmpty || repsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    int? sets = int.tryParse(setsText);
    int? reps = int.tryParse(repsText);

    if (sets == null || reps == null || sets <= 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 세트 수와 반복 횟수를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _exercises.add(Exercise(name: exerciseName, sets: sets, reps: reps));
      _exerciseController.clear();
      _setsController.clear();
      _repsController.clear();
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveRoutine() async {
    await _storageService.saveRoutine(_exercises);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('루틴이 저장되었습니다!')),
    );
  }

  Future<void> _clearRoutine() async {
    await _storageService.clearRoutine();
    setState(() {
      _exercises.clear();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('루틴이 초기화되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make My Routine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRoutine,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearRoutine,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '운동 루틴을 작성하세요.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ExerciseInput(
              nameController: _exerciseController,
              setsController: _setsController,
              repsController: _repsController,
              onAdd: _addExercise,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _exercises.isEmpty
                  ? const Center(child: Text('추가된 운동이 없습니다.'))
                  : ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return ExerciseListItem(
                    exercise: exercise,
                    index: index,
                    onDelete: () => _removeExercise(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}