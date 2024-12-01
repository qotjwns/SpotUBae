// lib/widgets/widget_for_profile/user_data_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/user_data.dart';


class UserDataChart extends StatelessWidget {
  final List<UserData> userDataList;
  final double maxY;

  const UserDataChart({
    super.key,
    required this.userDataList,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    if (userDataList.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    List<UserData> sortedData = List.from(userDataList)
      ..sort((a, b) => a.date.compareTo(b.date));

    List<FlSpot> weightSpots = [];
    List<FlSpot> bodyFatSpots = [];

    for (int i = 0; i < sortedData.length; i++) {
      weightSpots.add(FlSpot(i.toDouble(), sortedData[i].weight.toDouble()));
      bodyFatSpots.add(FlSpot(i.toDouble(), sortedData[i].bodyFat.toDouble()));
    }

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10, // 체지방률 10% 단위
                    getTitlesWidget: (value, meta) {
                      double bodyFatValue = value;
                      if (bodyFatValue % 10 == 0) { // 10% 단위로 표시
                        return Text(
                          '${bodyFatValue.toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < sortedData.length) {
                        DateTime date = sortedData[index].date;
                        String formattedDate = "${date.month}/${date.day}";
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 20, // 무게 20kg 단위
                    getTitlesWidget: (value, meta) {
                      if (value % 20 == 0) {
                        return Text(
                          '${value.toInt()}kg',
                          style: const TextStyle(fontSize: 10),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 20,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey,
                  strokeWidth: 0.5,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey,
                  strokeWidth: 0.5,
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: weightSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: const FlDotData(show: true),
                ),
                LineChartBarData(
                  spots: bodyFatSpots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 2,
                  dotData: const FlDotData(show: true),
                ),
              ],
              minY: 0,
              maxY: maxY,
            ),
          ),
        ),

      ],
    );
  }
}
