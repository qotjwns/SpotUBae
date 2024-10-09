import 'package:flutter/material.dart';
import '../screen/home_screen.dart'; // HomeScreen을 사용하고 있습니다.

class BottomNavBar extends StatefulWidget {
  final Function(int) onTap; // 탭 클릭 시 호출되는 함수
  final int selectedIndex; // 현재 선택된 인덱스

  const BottomNavBar({
    super.key,
    required this.onTap,
    required this.selectedIndex,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return  // 현재 선택된 화면 표시
      BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        onTap: widget.onTap, // 외부에서 전달된 onTap 사용
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: const Color(0xFF000000),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, size: 40),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 40),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: 40),
            label: "Account",
          ),
        ],
      );
  }
}
