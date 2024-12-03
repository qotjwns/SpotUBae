// lib/screens/program_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/program_user_data.dart';
import '../../models/user_data.dart';
import '../../services/user_data_service.dart';
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
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    await userDataService.loadProgramUserData();

    if (widget.programType == 'Bulking' && userDataService.bulkingProgramData != null) {
      final data = userDataService.bulkingProgramData!;
      _ageController.text = data.age.toString();
      _gender = data.gender;
      _currentWeightController.text = data.currentWeight.toString();
      _heightController.text = data.height.toString();
      _currentBodyFatController.text = data.currentBodyFat.toString();
      _goalWeightController.text = data.goalWeight.toString();
      _goalBodyFatController.text = data.goalBodyFat.toString();

      // 계산 결과 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateMacrosAndExpectations();
      });
    } else if (widget.programType == 'Cutting' && userDataService.cuttingProgramData != null) {
      final data = userDataService.cuttingProgramData!;
      _ageController.text = data.age.toString();
      _gender = data.gender;
      _currentWeightController.text = data.currentWeight.toString();
      _heightController.text = data.height.toString();
      _currentBodyFatController.text = data.currentBodyFat.toString();
      _goalWeightController.text = data.goalWeight.toString();
      _goalBodyFatController.text = data.goalBodyFat.toString();

      // 계산 결과 표시
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

    // Mifflin-St Jeor 방정식을 사용한 BMR 계산
    double bmr;
    if (gender == 'male') {
      bmr = 10 * currentWeight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * currentWeight + 6.25 * height - 5 * age - 161;
    }

    // 중간 활동 수준을 가정한 TDEE 계산
    double tdee = bmr * 1.55;

    // 프로그램 타입에 따른 칼로리 조정
    double calorieAdjustment;
    if (widget.programType == 'Bulking') {
      calorieAdjustment = tdee + 500;
    } else {
      calorieAdjustment = tdee - 500;
    }

    // 매크로 계산
    protein = currentWeight * 2.0; // 단백질 2g/kg
    fat = currentWeight * 0.8; // 지방 0.8g/kg
    carbs = (calorieAdjustment - (protein! * 4 + fat! * 9)) / 4;

    // 총 체중 변화량 계산
    double totalWeightChange = goalWeight - currentWeight;
    double totalBodyFatChange = goalBodyFat - currentBodyFat;

    // 주간 최대 변화량 설정
    const double maxWeeklyWeightChange = 0.5; // kg
    const double maxWeeklyBodyFatChange = 0.3; // %

    // 프로그램 타입에 따른 주간 변화량 조정
    double weeklyWeightChange;
    double weeklyBodyFatChange;

    if (widget.programType == 'Bulking') {
      // Bulking: 체중 증가
      weeklyWeightChange = (totalWeightChange > 0 ? (totalWeightChange).clamp(0.0, maxWeeklyWeightChange) : 0.0);

      // Bulking: 체지방 증감 허용
      if (totalBodyFatChange > 0) {
        // 체지방 증가
        weeklyBodyFatChange = (totalBodyFatChange).clamp(0.0, maxWeeklyBodyFatChange);
      } else if (totalBodyFatChange < 0) {
        // 체지방 감소
        weeklyBodyFatChange = (totalBodyFatChange).clamp(-maxWeeklyBodyFatChange, 0.0);
      } else {
        weeklyBodyFatChange = 0.0;
      }
    } else {
      // Cutting: 체중 감소
      weeklyWeightChange = (totalWeightChange < 0 ? (totalWeightChange).clamp(-maxWeeklyWeightChange, 0.0) : 0.0);

      // Cutting: 체지방 감소만 허용
      weeklyBodyFatChange = (totalBodyFatChange < 0 ? (totalBodyFatChange).clamp(-maxWeeklyBodyFatChange, 0.0) : 0.0);
    }

    // 1주 후 예상 값 계산
    expectedWeight1Week = currentWeight + weeklyWeightChange;
    expectedBodyFat1Week = currentBodyFat + weeklyBodyFatChange;

    // 1개월 후 예상 값 계산 (4주 기준)
    double monthlyWeightChange = weeklyWeightChange * 4;
    double monthlyBodyFatChange = weeklyBodyFatChange * 4;

    expectedWeight1Month = currentWeight + monthlyWeightChange;
    expectedBodyFat1Month = currentBodyFat + monthlyBodyFatChange;

    // 목표 초과 방지
    if (widget.programType == 'Bulking') {
      // Bulking: 목표 체중 초과 방지
      if (expectedWeight1Week! > goalWeight) {
        expectedWeight1Week = goalWeight;
      }
      if (expectedWeight1Month! > goalWeight) {
        expectedWeight1Month = goalWeight;
      }

      // Bulking: 목표 체지방에 따른 조정
      if (goalBodyFat > currentBodyFat) {
        // 체지방 증가 허용
        if (expectedBodyFat1Week! > goalBodyFat) {
          expectedBodyFat1Week = goalBodyFat;
        }
        if (expectedBodyFat1Month! > goalBodyFat) {
          expectedBodyFat1Month = goalBodyFat;
        }
      } else {
        // 체지방 감소 허용
        if (expectedBodyFat1Week! < goalBodyFat) {
          expectedBodyFat1Week = goalBodyFat;
        }
        if (expectedBodyFat1Month! < goalBodyFat) {
          expectedBodyFat1Month = goalBodyFat;
        }
      }
    } else {
      // Cutting: 목표 체중 이하 방지
      if (expectedWeight1Week! < goalWeight) {
        expectedWeight1Week = goalWeight;
      }
      if (expectedWeight1Month! < goalWeight) {
        expectedWeight1Month = goalWeight;
      }

      // Cutting: 목표 체지방 이하 방지
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

      // UserDataService 사용
      final userDataService = Provider.of<UserDataService>(context, listen: false);

      // 현재 프로그램 타입을 UserDataService에 설정
      await userDataService.setCurrentProgramType(widget.programType);

      // 프로그램 데이터가 이미 존재하면 특정 필드만 업데이트
      if (widget.programType == 'Bulking' && userDataService.bulkingProgramData != null) {
        await userDataService.updateProgramUserData(
          programType: 'Bulking',
          currentWeight: double.parse(_currentWeightController.text),
          currentBodyFat: double.parse(_currentBodyFatController.text),
        );
      } else if (widget.programType == 'Cutting' && userDataService.cuttingProgramData != null) {
        await userDataService.updateProgramUserData(
          programType: 'Cutting',
          currentWeight: double.parse(_currentWeightController.text),
          currentBodyFat: double.parse(_currentBodyFatController.text),
        );
      } else {
        // 프로그램 데이터가 없으면 전체 저장
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
        if (widget.programType == 'Bulking') {
          await userDataService.saveBulkingProgramData(data);
        } else if (widget.programType == 'Cutting') {
          await userDataService.saveCuttingProgramData(data);
        }
      }

      // 프로필 데이터도 동기화
      if (userDataService.profileUserDataList.isNotEmpty) {
        UserData latestData = userDataService.profileUserDataList.last;
        latestData.weight = double.parse(_currentWeightController.text);
        latestData.bodyFat = double.parse(_currentBodyFatController.text);
        await userDataService.addOrUpdateProfileUserData(latestData);
      } else {
        // 프로필 데이터가 없으면 새로 추가
        UserData newUserData = UserData(
          date: DateTime.now(),
          weight: double.parse(_currentWeightController.text),
          bodyFat: double.parse(_currentBodyFatController.text),
        );
        await userDataService.addOrUpdateProfileUserData(newUserData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your data successfully saved.')),
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

      // UserDataService에서 프로그램 데이터 삭제
      final userDataService = Provider.of<UserDataService>(context, listen: false);
      await userDataService.resetProgramUserData(); // 변경된 부분


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your data has been reset.')),
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
          autovalidateMode: AutovalidateMode.onUserInteraction, // 실시간 검증
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Column 전체를 가운데 정렬
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
