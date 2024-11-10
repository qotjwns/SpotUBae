// lib/services/goal_manage_service.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/goal.dart';

class GoalManageService extends ChangeNotifier {
  Goal? _dailyGoal;
  Goal? _weeklyGoal;
  Goal? _monthlyGoal;

  Goal? get dailyGoal => _dailyGoal;
  Goal? get weeklyGoal => _weeklyGoal;
  Goal? get monthlyGoal => _monthlyGoal;

  GoalManageService() {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    String? dailyJson = prefs.getString('daily_goal');
    String? weeklyJson = prefs.getString('weekly_goal');
    String? monthlyJson = prefs.getString('monthly_goal');

    _dailyGoal = dailyJson != null ? Goal.fromJson(json.decode(dailyJson)) : null;
    _weeklyGoal = weeklyJson != null ? Goal.fromJson(json.decode(weeklyJson)) : null;
    _monthlyGoal = monthlyJson != null ? Goal.fromJson(json.decode(monthlyJson)) : null;

    _checkAndResetGoals();
  }

  Future<void> _saveGoal(Goal goal) async {
    final prefs = await SharedPreferences.getInstance();
    String goalJson = json.encode(goal.toJson());

    if (goal.type == 'daily') {
      _dailyGoal = goal;
      await prefs.setString('daily_goal', goalJson);
    } else if (goal.type == 'weekly') {
      _weeklyGoal = goal;
      await prefs.setString('weekly_goal', goalJson);
    } else if (goal.type == 'monthly') {
      _monthlyGoal = goal;
      await prefs.setString('monthly_goal', goalJson);
    }

    notifyListeners();
  }

  Future<void> setGoal(String type, String value) async {
    Goal newGoal = Goal(
      type: type,
      value: value,
      setDate: DateTime.now(),
    );
    await _saveGoal(newGoal);
  }

  // 공개 메서드: 특정 목표 초기화
  Future<void> resetGoal(String type) async {
    await _resetGoal(type);
  }

  Future<void> _resetGoal(String type) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == 'daily') {
      _dailyGoal = null;
      await prefs.remove('daily_goal');
    } else if (type == 'weekly') {
      _weeklyGoal = null;
      await prefs.remove('weekly_goal');
    } else if (type == 'monthly') {
      _monthlyGoal = null;
      await prefs.remove('monthly_goal');
    }
    notifyListeners();
  }

  void _checkAndResetGoals() {
    DateTime now = DateTime.now();

    // 일일 목표 초기화
    if (_dailyGoal != null) {
      if (!_isSameDay(now, _dailyGoal!.setDate!)) {
        _resetGoal('daily');
      }
    }

    // 주간 목표 초기화
    if (_weeklyGoal != null) {
      if (!_isSameWeek(now, _weeklyGoal!.setDate!)) {
        _resetGoal('weekly');
      }
    }

    // 월간 목표 초기화
    if (_monthlyGoal != null) {
      if (!_isSameMonth(now, _monthlyGoal!.setDate!)) {
        _resetGoal('monthly');
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    // ISO week number 계산
    int weekNumber(DateTime date) {
      int dayOfYear = int.parse(DateFormat("D").format(date));
      return ((dayOfYear - date.weekday + 10) / 7).floor();
    }

    return a.year == b.year && weekNumber(a) == weekNumber(b);
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
