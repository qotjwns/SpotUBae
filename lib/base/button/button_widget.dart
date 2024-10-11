import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ButtonWidget({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 가로로 꽉 차게 만듭니다.
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // 버튼 배경색을 검정색으로 설정
          padding: EdgeInsets.symmetric(vertical: 15), // 세로 패딩
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: Colors.white), // 텍스트 색상을 흰색으로 설정
        ),
      ),
    );
  }
}
