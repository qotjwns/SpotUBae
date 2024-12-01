// lib/screens/program_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/program_user_data.dart';
import '../../services/program_user_data_service.dart';
import '../../widgets/widgets_for_program_screen/age_input_field.dart';
import '../../widgets/widgets_for_program_screen/buttons_row.dart';
import '../../widgets/widgets_for_program_screen/current_body_fat_input_field.dart';
import '../../widgets/widgets_for_program_screen/current_weight_input_field.dart';
import '../../widgets/widgets_for_program_screen/expected_results_display.dart';
import '../../widgets/widgets_for_program_screen/gender_selection.dart';
import '../../widgets/widgets_for_program_screen/goal_body_fat_input_field.dart';
import '../../widgets/widgets_for_program_screen/goal_weight_input_field.dart';
import '../../widgets/widgets_for_program_screen/height_input_field.dart';
import '../../widgets/widgets_for_program_screen/macro_results_display.dart';
import '../../widgets/widgets_for_program_screen/reset_confirmation_dialog.dart';


class ProgramScreen extends StatefulWidget {
  final String programType; // "Bulking" or "Cutting"

  const ProgramScreen({super.key, required this.programType});

  @override
  ProgramScreenState createState() => ProgramScreenState();
}

class ProgramScreenState extends State<ProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _currentWeightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _currentBodyFatController = TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _goalBodyFatController = TextEditingController();

  String _gender = 'male'; // Default gender setting

  double? dailyCalories;
  double? protein;
  double? fat;
  double? carbs;
  double? expectedWeight1Week;
  double? expectedBodyFat1Week;
  double? expectedWeight1Month;
  double? expectedBodyFat1Month;

  // 로딩 상태를 관리하기 위한 변수
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 사용자 데이터를 로드하는 메서드
  Future<void> _loadUserData() async {
    final programUserDataService = Provider.of<ProgramUserDataService>(context, listen: false);
    await programUserDataService.loadProgramUserData();

    if (programUserDataService.currentProgramType == widget.programType && programUserDataService.currentProgramData != null) {
      final data = programUserDataService.currentProgramData!;
      _ageController.text = data.age.toString();
      _gender = data.gender;
      _currentWeightController.text = data.currentWeight.toString();
      _heightController.text = data.height.toString();
      _currentBodyFatController.text = data.currentBodyFat.toString();
      _goalWeightController.text = data.goalWeight.toString();
      _goalBodyFatController.text = data.goalBodyFat.toString();

      // Calculate results based on existing data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateMacrosAndExpectations();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _currentWeightController.dispose();
    _heightController.dispose();
    _currentBodyFatController.dispose();
    _goalWeightController.dispose();
    _goalBodyFatController.dispose();
    super.dispose();
  }

  void _calculateMacrosAndExpectations() {
    double currentWeight = double.tryParse(_currentWeightController.text) ?? 0.0;
    double height = double.tryParse(_heightController.text) ?? 0.0;
    double currentBodyFat = double.tryParse(_currentBodyFatController.text) ?? 0.0;
    double goalWeight = double.tryParse(_goalWeightController.text) ?? 0.0;
    double goalBodyFat = double.tryParse(_goalBodyFatController.text) ?? 0.0;
    int age = int.tryParse(_ageController.text) ?? 25;
    String gender = _gender;

    // Calculate BMR using the Mifflin-St Jeor Equation
    double bmr;
    if (gender == 'male') {
      bmr = 10 * currentWeight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * currentWeight + 6.25 * height - 5 * age - 161;
    }

    // Calculate TDEE assuming moderately active
    double tdee = bmr * 1.55;

    // Adjust calories based on program type
    double calorieAdjustment;
    if (widget.programType == 'Bulking') {
      calorieAdjustment = tdee + 500;
    } else {
      calorieAdjustment = tdee - 500;
    }

    // Calculate macros
    protein = currentWeight * 2.0; // Protein 2g/kg
    fat = currentWeight * 0.8; // Fat 0.8g/kg
    carbs = (calorieAdjustment - (protein! * 4 + fat! * 9)) / 4;

    // Calculate total change required
    double totalWeightChange = goalWeight - currentWeight;
    double totalBodyFatChange = goalBodyFat - currentBodyFat;

    // Set maximum weekly change
    const double maxWeeklyWeightChange = 0.5; // kg
    const double maxWeeklyBodyFatChange = 0.3; // %

    // Adjust weekly changes based on program type
    double weeklyWeightChange;
    double weeklyBodyFatChange;

    if (widget.programType == 'Bulking') {
      // Bulking: Increase weight
      weeklyWeightChange = (totalWeightChange > 0 ? (totalWeightChange).clamp(0.0, maxWeeklyWeightChange) : 0.0);

      // Bulking: Allow body fat to increase or decrease
      if (totalBodyFatChange > 0) {
        // Goal body fat is higher: allow increase
        weeklyBodyFatChange = (totalBodyFatChange).clamp(0.0, maxWeeklyBodyFatChange);
      } else if (totalBodyFatChange < 0) {
        // Goal body fat is lower: allow decrease
        weeklyBodyFatChange = (totalBodyFatChange).clamp(-maxWeeklyBodyFatChange, 0.0);
      } else {
        weeklyBodyFatChange = 0.0;
      }
    } else {
      // Cutting: Decrease weight
      weeklyWeightChange = (totalWeightChange < 0 ? (totalWeightChange).clamp(-maxWeeklyWeightChange, 0.0) : 0.0);

      // Cutting: Allow only body fat to decrease
      weeklyBodyFatChange = (totalBodyFatChange < 0 ? (totalBodyFatChange).clamp(-maxWeeklyBodyFatChange, 0.0) : 0.0);
    }

    // Calculate expected values after 1 week
    expectedWeight1Week = currentWeight + weeklyWeightChange;
    expectedBodyFat1Week = currentBodyFat + weeklyBodyFatChange;

    // Calculate expected values after 1 month (4 weeks)
    double monthlyWeightChange = weeklyWeightChange * 4;
    double monthlyBodyFatChange = weeklyBodyFatChange * 4;

    expectedWeight1Month = currentWeight + monthlyWeightChange;
    expectedBodyFat1Month = currentBodyFat + monthlyBodyFatChange;

    // Prevent exceeding goals
    if (widget.programType == 'Bulking') {
      // Bulking: Do not exceed target weight
      if (expectedWeight1Week! > goalWeight) {
        expectedWeight1Week = goalWeight;
      }
      if (expectedWeight1Month! > goalWeight) {
        expectedWeight1Month = goalWeight;
      }

      // Bulking: Handle body fat based on goal
      if (goalBodyFat > currentBodyFat) {
        // Allow up to goal body fat
        if (expectedBodyFat1Week! > goalBodyFat) {
          expectedBodyFat1Week = goalBodyFat;
        }
        if (expectedBodyFat1Month! > goalBodyFat) {
          expectedBodyFat1Month = goalBodyFat;
        }
      } else {
        // Allow down to goal body fat
        if (expectedBodyFat1Week! < goalBodyFat) {
          expectedBodyFat1Week = goalBodyFat;
        }
        if (expectedBodyFat1Month! < goalBodyFat) {
          expectedBodyFat1Month = goalBodyFat;
        }
      }
    } else {
      // Cutting: Do not go below target weight
      if (expectedWeight1Week! < goalWeight) {
        expectedWeight1Week = goalWeight;
      }
      if (expectedWeight1Month! < goalWeight) {
        expectedWeight1Month = goalWeight;
      }

      // Cutting: Do not go below target body fat
      if (expectedBodyFat1Week! < goalBodyFat) {
        expectedBodyFat1Week = goalBodyFat;
      }
      if (expectedBodyFat1Month! < goalBodyFat) {
        expectedBodyFat1Month = goalBodyFat;
      }
    }

    // 계산된 값들을 ProgramUserData에 포함
    setState(() {
      dailyCalories = calorieAdjustment;
    });
  }

  void _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      _calculateMacrosAndExpectations();

      ProgramUserData data = ProgramUserData(
        age: int.parse(_ageController.text),
        gender: _gender,
        currentWeight: double.parse(_currentWeightController.text),
        height: double.parse(_heightController.text),
        currentBodyFat: double.parse(_currentBodyFatController.text),
        goalWeight: double.parse(_goalWeightController.text),
        goalBodyFat: double.parse(_goalBodyFatController.text),
        programType: widget.programType,
        dailyCarbs: carbs ?? 0.0,
        dailyProtein: protein ?? 0.0,
        dailyFat: fat ?? 0.0,
      );

      await Provider.of<ProgramUserDataService>(context, listen: false).saveProgramUserData(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program saved successfully')),
      );
    }
  }

  /// Reset 기능 구현
  void _resetUserData() async {
    // ResetConfirmationDialog 표시
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ResetConfirmationDialog();
      },
    );

    if (confirm != null && confirm) {
      // 입력 필드 초기화
      _formKey.currentState?.reset();
      _ageController.clear();
      _currentWeightController.clear();
      _heightController.clear();
      _currentBodyFatController.clear();
      _goalWeightController.clear();
      _goalBodyFatController.clear();
      setState(() {
        _gender = 'male';
        dailyCalories = null;
        protein = null;
        fat = null;
        carbs = null;
        expectedWeight1Week = null;
        expectedBodyFat1Week = null;
        expectedWeight1Month = null;
        expectedBodyFat1Month = null;
      });

      // ProgramUserDataService에서 데이터 삭제
      await Provider.of<ProgramUserDataService>(context, listen: false).clearProgramUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information has been reset.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.programType} Program'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, // Real-time validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the entire Column
            children: [
              // Age input field
              AgeInputField(
                controller: _ageController,
                label: 'Age',
                suffix: 'years',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age.';
                  }
                  final int? age = int.tryParse(value);
                  if (age == null || age < 10 || age > 120) {
                    return 'Age must be between 10 and 120 years.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Gender selection field (Radio buttons)
              GenderSelection(
                selectedGender: _gender,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _gender = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              // Height input field
              HeightInputField(
                controller: _heightController,
                label: 'Height',
                suffix: 'cm',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height.';
                  }
                  final double? height = double.tryParse(value);
                  if (height == null || height < 100 || height > 200) {
                    return 'Height must be between 100cm and 200cm.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Current weight input field
              CurrentWeightInputField(
                controller: _currentWeightController,
                label: 'Current Weight',
                suffix: 'kg',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current weight.';
                  }
                  final double? weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 150) {
                    return 'Weight must be between 30kg and 150kg.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Current body fat percentage input field
              CurrentBodyFatInputField(
                controller: _currentBodyFatController,
                label: 'Current Body Fat Percentage',
                suffix: '%',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current body fat percentage.';
                  }
                  final double? bodyFat = double.tryParse(value);
                  if (bodyFat == null || bodyFat < 0 || bodyFat > 100) {
                    return 'Body fat percentage must be between 0% and 100%.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Goal weight input field
              GoalWeightInputField(
                controller: _goalWeightController,
                label: 'Goal Weight',
                suffix: 'kg',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your goal weight.';
                  }
                  final double? weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 150) {
                    return 'Goal weight must be between 30kg and 150kg.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Goal body fat percentage input field
              GoalBodyFatInputField(
                controller: _goalBodyFatController,
                label: 'Goal Body Fat Percentage',
                suffix: '%',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your goal body fat percentage.';
                  }
                  final double? bodyFat = double.tryParse(value);
                  if (bodyFat == null || bodyFat < 0 || bodyFat > 100) {
                    return 'Body fat percentage must be between 0% and 100%.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Save and Reset 버튼을 가로로 배치
              ButtonsRow(
                onSave: _saveUserData,
                onReset: _resetUserData,
              ),
              const SizedBox(height: 30),
              // Display calculation results
              if (dailyCalories != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center the entire Column
                  children: [
                    // Daily Calorie Intake Card
                    MacroResultsDisplay(
                      dailyCalories: dailyCalories!,
                      carbs: carbs ?? 0.0,
                      protein: protein ?? 0.0,
                      fat: fat ?? 0.0,
                    ),
                    const SizedBox(height: 20),
                    // Expected Results after 1 Week and 1 Month
                    ExpectedResultsDisplay(
                      expectedWeight1Week: expectedWeight1Week,
                      expectedBodyFat1Week: expectedBodyFat1Week,
                      expectedWeight1Month: expectedWeight1Month,
                      expectedBodyFat1Month: expectedBodyFat1Month,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}