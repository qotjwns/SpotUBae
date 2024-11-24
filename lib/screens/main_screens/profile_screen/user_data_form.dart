import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_data.dart';
import '../../../services/user_data_manage_service.dart';
import '../../../widgets/widget_for_profile/number_input_box.dart';
import 'confirmation_dialog.dart';

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
    final userDataManageService =
    Provider.of<UserDataManageService>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('user_data');
    if (jsonString != null) {
      List<dynamic> jsonData = json.decode(jsonString);
      List<UserData> loadedData =
      jsonData.map((item) => UserData.fromJson(item)).toList();
      userDataManageService.loadUserData(loadedData);
    }
  }

  Future<void> _saveUserData() async {
    if (_weightController.text.isEmpty || _bodyFatController.text.isEmpty) {
      _showSnackBar('Please fill out all fields');
      return;
    }

    final weight = int.tryParse(_weightController.text);
    final bodyFat = int.tryParse(_bodyFatController.text);

    if (weight == null || bodyFat == null) {
      _showSnackBar('Please enter a valid number');
      return;
    }

    if (weight <= 0 || bodyFat < 0 || bodyFat > 100) {
      _showSnackBar('Please enter realistic values');
      return;
    }

    final userDataManageService =
    Provider.of<UserDataManageService>(context, listen: false);

    UserData newData = UserData(
      date: DateTime.now(),
      weight: weight,
      bodyFat: bodyFat,
    );

    userDataManageService.addOrUpdateUserData(newData);

    final prefs = await SharedPreferences.getInstance();
    List<UserData> currentData = userDataManageService.userDataList;
    String jsonString =
    json.encode(currentData.map((data) => data.toJson()).toList());
    await prefs.setString('user_data', jsonString);

    if (!mounted) return;
    _showSnackBar('Your data has been saved successfully');

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
        final weight = int.tryParse(_weightController.text);
        if (weight == null || weight <= 0) {
          _weightError = 'Please enter a valid weight';
        } else {
          _weightError = null;
        }
      }

      if (_bodyFatController.text.isEmpty) {
        _bodyFatError = 'Input your body fat';
      } else {
        final bodyFat = int.tryParse(_bodyFatController.text);
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

    final userDataManageService =
    Provider.of<UserDataManageService>(context, listen: false);

    bool confirm = await showConfirmationDialog(
      context,
      'Graph initialization',
      'Do you want to reset all data?\nThis action is irreversible.',
    );

    if (confirm) {
      userDataManageService.resetUserData();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
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
                'Graph initialization',
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
