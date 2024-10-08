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
          child: Text('Button 1'),
        ),
        ElevatedButton(
          onPressed: () {
            // 버튼 2 클릭 시 동작
            print('Button 2 Pressed');
          },
          child: Text('Button 2'),
        ),
        ElevatedButton(
          onPressed: () {
            // 버튼 3 클릭 시 동작
            print('Button 3 Pressed');
          },
          child: Text('Button 3'),
        ),
      ],
    );
  }
}