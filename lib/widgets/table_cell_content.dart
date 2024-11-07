import 'package:flutter/material.dart';

class TableCellContent extends StatelessWidget {
  final String text;

  const TableCellContent({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
