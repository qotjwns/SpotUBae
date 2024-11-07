import 'package:flutter/material.dart';
import 'package:group_app/screens/main_screens/calendar_screen.dart';
import '../main_screens/home_screen.dart';
import '../main_screens/profile_screen/profile_screen.dart';

class Controller extends StatefulWidget {
  const Controller({super.key});

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          CalendarScreen(),
          HomeScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(
              text: 'Calendar',
              icon: Icon(Icons.calendar_today),
            ),
            Tab(text: 'Home', icon: Icon(Icons.home)),
            Tab(text: 'Profile', icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}