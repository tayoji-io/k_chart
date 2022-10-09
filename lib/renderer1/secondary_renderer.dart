import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k_chart/entity/k_chart_entity.dart';
import 'package:k_chart/technical_indicator/indicator_plot.dart';

import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<KChartEntity> {
  late double mMACDWidth;

  final ChartStyle chartStyle;
  final ChartColors chartColors;
  final int plotIndex;

  SecondaryRenderer(
      Rect mainRect,
      double maxValue,
      double minValue,
      double topPadding,
      int fixedLength,
      this.chartStyle,
      this.chartColors,
      this.plotIndex)
      : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          fixedLength: fixedLength,
          gridColor: chartColors.gridColor,
        ) {
    mMACDWidth = this.chartStyle.macdWidth;
  }

  @override
  void drawChart(KChartEntity lastPoint, KChartEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    try {
      final curPlot = curPoint.secondaryPlot[plotIndex];
      final lastPlot = lastPoint.secondaryPlot[plotIndex];
      for (var i = 0; i < curPlot.plotPoints.length; i++) {
        final cur = curPlot.plotPoints[i];
        final last = lastPlot.plotPoints[i];
        final plot = cur.plot;
        if (plot is IndicatorLinePlot) {
          drawLine(last.value, cur.value, canvas, lastX, curX,
              this.chartColors.plotColors[i]);
        } else if (plot is IndicatorBarPlot) {
          final cValue = cur.value;
          final lValue = last.value;
          final baseValue = plot.baseValue.toDouble();
          if (cValue == null) {
            return;
          }
          double macdY = getY(cValue);
          double r = mMACDWidth / 2;
          double zeroy = getY(baseValue);
          final color = plot.indicatorColor?.calculate(
              last: lastPoint,
              cur: curPoint,
              colors: chartColors,
              lValue: lValue,
              cValue: cValue);
          final isStroke = plot.indicatorBarStroke?.calculate(
                  last: lastPoint,
                  cur: curPoint,
                  lValue: lValue,
                  cValue: cValue) ??
              false;
          if (cValue > baseValue) {
            canvas.drawRect(
                Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
                chartPaint
                  ..color = color ?? this.chartColors.upColor
                  ..style =
                      isStroke ? PaintingStyle.stroke : PaintingStyle.fill);
          } else {
            canvas.drawRect(
                Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
                chartPaint
                  ..style = isStroke ? PaintingStyle.stroke : PaintingStyle.fill
                  ..color = color ?? this.chartColors.upColor);
          }
        } else if (plot is IndicatorCirclePlot) {
          final cValue = cur.value;
          final lValue = last.value;
          if (cValue == null) {
            return;
          }
          final color = plot.indicatorColor?.calculate(
              last: lastPoint,
              cur: curPoint,
              colors: chartColors,
              lValue: lValue,
              cValue: cValue);
          double y = getY(cValue);
          canvas.drawCircle(
              Offset(curX, y),
              chartStyle.circleRadius,
              chartPaint
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.5
                ..color = color ?? chartColors.noChangeColor);
        }
      }
    } catch (e) {}
  }

  @override
  void drawText(Canvas canvas, KChartEntity data, double x) {
    final plots = data.secondaryPlot[plotIndex];
    List<TextSpan> children = [
      TextSpan(
          text: "${plots.name} ${plots.calcParams.map((e) => e.toString())}   ",
          style: getTextStyle(this.chartColors.defaultTextColor))
    ];
    for (var i = 0; i < plots.plotPoints.length; i++) {
      final plot = plots.plotPoints[i];

      children.add(TextSpan(
          text: "${plot.plot.title} ${format(plot.value)}   ",
          style: getTextStyle(this.chartColors.plotColors[i])));
    }
    TextPainter tp = TextPainter(
        text: TextSpan(children: children), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: "${format(maxValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: "${format(minValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(canvas,
        Offset(chartRect.width - maxTp.width, chartRect.top - topPadding));
    minTp.paint(canvas,
        Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    gridPaint..color = chartColors.gridColor;
    canvas.drawLine(Offset(0, chartRect.top),
        Offset(chartRect.width, chartRect.top), gridPaint);
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
