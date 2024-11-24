// lib/widgets/serving_size_dialog.dart

import 'package:flutter/material.dart';

class ServingSizeDialog extends StatefulWidget {
  final String foodName;
  final double initialServingSize;

  const ServingSizeDialog({
    Key? key,
    required this.foodName,
    required this.initialServingSize,
  }) : super(key: key);

  @override
  _ServingSizeDialogState createState() => _ServingSizeDialogState();
}

class _ServingSizeDialogState extends State<ServingSizeDialog> {
  late double servingSize;

  @override
  void initState() {
    super.initState();
    servingSize = widget.initialServingSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose ${widget.foodName} intake'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Servings: ${servingSize.toStringAsFixed(1)}'),
          Slider(
            value: servingSize,
            min: 0.5,
            max: 3.0,
            divisions: 5,
            label: '${servingSize.toStringAsFixed(1)} serving',
            onChanged: (value) {
              setState(() {
                servingSize = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 취소
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(servingSize); // 수정된 servingSize 반환
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}