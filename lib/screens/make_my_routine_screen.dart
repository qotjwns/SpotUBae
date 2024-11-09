import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/routine_storage_service.dart';
import '../widgets/exercise_card.dart';

class MakeMyRoutineScreen extends StatefulWidget {
  const MakeMyRoutineScreen({super.key});

  @override
  State<MakeMyRoutineScreen> createState() => _MakeMyRoutineScreenState();
}

class _MakeMyRoutineScreenState extends State<MakeMyRoutineScreen> {
  final List<Exercise> _exercises = [];
  final RoutineStorageService _storageService = RoutineStorageService();

  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  Future<void> _loadRoutine() async {
    List<Exercise> loadedExercises = await _storageService.loadRoutine();
    setState(() {
      if (loadedExercises.isEmpty) {
        _exercises.add(Exercise(
          name: "새 운동",
          sets: [],
          recentRecord: '20kg x 10회', // 초기값
          recommendedRecord: '25kg x 10회', // 초기값
        ));
      } else {
        _exercises.addAll(loadedExercises);
      }
    });
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
    _saveRoutine(); // 운동 항목이 추가될 때마다 저장
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
    _saveRoutine(); // 운동 항목이 삭제될 때마다 저장
  }

  Future<void> _saveRoutine() async {
    await _storageService.saveRoutine(_exercises);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('루틴이 저장되었습니다!')),
    );
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
    _saveRoutine(); // 세트가 수정될 때마다 저장
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text('My Routine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, size: 30,),
            onPressed: _saveRoutine,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return Column(
            children: [
              ExerciseCard(
                exercise: exercise,
                onDelete: () => _removeExercise(index),
                onSetsUpdated: (sets) => _updateSets(index, sets),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add, color: Colors.grey,),
                label: const Text("Add", style: TextStyle(color: Colors.black),),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20), // 다음 카드와의 간격
            ],
          );
        },
      ),
    );
  }
}
