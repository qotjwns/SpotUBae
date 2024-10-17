import 'package:flutter/material.dart';

import '../base/bar_graph/bar_graph.dart';



class Performance extends StatefulWidget {
  const Performance({super.key});

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {


  final List<double> values = [20, 40, 60, 40, 20]; // Y축 값
  final List<String> yLabels = ['1set', '2set', '3set', '4set', '5set']; // X축 값 (레이블)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Performance"),
      ),
      body: ListView(
        children: [
          Center(
            child: Container( width: 200, height: 400,
              child: CustomBarGraph(
                xLabels: ['1set', '2set', '3set', '4set', '5set'],
                yLabels: ['0kg', '20kg', '40kg', '60kg', '80kg', '100kg  '],
                values: [20, 40, 60, 80, 100],
                name: "Bench Press",// 그래프에 표시할 값들
              ),
            ),
          ),
          Center(
            child: Container(  width: 200, height: 400,
              child: CustomBarGraph(
                xLabels: ['1set', '2set', '3set', '4set', '5set'],
                yLabels: ['0kg', '20kg', '40kg', '60kg', '80kg', '100kg  '],
                values: [20, 40, 60, 80, 100],
                name: "Shoulder Press",// 그래프에 표시할 값들
              ),
            ),
          ),
          Center(
            child: Container(  width: 200, height: 400,
              child: CustomBarGraph(
                xLabels: ['1set', '2set', '3set', '4set', '5set'],
                yLabels: ['0kg', '20kg', '40kg', '60kg', '80kg', '100kg  '],
                values: [20, 40, 60, 80, 100],
                name: "Dead Lift",// 그래프에 표시할 값들
              ),
            ),
          ),
          Center(
            child: Container(  width: 200, height: 400,
              child: CustomBarGraph(
                xLabels: ['1set', '2set', '3set', '4set', '5set'],
                yLabels: ['0kg', '20kg', '40kg', '60kg', '80kg', '100kg  '],
                values: [20, 40, 60, 80, 100],
                name: "Squart",// 그래프에 표시할 값들
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar : BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.arrow_left),label: "Back"),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_right),label: "Next"),
        ],
      ),
    );
  }
}
