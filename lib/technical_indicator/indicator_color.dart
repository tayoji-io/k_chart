import 'package:k_chart/entity/k_chart_entity.dart';
import 'package:k_chart/renderer1/index.dart';

abstract class IndicatorColor {
  /// cValue 当前指标Value
  ///
  Color calculate({
    required KChartEntity last,
    required KChartEntity cur,
    double? lValue,
    double? cValue,
    required ChartColors colors,
  });
}

class CurValueZeroIndicatorColor extends IndicatorColor {
  @override
  Color calculate({
    required KChartEntity last,
    required KChartEntity cur,
    double? lValue,
    double? cValue,
    required ChartColors colors,
  }) {
    if (cValue == null) {
      return colors.noChangeColor;
    }
    if (cValue > 0) {
      return colors.upColor;
    } else if (cValue < 0) {
      return colors.dnColor;
    }
    return colors.noChangeColor;
  }
}

class CurValueCompareIndicatorColor extends IndicatorColor {
  @override
  Color calculate({
    required KChartEntity last,
    required KChartEntity cur,
    double? lValue,
    double? cValue,
    required ChartColors colors,
  }) {
    if (cValue == null || lValue == null) {
      return colors.noChangeColor;
    }
    if (cValue > lValue) {
      return colors.upColor;
    } else {
      return colors.dnColor;
    }
  }
}

class CurOpenCloseIndicatorColor extends IndicatorColor {
  @override
  Color calculate({
    required KChartEntity last,
    required KChartEntity cur,
    double? lValue,
    double? cValue,
    required ChartColors colors,
  }) {
    if (cur.close > cur.open) {
      return colors.upColor;
    } else if (cur.close < cur.open) {
      return colors.dnColor;
    }
    return colors.noChangeColor;
  }
}
