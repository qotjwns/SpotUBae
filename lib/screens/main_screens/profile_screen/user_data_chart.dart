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
    List<UserData> sortedData = List.from(userDataList)
      ..sort((a, b) => a.date.compareTo(b.date));

    List<FlSpot> weightSpots = [];
    List<FlSpot> bodyFatSpots = [];

    for (int i = 0; i < sortedData.length; i++) {
      weightSpots.add(FlSpot(i.toDouble(), sortedData[i].weight.toDouble()));
      bodyFatSpots
          .add(FlSpot(i.toDouble(), sortedData[i].bodyFat.toDouble() * 2));
    }

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              interval: 20,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                double bodyFatValue = value - 20;
                return Text(
                  '${bodyFatValue.toInt()}%',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData:
        FlBorderData(show: true, border: Border.all(color: Colors.black)),
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
    );
  }
}