import 'package:flutter/material.dart';
import 'package:group_app/screens/main_screens/profile_screen/user_data_chart.dart';
import 'package:group_app/screens/main_screens/profile_screen/user_data_form.dart';
import 'package:provider/provider.dart';
import '../../../services/user_data_manage_service.dart';
import '../../photo_diary_screen.dart';
import 'legend_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, // 기본 높이보다 크게 설정 (필요에 따라 조정)
        centerTitle: true, // 제목을 중앙에 배치
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0), // 제목을 아래로 내리기 위한 상단 패딩 (필요에 따라 조정)
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 36, // 텍스트 크기 조정 (필요에 따라 조정)
              fontWeight: FontWeight.bold, // 텍스트 두께 조정
            ),
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
                      : const Text(
                    'Enter your weight and body fat and save it',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // 새로 추가된 버튼
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
