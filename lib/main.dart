import 'package:flutter/material.dart';
import 'package:group_app/screens/screen_controller/controller.dart';
import 'package:group_app/services/api_service.dart';
import 'package:group_app/services/goal_manage_service.dart';
import 'package:provider/provider.dart';
import 'package:group_app/services/storage_service.dart';
import 'services/user_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StorageService storageService = StorageService();
  await storageService.initializeWorkouts();


  // UserDataService 초기화 및 데이터 로드
  final userDataService = UserDataService();
  await userDataService.loadProgramUserData();
  await userDataService.loadProfileUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalManageService()),
        // Provide the single instance of UserDataService
        ChangeNotifierProvider<UserDataService>.value(
          value: userDataService,
        ),
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
