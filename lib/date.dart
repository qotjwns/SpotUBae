import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Date extends StatelessWidget {
  Date({super.key});

  final now = DateTime.now();
  String formattedDate = DateFormat('yy.MM.dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Text(formattedDate,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold));
  }
}
