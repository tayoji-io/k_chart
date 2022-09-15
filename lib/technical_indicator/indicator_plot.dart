enum IndicatorPlotType { line, bar, circle }

abstract class IndicatorPlot {
  late String key;
  late String title;
  IndicatorPlot.create({required this.key, required this.title});
}

class IndicatorLinePlot extends IndicatorPlot {
  num baseValue = 0;
  IndicatorLinePlot.create(
      {required String key, required String title, required this.baseValue})
      : super.create(
          key: key,
          title: title,
        );
}

class IndicatorBarPlot extends IndicatorPlot {
  IndicatorBarPlot.create({
    required String key,
    required String title,
  }) : super.create(key: key, title: title);
}

class IndicatorCirclePlot extends IndicatorPlot {
  IndicatorCirclePlot.create({
    required String key,
    required String title,
  }) : super.create(key: key, title: title);
}

class IndicatorPlotPoint {
  IndicatorPlot plot;
  double? value;
  IndicatorPlotPoint({required this.plot, this.value});
}
