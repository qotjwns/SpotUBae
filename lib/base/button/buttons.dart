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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // 배경색 검정색
            minimumSize: Size(300, 50), // 버튼 크기 설정
          ),
          child: const Text('CHEST'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // 버튼 2 클릭 시 동작
            print('Button 2 Pressed');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // 배경색 검정색
            minimumSize: Size(300, 50), // 버튼 크기 설정
        ),
          child: const Text('BACK'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // 배경색 검정색
            minimumSize: Size(300, 50), // 버튼 크기 설정
          ),
          child: const Text('SHOULDER'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // 배경색 검정색
            minimumSize: Size(300, 50), // 버튼 크기 설정
          ),
          child: const Text('LEGS'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // 배경색 검정색
            minimumSize: Size(300, 50), // 버튼 크기 설정
          ),
          child: const Text('ARMS'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: Size(300, 50), // 버튼 크기 설정
          ),
          child: const Text('ABS'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,// 배경색 검정색
            minimumSize: const Size(300, 50), // 버튼 크기 설정
          ),
          child: const Text('CARDIO'),
        ),
      ],
    );
  }
}