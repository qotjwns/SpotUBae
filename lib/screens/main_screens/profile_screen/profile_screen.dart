import 'package:flutter/material.dart';
import 'package:group_app/screens/main_screens/profile_screen/user_data_chart.dart';
import 'package:group_app/screens/main_screens/profile_screen/user_data_form.dart';
import 'package:provider/provider.dart';
import '../../../services/user_data_manage_service.dart';
import 'legend_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Consumer<UserDataManageService>(
        builder: (context, userDataManageService, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 50.0),
              child: Column(
                children: <Widget>[
                  const Center(
                    child: Text(
                      'User Data',
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const UserDataForm(),
                  const SizedBox(height: 20),
                  userDataManageService.userDataList.isNotEmpty
                      ? Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: UserDataChart(
                          userDataList:
                          userDataManageService.userDataList,
                          maxY: 120,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LegendItem(color: Colors.blue, label: 'Weight'),
                          SizedBox(width: 20),
                          LegendItem(color: Colors.red, label: 'Body Fat'),
                        ],
                      ),
                    ],
                  )
                      : const Text('Enter your weight and body fat and save it',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
