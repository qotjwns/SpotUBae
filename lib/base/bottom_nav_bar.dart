import 'package:flutter/material.dart';
import 'package:group_app/screen/home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    const Text("Calendar"),
    const HomeScreen(),
    const Text("Profile"),
  ];
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
