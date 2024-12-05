import 'package:flutter/material.dart';
import 'package:group_app/screens/make_routine_screens/make_my_routine_screen.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../models/exercise.dart';

class WorkoutSelectionScreen extends StatefulWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  State<WorkoutSelectionScreen> createState() => _WorkoutSelectionScreenState();
}

class _WorkoutSelectionScreenState extends State<WorkoutSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  late StorageService _storageService;

  final List<String> _allCategories = [
    "recommendation",
    "bookmarks",
    "chest",
    "back",
    "shoulder",
    "legs",
    "arms",
    "abs",
    "cardio",
  ];

  List<String> _filteredWorkouts = [];
  Set<String> selectedWorkouts = {};
  String _selectedCategory = "recommendation";

  final Map<String, List<String>> _categoryWorkouts = {};
  Set<String> _bookmarkedWorkouts = {};

  bool _isInit = false; // To check if initialization has been done

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _storageService = Provider.of<StorageService>(context);
      _loadAllWorkouts(); // Load workout list
      _loadBookmarks(); // Load bookmarked workouts
      _isInit = true;
    }
  }

  Future<void> _loadAllWorkouts() async {
    for (String category in _allCategories) {
      if (category == "bookmarks") {
        // Bookmarks are managed separately
        continue;
      }
      List<String> workouts =
          await _storageService.loadExercisesFromDownload(category);
      _categoryWorkouts[category] = workouts;
      print("Loaded workouts for $category: $workouts"); // Debugging
    }
    _updateFilteredWorkouts();
  }

  Future<void> _loadBookmarks() async {
    List<String> bookmarks = await _storageService.loadBookmarks();
    setState(() {
      _bookmarkedWorkouts = bookmarks.toSet();
    });
    print("Loaded bookmarks: $_bookmarkedWorkouts"); // Debugging
  }

  void _filterWorkouts(String query) {
    _updateFilteredWorkouts(query: query);
  }

  void _updateFilteredWorkouts({String query = ''}) {
    List<String> workoutsToFilter;
    if (_selectedCategory == "bookmarks") {
      workoutsToFilter = _bookmarkedWorkouts.toList();
    } else {
      workoutsToFilter = _categoryWorkouts[_selectedCategory] ?? [];
    }
    print(
        "Category: $_selectedCategory, Workouts: $workoutsToFilter"); // Debugging

    if (query.isNotEmpty) {
      workoutsToFilter = workoutsToFilter
          .where(
              (workout) => workout.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print(
          "Filtered Workouts with query '$query': $workoutsToFilter"); // Debugging
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
      bool isCardio = _storageService.cardioWorkouts.contains(workoutName);
      return Exercise(
        id: UniqueKey().toString(),
        name: workoutName,
        sets: [],
        notes: null,
        isCardio: isCardio, // isCardio 설정
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

  void _toggleBookmark(String workout) async {
    setState(() {
      if (_bookmarkedWorkouts.contains(workout)) {
        _bookmarkedWorkouts.remove(workout);
      } else {
        _bookmarkedWorkouts.add(workout);
      }
    });
    await _storageService.saveBookmarks(_bookmarkedWorkouts.toList());
    print("Updated bookmarks: $_bookmarkedWorkouts"); // Debugging
  }

  void _resetRecommendation() async {
    bool confirm = await _showConfirmationDialog(
      context,
      'Reset Recommendation',
      'Do you want to reset the recommendation exercise list?',
    );

    if (confirm) {
      // Reset to default recommendation exercises
      List<String> defaultRecommendations = [
        // Add default recommendation exercises here
        // Example:
        // "Push Up",
        // "Pull Up",
        // "Squat",
      ];
      await _storageService.setExercisesToDownload(
          defaultRecommendations, "recommendation");
      await _loadAllWorkouts(); // Reload workout list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Recommendation exercise list has been reset.')),
      );
    }
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select your Exercises"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetRecommendation,
            tooltip: 'Reset Recommendation',
          ),
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: selectedWorkouts.isNotEmpty
                ? _navigateToMakeMyRoutineScreen
                : null,
            tooltip: 'Create Routine',
          ),
        ],
      ),
      body: Column(
        children: [
          // Exercise search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterWorkouts,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search Exercises...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Category selection filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _allCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: category == "bookmarks"
                          ? Tooltip(
                              message: "Bookmarks",
                              child: Icon(Icons.bookmark),
                            )
                          : Text(_capitalize(category)),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        _onCategorySelected(category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Workout list
          Expanded(
            child: _filteredWorkouts.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredWorkouts.length,
                    itemBuilder: (context, index) {
                      final workout = _filteredWorkouts[index];
                      bool isBookmarked = _bookmarkedWorkouts.contains(workout);
                      bool isSelected = selectedWorkouts.contains(workout);
                      return ListTile(
                        title: Text(workout),
                        leading: Checkbox(
                          value: isSelected,
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
                        trailing: IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked ? Colors.black : null,
                          ),
                          onPressed: () {
                            _toggleBookmark(workout);
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedWorkouts.remove(workout);
                            } else {
                              selectedWorkouts.add(workout);
                            }
                          });
                        },
                      );
                    },
                  )
                : const Center(
                    child: Text("No exercises found."),
                  ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}
