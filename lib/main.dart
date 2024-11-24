import 'package:flutter/material.dart';
import 'package:group_app/screens/screen_controller/controller.dart';
import 'package:group_app/services/goal_manage_service.dart';
import 'package:group_app/services/user_data_manage_service.dart';
import 'package:provider/provider.dart';
import 'package:group_app/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // StorageService 인스턴스 생성 및 운동 데이터 초기화
  StorageService storageService = StorageService();
  await storageService.initializeWorkouts();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataManageService()),
        ChangeNotifierProvider(create: (_) => GoalManageService()),
        Provider<StorageService>(create: (_) => storageService), // StorageService를 Provider로 등록
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
