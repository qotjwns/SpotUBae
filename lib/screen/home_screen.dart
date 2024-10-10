import 'package:flutter/material.dart';
import 'package:group_app/date.dart';
import 'package:group_app/login/login_screen.dart';
import 'package:intl/intl.dart';


import '../base/button/button_widget.dart';

import '../base/button/buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  const Column(
                    children: [
                      SizedBox(height: 50,),
                      Buttons()
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

