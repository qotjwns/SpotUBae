import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // 버튼 1 클릭 시 동작
            print('Button 1 Pressed');
          },
          child: const Text('CHEST'),
        ),
        ElevatedButton(
          onPressed: () {
            // 버튼 2 클릭 시 동작
            print('Button 2 Pressed');
          },
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // 배경색 검정색
          minimumSize: Size(200, 40), // 버튼 크기 설정
        ),
          child: const Text('BACK'),
        ),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          child: const Text('SHOULDER'),
        ),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          child: const Text('LEGS'),
        ),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          child: const Text('ARMS'),
        ),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          child: const Text('ABS'),
        ),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          child: const Text('CARDIO'),
        ),
      ],
    );
  }
}