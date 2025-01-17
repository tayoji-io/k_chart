import 'package:k_chart/entity/k_chart_entity.dart';

final Map<num, IndicatorBarStroke> indicatorBarStrokes = {
  0: CLValueBarStroke(),
};

abstract class IndicatorBarStroke {
  bool calculate({
    required KChartEntity last,
    required KChartEntity cur,
    double? lValue,
    double? cValue,
  });
}

class CLValueBarStroke extends IndicatorBarStroke {
  @override
  bool calculate(
      {required KChartEntity last,
      required KChartEntity cur,
      double? lValue,
      double? cValue}) {
    return (lValue ?? 0) < (cValue ?? 0);
  }
}
