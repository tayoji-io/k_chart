import 'package:flutter/material.dart';

export '../chart_style.dart';

abstract class BaseChartRenderer<T> {
  double maxValue, minValue;
  late double scaleY;
  double topPadding;
  Rect chartRect;
  int fixedLength;
  Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = Colors.red;
  Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5
    ..color = Color(0xff4c5c74);

  BaseChartRenderer({
    required this.chartRect,
    required this.maxValue,
    required this.minValue,
    required this.topPadding,
    required this.fixedLength,
    required Color gridColor,
  }) {
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = chartRect.height / (maxValue - minValue);
    gridPaint.color = gridColor;
  }

  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

  String format(double? n) {
    if (n == null || n.isNaN) {
      return "0.00";
    } else {
      if (n > 1000 * 1000 * 100 * 10) {
        return (n / 1000 / 1000 / 1000).toStringAsFixed(fixedLength) + "B";
      }
      if (n > 1000 * 1000 * 10) {
        return (n / 1000 / 1000).toStringAsFixed(fixedLength) + "M";
      }
      if (n > 1000 * 10) {
        return (n / 1000).toStringAsFixed(fixedLength) + "K";
      }

      return n.toStringAsFixed(fixedLength);
    }
  }

  void drawGrid(Canvas canvas, int gridRows, int gridColumns);

  void drawText(Canvas canvas, T data, double x);

  void drawVerticalText(canvas, textStyle, int gridRows);

  void drawChart(T lastPoint, T curPoint, double lastX, double curX, Size size,
      Canvas canvas);

  void drawLine(double? lastPrice, double? curPrice, Canvas canvas,
      double lastX, double curX, Color color,
      [double lineWidth = 0.5]) {
    if (lastPrice == null || curPrice == null) {
      return;
    }
    //("lasePrice==" + lastPrice.toString() + "==curPrice==" + curPrice.toString());
    double lastY = getY(lastPrice);
    double curY = getY(curPrice);
    // print('$this $curY  ${lastPrice} ${this.maxValue} ${this.minValue}');
    //print("lastX-----==" + lastX.toString() + "==lastY==" + lastY.toString() + "==curX==" + curX.toString() + "==curY==" + curY.toString());
    canvas.drawLine(
        Offset(lastX, lastY),
        Offset(curX, curY),
        chartPaint
          ..color = color
          ..strokeWidth = lineWidth);
  }

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: 10.0, color: color);
  }
}
