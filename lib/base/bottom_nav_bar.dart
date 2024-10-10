import 'package:flutter/material.dart';
import 'package:group_app/screen/calendar_screen.dart';
import 'package:group_app/screen/my_routine_screen.dart';

import '../screen/account.dart';
import '../screen/home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    const CalendarScreen(),
    const HomeScreen(),
    const AccountScreen(),
    const MyRoutineScreen(),
  ];                          //메인화면 컨트롤
  int _indexSelected = 1;

  void _onTappedItem(int index) {
    setState(() {
      _indexSelected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: appScreens[_indexSelected],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indexSelected,
            onTap: _onTappedItem,
            selectedItemColor: Colors.black,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month), label: "Calendar"),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Profile"),
            ]));
  }
}
