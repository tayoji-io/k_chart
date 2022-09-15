extension NumExt on num? {
  bool get notNullOrZero {
    if (this == null || this == 0) {
      return false;
    }
    return this!.abs().toStringAsFixed(4) != "0.0000";
  }
}

extension ListNumExt on List<num?> {
  num? get maxValue {
    if (this.length == 0) return null;
    var value = this[0];
    for (var item in this) {
      if (item != null) {
        value = value ?? item;
        if (item > value) {
          value = item;
        }
      }
    }
    return value;
  }

  num? get minValue {
    if (this.length == 0) return null;
    var value = this[0];
    for (var item in this) {
      if (item != null) {
        value = value ?? item;
        if (item < value) {
          value = item;
        }
      }
    }
    return value;
  }
}
