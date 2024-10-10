import 'package:flutter/material.dart';
import 'package:group_app/base/bottom_nav_bar.dart';
import 'package:group_app/login/login_screen.dart';
import 'package:group_app/screen/first_screen.dart';
import 'package:group_app/screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // 초기 선택 인덱스

  final List<Widget> appScreens = [
    const Center(child: Text("Calendar")),
    const HomeScreen(),
    const Center(child: Text("Account")),
    const FirstScreen()
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < appScreens.length) {
      setState(() {
        _selectedIndex = index; // 선택된 인덱스 업데이트
      });
    }
  }

  void navigateToFirstScreen() {
    setState(() {
      _selectedIndex = 3; // FirstScreen으로 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    // HomeScreen에 navigateToFirstScreen 전달
    return Scaffold(
      body: appScreens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        onTap: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
