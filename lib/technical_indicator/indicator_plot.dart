import 'package:k_chart/technical_indicator/indicator_bar_stroke.dart';
import 'package:k_chart/technical_indicator/indicator_color.dart';

enum IndicatorPlotType { line, bar, circle }

abstract class IndicatorPlot {
  late String key;
  late String title;
  Map<String, dynamic> toJson() {
    return {"key": key, "title": title};
  }

  IndicatorPlot.create({required this.key, required this.title});
}

class IndicatorLinePlot extends IndicatorPlot {
  IndicatorLinePlot.create({required String key, required String title})
      : super.create(
          key: key,
          title: title,
        );

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "type": 'line'};
  }
}

class IndicatorBarPlot extends IndicatorPlot {
  num baseValue = 0;
  IndicatorBarStroke? indicatorBarStroke;
  IndicatorColor? indicatorColor;
  IndicatorBarPlot.create(
      {required String key,
      required String title,
      required this.baseValue,
      this.indicatorBarStroke,
      this.indicatorColor})
      : super.create(key: key, title: title);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "type": 'bar', 'baseValue': baseValue};
  }
}

class IndicatorCirclePlot extends IndicatorPlot {
  IndicatorCirclePlot.create({
    required String key,
    required String title,
  }) : super.create(key: key, title: title);

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), "type": 'circle'};
  }
}

class IndicatorPlotPoint {
  IndicatorPlot plot;
  double? value;
  IndicatorPlotPoint({required this.plot, this.value});
}
