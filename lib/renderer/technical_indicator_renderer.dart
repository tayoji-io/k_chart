import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k_chart/renderer/index.dart';
import 'package:k_chart/technical_indicator/technical_indicator.dart';

import '../k_chart_widget.dart' show SecondaryState;
import 'base_chart_renderer.dart';

class TechnicalIndicatorRenderer extends BaseChartRenderer<TechnicalIndicator> {
  late double mMACDWidth;
  SecondaryState state;
  final ChartStyle chartStyle;
  final ChartColors chartColors;

  TechnicalIndicatorRenderer(
      Rect mainRect,
      double maxValue,
      double minValue,
      double topPadding,
      this.state,
      int fixedLength,
      this.chartStyle,
      this.chartColors)
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
  void drawChart(TechnicalIndicator lastPoint, TechnicalIndicator curPoint,
      double lastX, double curX, Size size, Canvas canvas) {
    // TODO: implement drawChart
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    // TODO: implement drawGrid
  }

  @override
  void drawText(Canvas canvas, TechnicalIndicator data, double x) {
    // TODO: implement drawText
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    // TODO: implement drawVerticalText
  }
}
