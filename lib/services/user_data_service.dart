import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/program_user_data.dart';
import '../models/user_data.dart';

class UserDataService with ChangeNotifier {
  ProgramUserData? _bulkingProgramData;
  ProgramUserData? _cuttingProgramData;
  List<UserData> _profileUserDataList = [];
  String?
      _currentProgramType; //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com
  ProgramUserData? get bulkingProgramData => _bulkingProgramData;

  ProgramUserData? get cuttingProgramData => _cuttingProgramData;

  List<UserData> get profileUserDataList => _profileUserDataList;

  String? get currentProgramType => _currentProgramType;

  Future<void> loadProgramUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentProgramType =
        prefs.getString('currentProgramType'); // 'Bulking' 또는 'Cutting'

    final String? bulkingDataString = prefs.getString('bulkingProgramData');
    if (bulkingDataString != null) {
      final Map<String, dynamic> bulkingMap = json.decode(bulkingDataString);
      _bulkingProgramData = ProgramUserData.fromMap(bulkingMap);
    }

    final String? cuttingDataString = prefs.getString('cuttingProgramData');
    if (cuttingDataString != null) {
      final Map<String, dynamic> cuttingMap = json.decode(cuttingDataString);
      _cuttingProgramData = ProgramUserData.fromMap(cuttingMap);
    }
    notifyListeners();
  }

  Future<void> saveBulkingProgramData(ProgramUserData data) async {
    _bulkingProgramData = data;
    final prefs = await SharedPreferences.getInstance();
    final String bulkingDataString = json.encode(data.toMap());
    await prefs.setString('bulkingProgramData', bulkingDataString);
    notifyListeners();
  }

  Future<void> saveCuttingProgramData(ProgramUserData data) async {
    _cuttingProgramData = data;
    final prefs = await SharedPreferences.getInstance();
    final String cuttingDataString = json.encode(data.toMap());
    await prefs.setString('cuttingProgramData', cuttingDataString);
    notifyListeners();
  }

  Future<void> setCurrentProgramType(String programType) async {
    _currentProgramType = programType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentProgramType', programType);
    notifyListeners();
  }

  Future<void> updateProgramUserData({
    required String programType, // 'Bulking' 또는 'Cutting'
    double? currentWeight,
    double? currentBodyFat,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (programType == 'Bulking' && _bulkingProgramData != null) {
      if (currentWeight != null) {
        _bulkingProgramData!.currentWeight = currentWeight;
      }
      if (currentBodyFat != null) {
        _bulkingProgramData!.currentBodyFat = currentBodyFat;
      }
      final String bulkingDataString =
          json.encode(_bulkingProgramData!.toMap());
      await prefs.setString('bulkingProgramData', bulkingDataString);
    } else if (programType == 'Cutting' && _cuttingProgramData != null) {
      if (currentWeight != null) {
        _cuttingProgramData!.currentWeight = currentWeight;
      }
      if (currentBodyFat != null) {
        _cuttingProgramData!.currentBodyFat = currentBodyFat;
      }
      final String cuttingDataString =
          json.encode(_cuttingProgramData!.toMap());
      await prefs.setString('cuttingProgramData', cuttingDataString);
    } else {
      return;
    }

    notifyListeners();
  }

  Future<void> loadProfileUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileUserDataString =
        prefs.getString('profileUserDataList');
    if (profileUserDataString != null) {
      final List<dynamic> userList = json.decode(profileUserDataString);
      _profileUserDataList = userList.map((e) => UserData.fromMap(e)).toList();
    }
    notifyListeners();
  }

  Future<void> addOrUpdateProfileUserData(UserData data) async {
    bool updated = false;
    for (int i = 0; i < _profileUserDataList.length; i++) {
      if (_isSameDate(_profileUserDataList[i].date, data.date)) {
        _profileUserDataList[i] = data;
        updated = true;
        break;
      }
    }

    if (!updated) {
      _profileUserDataList.add(data);
    }

    final prefs = await SharedPreferences.getInstance();
    final String userDataString =
        json.encode(_profileUserDataList.map((e) => e.toMap()).toList());
    await prefs.setString('profileUserDataList', userDataString);
    notifyListeners();
  }

  Future<void> resetProfileUserData() async {
    _profileUserDataList.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileUserDataList');
    notifyListeners();
  }

  Future<void> resetProgramUserData() async {
    _bulkingProgramData = null;
    _cuttingProgramData = null;
    _currentProgramType = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bulkingProgramData');
    await prefs.remove('cuttingProgramData');
    await prefs.remove('currentProgramType');
    notifyListeners();
  }

  Future<void> resetAllData() async {
    _profileUserDataList.clear();
    _bulkingProgramData = null;
    _cuttingProgramData = null;
    _currentProgramType = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileUserDataList');
    await prefs.remove('bulkingProgramData');
    await prefs.remove('cuttingProgramData');
    await prefs.remove('currentProgramType');
    notifyListeners();
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  } //OpenAi.(2024).ChatGPT(version 4o).https://chat.openai.com
}
