import 'dart:convert';

import 'package:example/technicalindicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/chart_translations.dart';
import 'package:k_chart/entity/k_chart_entity.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/technical_indicator/indicator_plot.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<KlineData>? datas;
  List<TechnicalIndicator> mainIndicators = [];
  List<TechnicalIndicator> secondaryIndicators = [];
  bool showLoading = true;
  var parseTime = 0;

  bool _volHidden = false;

  bool isLine = false;
  bool isChinese = true;
  bool _hideGrid = false;
  bool _showNowPrice = true;
  List<DepthEntity>? _bids, _asks;
  bool isChangeUI = false;
  bool _isTrendLine = false;
  bool _priceLeft = true;
  VerticalTextAlignment _verticalTextAlignment = VerticalTextAlignment.left;

  ChartStyle chartStyle = ChartStyle()..secondaryHeight = 50;
  ChartColors chartColors = ChartColors();

  @override
  void initState() {
    super.initState();
    getData('1day');
    rootBundle.loadString('assets/depth.json').then((result) {
      final parseJson = json.decode(result);
      final tick = parseJson['tick'] as Map<String, dynamic>;
      final List<DepthEntity> bids = (tick['bids'] as List<dynamic>)
          .map<DepthEntity>(
              (item) => DepthEntity(item[0] as double, item[1] as double))
          .toList();
      final List<DepthEntity> asks = (tick['asks'] as List<dynamic>)
          .map<DepthEntity>(
              (item) => DepthEntity(item[0] as double, item[1] as double))
          .toList();
      initDepth(bids, asks);
    });
  }

  test() async {
    showLoading = false;

    final start = DateTime.now();
    if (datas == null || datas!.length == 0) {
      final data1 = await rootBundle.loadString('assets/chatData.json');
      var data = json.decode(data1) as List;

      datas = data
          .map((e) => KlineData.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final List<TechnicalIndicator> mains = [
      // KJsonIndicator.create(js: TechnicalindicatorJs.bbi),
      // KJsonIndicator.create(js: ema),
      // KJsonIndicator.create(js: ma),
      // KJsonIndicator.create(js: TechnicalindicatorJs.sma),
      KJsonIndicator.create(js: TechnicalindicatorJs.boll),
      // KJsonIndicator.create(js: TechnicalindicatorJs.sar),
    ];

    final List<TechnicalIndicator> secondarys = [
      // KJsonIndicator.create(js: TechnicalindicatorJs.kdj),
      // KJsonIndicator.create(js: TechnicalindicatorJs.macd),
      // KJsonIndicator.create(js: TechnicalindicatorJs.vol),
    ];

    final jsonTime = DateTime.now();

    await calcTechnicalIndicator(datas!, mains, secondarys);
    secondaryIndicators = secondarys;
    mainIndicators = mains;
    final parseTimea = DateTime.now();
    parseTime =
        parseTimea.millisecondsSinceEpoch - jsonTime.millisecondsSinceEpoch;
    print(
        "parseTime ${parseTimea.millisecondsSinceEpoch - jsonTime.millisecondsSinceEpoch}");
    print(
        "parseTime ${jsonTime.millisecondsSinceEpoch - start.millisecondsSinceEpoch}");

    setState(() {});
  }

  void initDepth(List<DepthEntity>? bids, List<DepthEntity>? asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = [];
    _asks = [];
    double amount = 0.0;
    bids.sort((left, right) => left.price.compareTo(right.price));
    //累加买入委托量
    bids.reversed.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _bids!.insert(0, item);
    });

    amount = 0.0;
    asks.sort((left, right) => left.price.compareTo(right.price));
    //累加卖出委托量
    asks.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _asks!.add(item);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Stack(children: <Widget>[
          Container(
            height: 300 +
                secondaryIndicators.length *
                    (chartStyle.secondaryHeight! + chartStyle.childPadding),
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: KLineChart(
              datas,
              chartStyle,
              chartColors,
              isLine: isLine,
              onSecondaryTap: () {
                print('Secondary Tap');
              },
              isTrendLine: _isTrendLine,
              volHidden: _volHidden,
              fixedLength: 2,
              timeFormat: TimeFormat.YEAR_MONTH_DAY,
              translations: kChartTranslations,
              showNowPrice: _showNowPrice,
              isChinese: isChinese,
              hideGrid: _hideGrid,
              isTapShowInfoDialog: true,
              verticalTextAlignment: _verticalTextAlignment,
              maDayList: [1, 100, 1000],
              mainIndicators: mainIndicators,
              secondaryIndicators: secondaryIndicators,
            ),
          ),
          if (showLoading)
            Container(
                width: double.infinity,
                height: 450,
                alignment: Alignment.center,
                child: const CircularProgressIndicator()),
        ]),
        buildButtons(),
        Container(child: Text('parseTime $parseTime')),
        if (_bids != null && _asks != null)
          Container(
            height: 230,
            width: double.infinity,
            child: DepthChart(_bids!, _asks!, chartColors),
          )
      ],
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button("Refresh", onPressed: () {
          // isLine = true;
          test();
        }),
        // button("K Line Mode", onPressed: () => isLine = false),
        // button("TrendLine", onPressed: () => _isTrendLine = !_isTrendLine),
        // button(_volHidden ? "Show Vol" : "Hide Vol",
        //     onPressed: () => _volHidden = !_volHidden),
        // button("Change Language", onPressed: () => isChinese = !isChinese),
        // button(_hideGrid ? "Show Grid" : "Hide Grid",
        //     onPressed: () => _hideGrid = !_hideGrid),
        // button(_showNowPrice ? "Hide Now Price" : "Show Now Price",
        //     onPressed: () => _showNowPrice = !_showNowPrice),
        // button("Customize UI", onPressed: () {
        //   setState(() {
        //     this.isChangeUI = !this.isChangeUI;
        //     if (this.isChangeUI) {
        //       chartColors.selectBorderColor = Colors.red;
        //       chartColors.selectFillColor = Colors.red;
        //       chartColors.lineFillColor = Colors.red;
        //       chartColors.kLineColor = Colors.yellow;
        //     } else {
        //       chartColors.selectBorderColor = Color(0xff6C7A86);
        //       chartColors.selectFillColor = Color(0xff0D1722);
        //       chartColors.lineFillColor = Color(0x554C86CD);
        //       chartColors.kLineColor = Color(0xff4C86CD);
        //     }
        //   });
        // }),
        // button("Change PriceTextPaint",
        //     onPressed: () => setState(() {
        //           _priceLeft = !_priceLeft;
        //           if (_priceLeft) {
        //             _verticalTextAlignment = VerticalTextAlignment.left;
        //           } else {
        //             _verticalTextAlignment = VerticalTextAlignment.right;
        //           }
        //         })),
      ],
    );
  }

  Widget button(String text, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      child: Text(text),
      style: TextButton.styleFrom(
        primary: Colors.white,
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void getData(String period) {
    /*
     * 可以翻墙使用方法1加载数据，不可以翻墙使用方法2加载数据，默认使用方法1加载最新数据
     */
    final Future<String> future = getChatDataFromJson();
    //final Future<String> future = getChatDataFromJson();
    future.then((String result) {}).catchError((_) {
      showLoading = false;
      setState(() {});
      print('### datas error $_');
    });
  }

  //获取火币数据，需要翻墙
  Future<String> getChatDataFromInternet(String? period) async {
    var url =
        'https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    late String result;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      print('Failed getting IP address');
    }
    return result;
  }

  // 如果你不能翻墙，可以使用这个方法加载数据
  Future<String> getChatDataFromJson() async {
    return rootBundle.loadString('assets/chatData.json');
  }
}

