import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../base/button/buttons.dart';
import 'first_screen.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key}); // 생성자

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TODAY\'s WORKOUT',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 75),
            Container(width: 300, height: 4, color: Colors.black),
            const SizedBox(height: 75),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FirstScreen())
                );
              }, // 콜백 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(300, 50),
              ),
              child: const Text('START WORKOUT', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }


}
