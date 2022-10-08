import 'package:k_chart/technical_indicator/technical_indicator.dart';

class KChartEntity {
  double open = 0;
  double high = 0;
  double low = 0;
  double close = 0;
  double vol = 0;
  int time = 0;
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
