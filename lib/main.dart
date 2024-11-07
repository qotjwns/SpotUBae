import 'package:flutter/material.dart';
import 'package:group_app/screens/screen_controller/controller.dart';
import 'package:group_app/services/user_data_manage_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataManageService()),
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
