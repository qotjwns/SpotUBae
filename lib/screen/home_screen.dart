import 'package:flutter/material.dart';
import 'package:group_app/base/button/button_widget.dart';
import 'package:group_app/screen/first_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100), // 상단 여백
            const Text(
              'TODAY\'S WORKOUT',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // 제목과 날짜 사이의 간격
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            ButtonWidget(
                label: "Start Workout",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FirstScreen(),
                      ));
                }),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide(
                      width: 2, // 가로줄 두께
                      color: Colors.grey, // 가로줄 색상
                      style: BorderStyle.solid,
                    ),
                    verticalInside: BorderSide(
                      width: 2, // 가로줄 두께
                      color: Colors.grey, // 가로줄 색상
                      style: BorderStyle.solid,
                    ),
                  ),
                  children: const [
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text('Today`s Goal', style: TextStyle(fontSize: 18))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text('Weekly Goal', style: TextStyle(fontSize: 18))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text('Monthly Goal', style: TextStyle(fontSize: 18))),
                        ),
                      ],
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
