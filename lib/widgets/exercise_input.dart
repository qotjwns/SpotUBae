// lib/widgets/exercise_input.dart
import 'package:flutter/material.dart';
import 'package:group_app/widgets/button_widget.dart';

class ExerciseInput extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final VoidCallback onAdd;

  const ExerciseInput({
    super.key,
    required this.nameController,
    required this.setsController,
    required this.repsController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '운동 이름',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '세트 수',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '반복 횟수',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
           ButtonWidget(label: '추가', onPressed:onAdd)
          ],
        ),
      ],
    );
  }
}