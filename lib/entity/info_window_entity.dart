import 'package:k_chart/entity/k_chart_entity.dart';

class InfoWindowEntity {
  KChartEntity kLineEntity;
  bool isLeft;

  InfoWindowEntity(
    this.kLineEntity, {
    this.isLeft = false,
  });
}
