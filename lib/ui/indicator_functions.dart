import 'package:flutter/cupertino.dart';

class Range {
  num end;
  num start;
  bool isUnbounded;

  @override
  String toString() {
    return 'Range(start: $start end: $end)';
  }

  Range.normal({required this.start, required this.end}) : isUnbounded = false;
  Range.unBoundedMax({
    required this.start,
  })  : end = double.infinity,
        isUnbounded = true;
  Range.unBoundedMin({
    required this.end,
  })  : start = -double.infinity,
        isUnbounded = true;
}

class RangeInfo {
  late num end;
  Color? color;

  @override
  String toString() {
    return 'RangeInfo(end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return other is RangeInfo && end == other.end;
  }

  RangeInfo({required this.end, this.color});

  @override
  int get hashCode => end.hashCode;
}

List<RangeInfo> checkIfRangesIsValid(List<RangeInfo> l, RangeType rangeType) {
  if (l.length < 2) {
    throw FlutterErrorDetails(
        exception: Exception('RANGES ERROR'),
        informationCollector: () {
          return [DiagnosticsNode.message('must have at least two ranges')];
        });
  }
  List<RangeInfo> data = [];
  data.addAll(l);
  data.sort(
        (a, b) {
      return a.end.compareTo(b.end);
    },
  );
  if (rangeType == RangeType.unBounded ||
      rangeType == RangeType.unBoundedMin) {}
  Map<num, bool> table = {};
  int duplicated = 0;
  for (int i = 0; i < data.length; i++) {
    if (table[data[i].end] == null) {
      table[data[i].end] = true;
    } else {
      if (table[data[i].end] == true) {
        duplicated++;
      }
    }
  }
  if (duplicated > 0) {
    throw FlutterErrorDetails(
        exception: Exception('RANGES ERROR'),
        informationCollector: () {
          return [DiagnosticsNode.message('Ranges must be unique')];
        });
  }
  return data;
}

bool isDiffLists(List<RangeInfo> old, List<RangeInfo> recent) {
  if (old.length != recent.length) {
    return true;
  }
  old.sort(
        (a, b) {
      return a.end.compareTo(b.end);
    },
  );
  recent.sort(
        (a, b) {
      return a.end.compareTo(b.end);
    },
  );
  for (int i = 0; i < old.length; i++) {
    if (recent[i] != old[i]) {
      return true;
    }
  }
  return false;
}

// min max
//1 10
//1 2 3 4 5 6 7 8 9 10
//
enum RangeType { unBoundedMax, unBoundedMin, unBounded, fixed }