class KlineData extends KChartEntity {
  KlineData.fromJson(Map<String, dynamic> data) {
    this.open = (data['open'] as num).toDouble();
    this.close = (data['close'] as num).toDouble();
    this.low = (data['low'] as num).toDouble();
    this.high = (data['high'] as num).toDouble();
    this.vol = (data['vol'] as num).toDouble();
    this.time = (data['id'] as num).toInt() * 1000;
  }
}

class KJsonIndicator extends TechnicalIndicator {
  final String js;
  KJsonIndicator.create({
    required this.js,
  }) : super.create(name: '', shortName: '', calcParams: [], plots: []);

  @override
  Future<List<TechnicalIndicatorPlotPoints>> calcTechnicalIndicator(
      List<KChartEntity> dataList) async {
    try {
      final engine = IsolateQjs(
        stackSize: 1024 * 1024, // change stack size here.
        moduleHandler: (a) async {
          return js;
        },
      );
      name = await engine.evaluate('''
import("hello").then(({default: greet}) => greet.name)
''');
      shortName = await engine.evaluate('''
import("hello").then(({default: greet}) => greet.shortName)
''');
      calcParams = ((await engine.evaluate('''
import("hello").then(({default: greet}) => greet.calcParams)
''')) as List).map((e) => e as num).toList();

      plots = ((await engine.evaluate('''
import("hello").then(({default: greet}) => greet.plots)
''')) as List)
          .map((e) {
            final d = e as Map;
            final type = d['type'] as String;
            final key = e['key'];
            final title = e['title'];
            final color = e['color'];
            final stroke = e['stroke'];

            switch (type) {
              case "line":
                return IndicatorLinePlot.create(key: key, title: title);
              case "bar":
                return IndicatorBarPlot.create(
                    indicatorColor: indicatorColors[color],
                    indicatorBarStroke: indicatorBarStrokes[stroke],
                    key: key,
                    title: title,
                    baseValue: d["baseValue"] ?? 0);
              case "circle":
                return IndicatorCirclePlot.create(
                  key: key,
                  title: title,
                  indicatorColor: indicatorColors[color],
                );
            }
            return null;
          })
          .where((element) => element != null)
          .map((e) => e!)
          .toList();

      final points = ((await engine.evaluate('''
import("hello").then(({default: greet}) => greet.calcTechnicalIndicator(${json.encode(dataList.map((e) => e.toJson()).toList())},{
  params:${calcParams},
  plots: ${json.encode(plots.map((e) => e.toJson()).toList())}
}))
''')) as List).map((e) {
        var d = e as Map;
        return TechnicalIndicatorPlotPoints(
            name,
            calcParams,
            plots.map((e) {
              final v = d[e.key];
              if (v != null && v is num) {
                return IndicatorPlotPoint(plot: e, value: v.toDouble());
              }
              return IndicatorPlotPoint(plot: e);
            }).toList());
      }).toList();

      return points;
    } catch (e) {
      print('---e-----$e $name');
    }
    return [];
  }
}
