import 'package:flutter/material.dart';
import '../screen/home_screen.dart'; // HomeScreen을 사용하고 있습니다.

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<Widget> appScreens = [
    const Center(child: Text("Calendar")), // 첫 번째 항목을 캘린더로 변경
    const HomeScreen(),
    //const Center(child: Text("Home")), // 두 번째 항목을 홈으로
    const Center(child: Text("Account")), // 세 번째 항목은 계정
  ];

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appScreens[_selectedIndex], // 현재 선택된 화면 표시
      bottomNavigationBar:
            SizedBox(
              child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.blueGrey,
              unselectedItemColor: const Color(0xFF000000),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month, size: 40,),
                  label: "Calendar", // 캘린더 아이콘
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 40),
                  label: "Home", // 홈 아이콘
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle, size: 40),
                  label: "Account", // 계정 아이콘
                ),
              ],
                        ),
            ),
        );
    }
}
