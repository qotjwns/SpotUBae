// lib/screens/workout_selection_screen.dart
import 'package:flutter/material.dart';
import '../storage_service.dart';
import 'make_my_routine_screen.dart'; // 챗봇 추천 운동 데이터 로드 함수 포함

class WorkoutSelectionScreen extends StatefulWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  State<WorkoutSelectionScreen> createState() => _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState extends State<WorkoutSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storageService = StorageService();

  List<String> _filteredWorkouts = [];
  Set<String> _selectedWorkouts = {};
  String _selectedCategory = "recommendation";

  List<String> _recommendationWorkouts = [];
  List<String> _chestWorkouts = [
    "Bench Press", "Incline Bench Press", "Dumbbell Bench Press", "Push up"
  ];

  @override
  void initState() {
    super.initState();
    _loadRecommendationWorkouts();
  }

  // recommendation 카테고리의 운동 종목을 로드
  Future<void> _loadRecommendationWorkouts() async {
    String workoutType = "CHEST";  // recommendation 운동 종목은 CHEST에서 로드
    List<String> workouts = await _storageService.loadExercisesFromDownload(workoutType);

    setState(() {
      _recommendationWorkouts = workouts;
      _filteredWorkouts = _recommendationWorkouts; // 운동 종목을 화면에 바로 표시
    });
  }

  // 검색어로 운동 종목 필터링
  void _filterWorkouts(String query) {
    setState(() {
      if (_selectedCategory == "recommendation") {
        _filteredWorkouts = _recommendationWorkouts
            .where((workout) => workout.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else if (_selectedCategory == "chest") {
        _filteredWorkouts = _chestWorkouts
            .where((workout) => workout.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // 운동 종목을 저장하고 recommendation에만 표시
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;

      if (_selectedCategory == "recommendation") {
        _loadRecommendationWorkouts(); // recommendation 카테고리로 전환 시 운동 종목 로드
      } else if (_selectedCategory == "chest") {
        _filteredWorkouts = _chestWorkouts; // chest 카테고리 운동 종목 표시
      }

      _filterWorkouts(_searchController.text); // 필터링된 운동 목록 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make your Routine"),
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
                hintText: "Search workouts...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // 운동 부위 선택 필터 (예: Recommendation, Chest 등)
          Row(
            children: [
              _buildCategoryButton("recommendation", "Recommendation"),
              _buildCategoryButton("chest", "Chest"),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredWorkouts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredWorkouts[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.bookmark_border),
                    onPressed: () {
                      // 북마크 기능 추가
                    },
                  ),
                  leading: Checkbox(
                    value: _selectedWorkouts.contains(_filteredWorkouts[index]),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedWorkouts.add(_filteredWorkouts[index]);
                        } else {
                          _selectedWorkouts.remove(_filteredWorkouts[index]);
                        }
                      });
                    },
                  ),
                );
              },
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
        _onCategorySelected(category);  // 카테고리 선택 시 동작 처리
      },
    );
  }
}
