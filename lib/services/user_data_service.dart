// lib/services/user_data_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/program_user_data.dart';
import '../models/user_data.dart';

class UserDataService with ChangeNotifier {
  ProgramUserData? _bulkingProgramData;
  ProgramUserData? _cuttingProgramData;
  List<UserData> _profileUserDataList = [];
  String? _currentProgramType; // 현재 활성화된 프로그램 타입



  ProgramUserData? get bulkingProgramData => _bulkingProgramData;
  ProgramUserData? get cuttingProgramData => _cuttingProgramData;
  List<UserData> get profileUserDataList => _profileUserDataList;
  String? get currentProgramType => _currentProgramType;

  // 프로그램 데이터 로드
  Future<void> loadProgramUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentProgramType = prefs.getString('currentProgramType'); // 'Bulking' 또는 'Cutting'

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

  // Bulking 프로그램 데이터 저장
  Future<void> saveBulkingProgramData(ProgramUserData data) async {
    _bulkingProgramData = data;
    final prefs = await SharedPreferences.getInstance();
    final String bulkingDataString = json.encode(data.toMap());
    await prefs.setString('bulkingProgramData', bulkingDataString);
    notifyListeners();
  }

  // Cutting 프로그램 데이터 저장
  Future<void> saveCuttingProgramData(ProgramUserData data) async {
    _cuttingProgramData = data;
    final prefs = await SharedPreferences.getInstance();
    final String cuttingDataString = json.encode(data.toMap());
    await prefs.setString('cuttingProgramData', cuttingDataString);
    notifyListeners();
  }

  // 현재 프로그램 타입 설정 및 저장
  Future<void> setCurrentProgramType(String programType) async {
    _currentProgramType = programType;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentProgramType', programType);
    notifyListeners();
  }

  // 특정 프로그램 데이터 업데이트 (Bulking 또는 Cutting)
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
      final String bulkingDataString = json.encode(_bulkingProgramData!.toMap());
      await prefs.setString('bulkingProgramData', bulkingDataString);
    } else if (programType == 'Cutting' && _cuttingProgramData != null) {
      if (currentWeight != null) {
        _cuttingProgramData!.currentWeight = currentWeight;
      }
      if (currentBodyFat != null) {
        _cuttingProgramData!.currentBodyFat = currentBodyFat;
      }
      final String cuttingDataString = json.encode(_cuttingProgramData!.toMap());
      await prefs.setString('cuttingProgramData', cuttingDataString);
    } else {
      debugPrint('해당 프로그램 타입의 데이터가 없습니다.');
      return;
    }

    notifyListeners();
  }


  // 프로필 데이터 로드
  Future<void> loadProfileUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profileUserDataString = prefs.getString('profileUserDataList');
    if (profileUserDataString != null) {
      final List<dynamic> userList = json.decode(profileUserDataString);
      _profileUserDataList = userList.map((e) => UserData.fromMap(e)).toList();
    }
    notifyListeners();
  }

  // 프로필 데이터 추가 또는 업데이트
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
    final String userDataString = json.encode(_profileUserDataList.map((e) => e.toMap()).toList());
    await prefs.setString('profileUserDataList', userDataString);
    notifyListeners();
  }

  // **프로필 데이터만 초기화하는 메서드 추가**
  Future<void> resetProfileUserData() async {
    _profileUserDataList.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileUserDataList');
    notifyListeners();
  }
  // **프로그램 데이터만 초기화하는 메서드 추가**
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

  // 모든 데이터 초기화
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

  // 날짜 비교 헬퍼 메서드
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}