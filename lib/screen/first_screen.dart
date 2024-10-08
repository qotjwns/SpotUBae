import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../base/button/buttons.dart';

void main() {
  runApp(const FirstScreen());
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal : 20),
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(height: 100,),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TODAY\'s WORKOUT', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(formattedDate, style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 50,),
                      ElevatedButton(
                        onPressed: () {
                          // 버튼 1 클릭 시 동작
                          print('Button 1 Pressed');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,// 배경색 검정색
                          minimumSize: Size(300, 50), // 버튼 크기 설정
                        ),
                        child: const Text('CHEST'),
                      ),
                      //ButtonWidget(
                      // label: 'Chest', // 버튼에 표시될 텍스트
                      //onPressed: () {
                      //print('Button clicked!');
                      //},
                      //),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
    );
  }
}