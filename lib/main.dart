import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:group_app/screens/screen_controller/controller.dart';
import 'package:group_app/services/api_service.dart';
import 'package:group_app/services/goal_manage_service.dart';
import 'package:group_app/services/user_data_manage_service.dart';
import 'package:provider/provider.dart';
import 'package:group_app/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_data.dart';
import 'services/program_user_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // StorageService 인스턴스 생성 및 운동 데이터 초기화
  StorageService storageService = StorageService();
  await storageService.initializeWorkouts();

  // 사용자 데이터 로드
  final prefs = await SharedPreferences.getInstance();
  String? jsonString = prefs.getString('user_data');
  List<UserData> loadedData = [];
  if (jsonString != null) {
    try {
      List<dynamic> jsonData = json.decode(jsonString);
      loadedData = jsonData.map((item) => UserData.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // UserDataManageService 초기화 및 데이터 로드
  UserDataManageService userDataManageService = UserDataManageService();
  userDataManageService.loadUserData(loadedData);

  // ProgramUserDataService 인스턴스 생성 및 데이터 로드
  final programUserDataService = ProgramUserDataService();
  await programUserDataService.loadProgramUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userDataManageService),
        ChangeNotifierProvider(create: (_) => GoalManageService()),
        ChangeNotifierProvider.value(value: programUserDataService),
        Provider<StorageService>(create: (_) => storageService), // StorageService를 Provider로 등록
        Provider<ApiService>(
          create: (_) => ApiService(
            apiKey: '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',
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      title: 'Fitness Chatbot',
      debugShowCheckedModeBanner: false,
      home: Controller(),
    );
  }
}
