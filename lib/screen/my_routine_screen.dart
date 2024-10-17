import 'package:flutter/material.dart';
import 'package:group_app/screen/performance.dart';

class MyRoutineScreen extends StatelessWidget {
  const MyRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 고정된 영역
          const SizedBox(height: 100),
          const Text("My Routine",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          // Scrollable 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 45),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        workoutRow("BENCH PRESS"),
                        const SizedBox(height: 20),
                        setsRepsKgRow(),
                        Row(
                          children: [
                            setsDropdown(),
                            const TextFieldRow(label: "Reps"),
                            const TextFieldRow(label: "KG")
                          ],
                        ),
                        const SizedBox(height: 50),
                        workoutRow("DIPS"),
                        const SizedBox(height: 20),
                        setsRepsKgRow(),
                        Row(
                          children: [
                            setsDropdown(),
                            const TextFieldRow(label: "Reps"),
                            const TextFieldRow(label: "KG")
                          ],
                        ),
                        const SizedBox(height: 50),
                        workoutRow("DUMBBELL FLY"),
                        const SizedBox(height: 20),
                        setsRepsKgRow(),
                        Row(
                          children: [
                            setsDropdown(),
                            const TextFieldRow(label: "Reps"),
                            const TextFieldRow(label: "KG")
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30), // 위쪽 간격
          const SizedBox(height: 20), // 버튼과 스크롤 영역 사이 간격
          // 고정된 버튼 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Add workout 버튼 클릭 시 동작할 내용
                  },
                  icon: const Icon(Icons.add_box_outlined, color: Colors.black),
                  label: const Text("Add workout",
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context) => Performance()),
                    );
                    // Finish 버튼 클릭 시 동작할 내용
                  },
                  child: const Text("Finish",
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 7.5),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30), // 아래쪽 간격
        ],
      ),
    );
  }

  Row workoutRow(String title) {
    return Row(
      children: [
        const Icon(Icons.check_box_outlined),
        const SizedBox(
          width: 10,
        ),
        Text(title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Row setsRepsKgRow() {
    return const Row(
      children: [
        SizedBox(
          width: 45,
        ),
        Text("Sets",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(
          width: 80,
        ),
        Text("Reps",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(
          width: 80,
        ),
        Text("kg", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

Widget setsDropdown() {
  return Row(
    children: [
      const SizedBox(
        width: 45,
      ),
      SizedBox(
        width: 60,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black), // 검정색 테두리
            borderRadius: BorderRadius.circular(4), // 모서리 둥글게
          ),
          child: DropdownButton<int>(
            isExpanded: true,
            value: 1, // 기본값 설정
            items: List.generate(10, (index) => index + 1).map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Center(child: Text(value.toString())),
              );
            }).toList(),
            onChanged: (int? newValue) {
              // 값이 변경될 때의 동작
            },
          ),
        ),
      ),
    ],
  );
}

class TextFieldRow extends StatelessWidget {
  final String label;

  const TextFieldRow({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 60,
        ),
        SizedBox(
          width: 60,
          height: 40,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
