// lib/services/program_user_data_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/program_user_data.dart';

class ProgramUserDataService with ChangeNotifier {
  Map<String, ProgramUserData> _programDataMap = {};
  String? _currentProgramType;

  String? get currentProgramType => _currentProgramType;
  ProgramUserData? get currentProgramData => _currentProgramType != null ? _programDataMap[_currentProgramType!] : null;

  // 데이터 로드
  Future<void> loadProgramUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? programType = prefs.getString('programType');
    if (programType != null) {
      _currentProgramType = programType;
      final String? userDataString = prefs.getString('programUserData_$programType');
      if (userDataString != null) {
        final Map<String, dynamic> userMap = json.decode(userDataString);
        _programDataMap[programType] = ProgramUserData.fromMap(userMap);
        notifyListeners();
      }
    }
  }

  // 프로그램 타입 설정 및 저장
  Future<void> setProgramType(String programType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('programType', programType);
    _currentProgramType = programType;

    // 해당 프로그램 타입의 데이터 로드
    final String? userDataString = prefs.getString('programUserData_$programType');
    if (userDataString != null) {
      final Map<String, dynamic> userMap = json.decode(userDataString);
      _programDataMap[programType] = ProgramUserData.fromMap(userMap);
    } else {
      _programDataMap.remove(programType);
    }
    notifyListeners();
  }

  // 데이터 저장
  Future<void> saveProgramUserData(ProgramUserData data) async {
    if (_currentProgramType == null) return; // 프로그램 타입이 설정되지 않은 경우

    final prefs = await SharedPreferences.getInstance();
    final String userDataString = json.encode(data.toMap());
    await prefs.setString('programUserData_${_currentProgramType}', userDataString);
    _programDataMap[_currentProgramType!] = data;
    notifyListeners();
  }

  // 데이터 삭제
  Future<void> clearProgramUserData() async {
    if (_currentProgramType == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('programUserData_${_currentProgramType}');
    _programDataMap.remove(_currentProgramType);
    notifyListeners();
  }

  // 모든 프로그램 데이터 삭제 (필요 시)
  Future<void> clearAllProgramData() async {
    final prefs = await SharedPreferences.getInstance();
    for (String programType in _programDataMap.keys) {
      await prefs.remove('programUserData_$programType');
    }
    await prefs.remove('programType');
    _programDataMap.clear();
    _currentProgramType = null;
    notifyListeners();
  }
}
