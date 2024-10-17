import 'package:flutter/material.dart';

class CustomBarGraph extends StatelessWidget {
  final List<String> xLabels; // X축 레이블들
  final List<String> yLabels; // Y축 레이블들
  final List<double> values;  // 막대 그래프에 표시할 값들
  String name;
  CustomBarGraph({required this.xLabels, required this.yLabels, required this.values,required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Container(
          width: 300,
          height: 200,
          padding: EdgeInsets.all(16.0),
          child: CustomPaint(
            painter: BarGraphPainter(xLabels: xLabels, yLabels: yLabels, values: values),
          ),
        ),
      ),
    );
  }
}

class BarGraphPainter extends CustomPainter {
  final List<String> xLabels;
  final List<String> yLabels;
  final List<double> values;

  BarGraphPainter({required this.xLabels, required this.yLabels, required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    double barWidth = size.width / (values.length * 2);
    double maxBarHeight = size.height * 0.7; // 그래프 영역
    double maxValue = 100.0; // 최대 y축 값

    Paint barPaint = Paint()..color = Colors.blue;
    Paint axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    // Y축 그리기
    canvas.drawLine(Offset(40, 0), Offset(40, size.height), axisPaint);

    // X축 그리기
    canvas.drawLine(Offset(40, size.height - 20), Offset(size.width, size.height - 20), axisPaint);

    // 막대 그래프 그리기
    for (int i = 0; i < values.length; i++) {
      double barHeight = (values[i] / maxValue) * maxBarHeight;
      Offset barTopLeft = Offset(40 + i * (2 * barWidth), size.height - 20 - barHeight);
      Offset barBottomRight = Offset(40 + i * (2 * barWidth) + barWidth, size.height - 20);

      canvas.drawRect(Rect.fromPoints(barTopLeft, barBottomRight), barPaint);

      // X축 레이블 그리기
      _drawText(canvas, xLabels[i], Offset(40 + i * (2 * barWidth), size.height - 20 + 5));
    }

    // Y축 값 그리기
    for (int i = 0; i < yLabels.length; i++) {
      double y = size.height - 20 - (i * maxBarHeight / (yLabels.length - 1));
      _drawText(canvas, yLabels[i], Offset(10, y - 10)); // Y축 값 텍스트
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}