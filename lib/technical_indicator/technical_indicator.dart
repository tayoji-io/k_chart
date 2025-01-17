import 'package:k_chart/entity/k_chart_entity.dart';
import 'package:k_chart/technical_indicator/indicator_plot.dart';

Future<void> calcTechnicalIndicator(
    List<KChartEntity> dataList,
    List<TechnicalIndicator> mainIndicators,
    List<TechnicalIndicator> secondaryIndicators) async {
  List<List<TechnicalIndicatorPlotPoints>> mainPlotPoints = [];
  List<List<TechnicalIndicatorPlotPoints>> secondaryPlotPoints = [];

  for (var item in mainIndicators) {
    item.datas = await item.calcTechnicalIndicator(dataList);

    if (dataList.length == item.datas.length) {
      mainPlotPoints.add(item.datas);
    }
  }
  for (var item in secondaryIndicators) {
    item.datas = await item.calcTechnicalIndicator(dataList);
    if (dataList.length == item.datas.length) {
      secondaryPlotPoints.add(item.datas);
    }
  }

  for (var i = 0; i < dataList.length; i++) {
    List<TechnicalIndicatorPlotPoints> mainPlot = [];
    List<TechnicalIndicatorPlotPoints> secondaryPlot = [];
    for (var item in mainPlotPoints) {
      mainPlot.add(item[i]);
    }
    for (var item in secondaryPlotPoints) {
      secondaryPlot.add(item[i]);
    }
    dataList[i].mainPlot = mainPlot;
    dataList[i].secondaryPlot = secondaryPlot;
  }
}

abstract class TechnicalIndicator {
  late String name;
  late String shortName;
  late List<num> calcParams;
  late List<IndicatorPlot> plots;

  List<TechnicalIndicatorPlotPoints> datas = [];
  // num? maxValue;
  // num? minValue;

  Future<List<TechnicalIndicatorPlotPoints>> calcTechnicalIndicator(
      List<KChartEntity> dataList);

  TechnicalIndicator.create(
      {required this.name,
      required this.shortName,
      required this.calcParams,
      required this.plots});
}

class TechnicalIndicatorPlotPoints {
  late String name;
  late List<dynamic> calcParams;
  late List<IndicatorPlotPoint> plotPoints;
  TechnicalIndicatorPlotPoints(this.name, this.calcParams, this.plotPoints);
}
