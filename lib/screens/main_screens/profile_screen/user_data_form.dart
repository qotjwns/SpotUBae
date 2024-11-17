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
      _showSnackBar('모든 필드를 입력해주세요');
      return;
    }

    final weight = int.tryParse(_weightController.text);
    final bodyFat = int.tryParse(_bodyFatController.text);

    if (weight == null || bodyFat == null) {
      _showSnackBar('유효한 숫자를 입력해주세요');
      return;
    }

    if (weight <= 0 || bodyFat < 0 || bodyFat > 100) {
      _showSnackBar('현실적인 값을 입력해주세요');
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
    _showSnackBar('데이터가 성공적으로 저장되었습니다');

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
        _weightError = '무게를 입력해주세요';
      } else {
        final weight = int.tryParse(_weightController.text);
        if (weight == null || weight <= 0) {
          _weightError = '유효한 무게를 입력해주세요';
        } else {
          _weightError = null;
        }
      }

      if (_bodyFatController.text.isEmpty) {
        _bodyFatError = '체지방을 입력해주세요';
      } else {
        final bodyFat = int.tryParse(_bodyFatController.text);
        if (bodyFat == null || bodyFat < 0 || bodyFat > 100) {
          _bodyFatError = '유효한 체지방을 입력해주세요';
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
      '그래프 초기화',
      '모든 데이터를 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
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
                labelText: '무게 (KG)',
                controller: _weightController,
                onChanged: (value) {
                  _validateInputs();
                },
                errorText: _weightError,
                maxValue: 200,
              ),
              const SizedBox(width: 20),
              NumberInputBox(
                labelText: '체지방 (%)',
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
                '저장',
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
                '그래프 초기화',
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
