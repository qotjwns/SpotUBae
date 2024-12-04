import 'package:flutter/material.dart';
import 'package:group_app/screens/main_screens/profile_screen/user_data_chart.dart';
import 'package:group_app/screens/main_screens/profile_screen/user_data_form.dart';
import 'package:provider/provider.dart';
import '../../photo_diary_screen.dart';
import 'legend_item.dart';
import '../../../services/user_data_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Consumer<UserDataService>(
        builder: (context, userDataService, child) {
          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
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
                  userDataService.profileUserDataList.isNotEmpty
                      ? Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: UserDataChart(
                                userDataList:
                                    userDataService.profileUserDataList,
                                maxY: 150,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LegendItem(color: Colors.blue, label: 'Weight'),
                                SizedBox(width: 20),
                                LegendItem(
                                    color: Colors.red, label: 'Body Fat'),
                              ],
                            ),
                          ],
                        )
                      : const Text(
                          'Enter your weight and body fat and save it',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoDiaryScreen(),
                        ),
                      );
                    },
                    child: const Text('Open Photo Diary'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
