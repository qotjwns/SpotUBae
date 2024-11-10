import 'package:flutter/foundation.dart';
import '../models/user_data.dart';

class UserDataManageService with ChangeNotifier {
  List<UserData> _userDataList = [];

  List<UserData> get userDataList => _userDataList;

  void addOrUpdateUserData(UserData newData) {
    bool updated = false;
    for (int i = 0; i < _userDataList.length; i++) {
      if (_isSameDate(_userDataList[i].date, newData.date)) {
        _userDataList[i] = newData;
        updated = true;
        break;
      }
    }

    if (!updated) {
      _userDataList.add(newData);
    }
    notifyListeners();
  }

  void resetUserData() {
    _userDataList.clear();
    notifyListeners();
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void loadUserData(List<UserData> data) {
    _userDataList = data;
    notifyListeners();
  }
}