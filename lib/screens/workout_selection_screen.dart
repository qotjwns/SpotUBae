import 'package:flutter/material.dart';
import 'package:group_app/screens/make_my_routine_screen.dart';
import '../services/storage_service.dart';
import '../models/exercise.dart';

class WorkoutSelectionScreen extends StatefulWidget {
  final String workoutType; // 운동 부위

  const WorkoutSelectionScreen({super.key, required this.workoutType});

  @override
  State<WorkoutSelectionScreen> createState() => _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState extends State<WorkoutSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storageService = StorageService();

  List<String> _filteredWorkouts = [];
  Set<String> selectedWorkouts = {};
  String _selectedCategory = "recommendation"; // 기본 카테고리 설정

  List<String> _recommendationWorkouts = [];
  List<String> _currentWorkoutCategoryWorkouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts(widget.workoutType); // 운동 목록 로드
  }

  Future<void> _loadWorkouts(String workoutType) async {
    List<String> categoryWorkouts =
    _storageService.getWorkoutsByCategory(workoutType);
    _currentWorkoutCategoryWorkouts = categoryWorkouts;

    List<String> recommendationWorkouts =
    await _storageService.loadExercisesFromDownload("recommendation");
    _recommendationWorkouts = recommendationWorkouts;

    _updateFilteredWorkouts();
  }

  void _filterWorkouts(String query) {
    _updateFilteredWorkouts(query: query);
  }

  void _updateFilteredWorkouts({String query = ''}) {
    List<String> workoutsToFilter;

    if (_selectedCategory == "recommendation") {
      workoutsToFilter = _recommendationWorkouts
          .where((workout) => _currentWorkoutCategoryWorkouts.contains(workout))
          .toList();
    } else {
      workoutsToFilter = List.from(_currentWorkoutCategoryWorkouts);
    }

    if (query.isNotEmpty) {
      workoutsToFilter = workoutsToFilter
          .where(
              (workout) => workout.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredWorkouts = workoutsToFilter;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterWorkouts(_searchController.text);
    });
  }

  void _navigateToMakeMyRoutineScreen() {
    List<Exercise> selectedExercises = selectedWorkouts.map((workoutName) {
      return Exercise(
        name: workoutName,
        sets: [],
        recentRecord: '0kg x 0회',
        recommendedRecord: '0kg x 0회',
      );
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MakeMyRoutineScreen(
          initialExercises: selectedExercises,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("루틴 만들기 - ${_capitalize(widget.workoutType)}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: selectedWorkouts.isNotEmpty
                ? _navigateToMakeMyRoutineScreen
                : null, // 선택된 운동이 있을 때만 활성화
          ),
        ],
      ),
      body: Column(
        children: [
          // 운동 검색 필드
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterWorkouts,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "운동 검색...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // 카테고리 선택 필터
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildCategoryButton("recommendation", "추천"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCategoryButton(
                    widget.workoutType,
                    _capitalize(widget.workoutType),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 운동 리스트
          Expanded(
            child: _filteredWorkouts.isNotEmpty
                ? ListView.builder(
              itemCount: _filteredWorkouts.length,
              itemBuilder: (context, index) {
                final workout = _filteredWorkouts[index];
                return ListTile(
                  title: Text(workout),
                  tileColor: selectedWorkouts.contains(workout)
                      ? Colors.grey.withOpacity(0.1)
                      : null,
                  onTap: () {
                    setState(() {
                      if (selectedWorkouts.contains(workout)) {
                        selectedWorkouts.remove(workout);
                      } else {
                        selectedWorkouts.add(workout);
                      }
                    });
                  },
                  trailing: Checkbox(
                    value: selectedWorkouts.contains(workout),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedWorkouts.add(workout);
                        } else {
                          selectedWorkouts.remove(workout);
                        }
                      });
                    },
                  ),
                );
              },
            )
                : const Center(
              child: Text("운동을 찾을 수 없습니다."),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedCategory == category,
      onSelected: (_) {
        _onCategorySelected(category);
      },
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}