import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width; // Optional width
  final double? height; // Optional height

  const ButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = width ?? screenWidth * 0.8;

    Widget button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // 패딩 조절
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );

    if (width != null || height != null) {
      return SizedBox(
        width: buttonWidth,
        height: height,
        child: button,
      );
    } else {
      return button;
    }
  }
}
