import 'package:flutter/material.dart';
import 'package:group_app/screens/targeted_area_screen.dart';
import '../../widgets/table_cell_content.dart';
import '../../widgets/button_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, // 폰트 크기 조정
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ButtonWidget(
                label: "운동 선택하기",
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TargetedAreaScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Table(
                border: TableBorder.all(
                  width: 2,
                  color: Colors.grey.shade400,
                  style: BorderStyle.solid,
                ),
                children: const [
                  TableRow(
                    children: [
                      TableCellContent(text: '오늘의 목표'),
                      TableCellContent(text: '주간 목표'),
                      TableCellContent(text: '월간 목표'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
