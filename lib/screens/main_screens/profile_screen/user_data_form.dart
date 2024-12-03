// lib/screens/main_screens/profile_screen/user_data_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/user_data_service.dart';
import '../../../models/user_data.dart';
import '../../../models/program_user_data.dart';
import 'confirmation_dialog.dart';
import '../../../widgets/widget_for_profile/number_input_box.dart';

class UserDataForm extends StatefulWidget {
  const UserDataForm({super.key});

  @override
  UserDataFormState createState() => UserDataFormState();
}

class UserDataFormState extends State<UserDataForm> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();

  String? _weightError;
  String? _bodyFatError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    await userDataService.loadProfileUserData();
    await userDataService.loadProgramUserData();

    // 현재 프로그램 타입을 가져옴
    String? programType = userDataService.currentProgramType;

    // 프로그램 데이터가 존재하면 폼에 미리 채워넣기
    if (programType != null) {
      if (programType == 'Bulking' && userDataService.bulkingProgramData != null) {
        _weightController.text = userDataService.bulkingProgramData!.currentWeight.toString();
        _bodyFatController.text = userDataService.bulkingProgramData!.currentBodyFat.toString();
      } else if (programType == 'Cutting' && userDataService.cuttingProgramData != null) {
        _weightController.text = userDataService.cuttingProgramData!.currentWeight.toString();
        _bodyFatController.text = userDataService.cuttingProgramData!.currentBodyFat.toString();
      }
    }
  }

  Future<void> _saveUserData() async {
    _validateInputs();

    if (!_isSaveEnabled) {
      _showSnackBar('Please correct the errors before saving.');
      return;
    }

    final weight = double.tryParse(_weightController.text);
    final bodyFat = double.tryParse(_bodyFatController.text);

    if (weight == null || bodyFat == null) {
      _showSnackBar('Please enter valid numbers.');
      return;
    }

    if (weight <= 0 || bodyFat < 0 || bodyFat > 100) {
      _showSnackBar('Please enter realistic values.');
      return;
    }

    final userDataService = Provider.of<UserDataService>(context, listen: false);
    String? programType = userDataService.currentProgramType;

    if (programType == null) {
      _showSnackBar('Please set a program type (Bulking or Cutting) first.');
      return;
    }

    // 새로운 프로필 데이터 생성
    UserData newData = UserData(
      date: DateTime.now(),
      weight: weight,
      bodyFat: bodyFat,
    );

    // 프로필 데이터 추가 또는 업데이트
    await userDataService.addOrUpdateProfileUserData(newData);

    // 프로그램 데이터가 존재하면 특정 필드만 업데이트
    if (programType == 'Bulking' && userDataService.bulkingProgramData != null) {
      await userDataService.updateProgramUserData(
        programType: 'Bulking',
        currentWeight: weight,
        currentBodyFat: bodyFat,
      );
    } else if (programType == 'Cutting' && userDataService.cuttingProgramData != null) {

      await userDataService.updateProgramUserData(
        programType: 'Cutting',
        currentWeight: weight,
        currentBodyFat: bodyFat,
      );
    }

    _showSnackBar('Your data has been saved successfully.');

    _weightController.clear();
    _bodyFatController.clear();
  }

  void _showSnackBar(String message) {
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _validateInputs() {
    setState(() {
      if (_weightController.text.isEmpty) {
        _weightError = 'Input your weight';
      } else {
        final weight = double.tryParse(_weightController.text);
        if (weight == null || weight <= 0) {
          _weightError = 'Please enter a valid weight';
        } else {
          _weightError = null;
        }
      }

      if (_bodyFatController.text.isEmpty) {
        _bodyFatError = 'Input your body fat';
      } else {
        final bodyFat = double.tryParse(_bodyFatController.text);
        if (bodyFat == null || bodyFat < 0 || bodyFat > 100) {
          _bodyFatError = 'Please enter a valid body fat';
        } else {
          _bodyFatError = null;
        }
      }
    });
  }

  Future<void> _resetUserData() async {
    if (!mounted) return;

    final userDataService = Provider.of<UserDataService>(context, listen: false);

    bool confirm = await showConfirmationDialog(
      context,
      'Graph initialization',
      'Do you want to reset all data?\nThis action is irreversible.',
    );

    if (confirm) {
      await userDataService.resetProfileUserData(); // 변경된 부분
      _showSnackBar('Profile data has been reset.');
      _weightController.clear();
      _bodyFatController.clear();

    }
  }

  bool get _isSaveEnabled =>
      _weightError == null &&
          _bodyFatError == null &&
          _weightController.text.isNotEmpty &&
          _bodyFatController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              NumberInputBox(
                labelText: 'Weight (KG)',
                controller: _weightController,
                onChanged: (value) {
                  _validateInputs();
                },
                errorText: _weightError,
                maxValue: 200,
              ),
              const SizedBox(width: 20),
              NumberInputBox(
                labelText: 'Body Fat (%)',
                controller: _bodyFatController,
                onChanged: (value) {
                  _validateInputs();
                },
                errorText: _bodyFatError,
                maxValue: 100,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _isSaveEnabled ? _saveUserData : null,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _resetUserData,
              child: const Text(
                'Reset Graph',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
