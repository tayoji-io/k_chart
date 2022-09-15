import 'package:k_chart/entity/k_chart_entity.dart';
import 'package:k_chart/extension/num_ext.dart';
import 'package:k_chart/technical_indicator/indicator_plot.dart';

calcTechnicalIndicator(
    List<KChartEntity> dataList,
    List<TechnicalIndicator> mainIndicators,
    List<TechnicalIndicator> secondaryIndicators) {
  List<List<List<IndicatorPlotPoint>>> mainPlotPoints = [];
  List<List<List<IndicatorPlotPoint>>> secondaryPlotPoints = [];

  for (var item in mainIndicators) {
    item.datas = item.calcTechnicalIndicator(dataList);
    final values = item.datas
        .map((e) => e.map((e) => e.value).toList())
        .toList()
        .fold<List<num?>>(
            [], (previousValue, element) => previousValue + element);
    if (values.length == item.datas.length) {
      mainPlotPoints.add(item.datas);
    }
    item.maxValue = values.maxValue;
    item.minValue = values.minValue;
  }

  for (var item in secondaryIndicators) {
    item.datas = item.calcTechnicalIndicator(dataList);
    final values = item.datas
        .map((e) => e.map((e) => e.value).toList())
        .toList()
        .fold<List<num?>>(
            [], (previousValue, element) => previousValue + element);
    if (values.length == item.datas.length) {
      secondaryPlotPoints.add(item.datas);
    }
    item.maxValue = values.maxValue;
    item.minValue = values.minValue;
  }

  for (var i = 0; i < dataList.length; i++) {
    List<List<IndicatorPlotPoint>> mainPlot = [];
    List<List<IndicatorPlotPoint>> secondaryPlot = [];
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

  List<List<IndicatorPlotPoint>> datas = [];
  num? maxValue;
  num? minValue;

  List<List<IndicatorPlotPoint>> calcTechnicalIndicator(
      List<KChartEntity> dataList);

  TechnicalIndicator.create(
      {required this.name,
      required this.shortName,
      required this.calcParams,
      required this.plots});
}
