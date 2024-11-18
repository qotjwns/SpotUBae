// workout_selection_screen.dart

import 'package:flutter/material.dart';
import '../storage_service.dart';

class WorkoutSelectionScreen extends StatefulWidget {
  final String workoutType;  // 운동 부위 (예: chest, back, shoulder 등)

  const WorkoutSelectionScreen({super.key, required this.workoutType});

  @override
  State<WorkoutSelectionScreen> createState() => _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState extends State<WorkoutSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storageService = StorageService();

  List<String> _filteredWorkouts = [];
  Set<String> _selectedWorkouts = {};
  String _selectedCategory = "recommendation";  // 기본 카테고리 설정 (recommendation)

  List<String> _recommendationWorkouts = [];
  List<String> _currentWorkoutCategoryWorkouts = [];  // 현재 선택된 부위의 운동 목록

  @override
  void initState() {
    super.initState();
    _loadWorkouts(widget.workoutType);  // 해당 부위에 맞는 운동 목록 로드
  }

  // 운동 부위에 맞는 운동 종목을 로드
  Future<void> _loadWorkouts(String workoutType) async {
    // 해당 부위의 운동 목록 로드
    List<String> categoryWorkouts = _storageService.getWorkoutsByCategory(workoutType);
    _currentWorkoutCategoryWorkouts = categoryWorkouts;

    // recommendation 운동 목록 로드 (챗봇에서 얻은 운동 목록)
    List<String> recommendationWorkouts = await _storageService.loadExercisesFromDownload("recommendation");
    _recommendationWorkouts = recommendationWorkouts;

    // 초기 필터 적용
    _updateFilteredWorkouts();
  }

  // 운동 종목을 검색해서 필터링
  void _filterWorkouts(String query) {
    _updateFilteredWorkouts(query: query);
  }

  // 필터링 로직을 분리하여 재사용
  void _updateFilteredWorkouts({String query = ''}) {
    List<String> workoutsToFilter;

    if (_selectedCategory == "recommendation") {
      // recommendation에서는 추출된 운동 목록과 부위 운동 목록에서 일치하는 것만 표시
      workoutsToFilter = _recommendationWorkouts
          .where((workout) => _currentWorkoutCategoryWorkouts.contains(workout))
          .toList();
    } else {
      // 해당 부위 운동 목록에서만 필터링
      workoutsToFilter = List.from(_currentWorkoutCategoryWorkouts);
    }

    if (query.isNotEmpty) {
      workoutsToFilter = workoutsToFilter
          .where((workout) => workout.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredWorkouts = workoutsToFilter;
    });
  }

  // 카테고리 선택 시 해당 운동 목록 업데이트
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _filterWorkouts(_searchController.text);  // 현재 검색어로 필터링
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("루틴 만들기 - ${_capitalize(widget.workoutType)}"),
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
          // 운동 부위 선택 필터 (Recommendation과 해당 부위 버튼만)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(child: _buildCategoryButton("recommendation", "추천")),
                SizedBox(width: 8),
                Expanded(child: _buildCategoryButton(widget.workoutType, _capitalize(widget.workoutType))),
              ],
            ),
          ),
          Expanded(
            child: _filteredWorkouts.isNotEmpty
                ? ListView.builder(
              itemCount: _filteredWorkouts.length,
              itemBuilder: (context, index) {
                final workout = _filteredWorkouts[index];
                return ListTile(
                  title: Text(workout),
                  leading: Checkbox(
                    value: _selectedWorkouts.contains(workout),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedWorkouts.add(workout);
                        } else {
                          _selectedWorkouts.remove(workout);
                        }
                      });
                    },
                  ),
                );
              },
            )
                : Center(
              child: Text("운동을 찾을 수 없습니다."),
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리 버튼을 생성하는 위젯
  Widget _buildCategoryButton(String category, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedCategory == category,
      onSelected: (_) {
        _onCategorySelected(category);  // 카테고리 선택 시 동작 처리
      },
    );
  }

  // 문자열의 첫 글자를 대문자로 변환
  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
