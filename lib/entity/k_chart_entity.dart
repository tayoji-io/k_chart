import 'package:k_chart/technical_indicator/technical_indicator.dart';

class KChartEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  late int time;
  List<TechnicalIndicatorPlotPoints> mainPlot = [];

  List<TechnicalIndicatorPlotPoints> secondaryPlot = [];
  double? MA5Volume;
  double? MA10Volume;

  Map<String, dynamic> toJson() {
    return {
      "open": open,
      "close": close,
      "low": low,
      "high": high,
      "volume": vol,
      "time": time
    };
  }
}
