import 'package:flutter/material.dart';
import 'package:group_app/base/bottom_nav_bar.dart';
import 'package:group_app/date.dart';
import 'package:group_app/login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 100,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal : 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TODAY\'s WORKOUT', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end
            ,
            children: [
              Date(),
            ],
          )
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}





