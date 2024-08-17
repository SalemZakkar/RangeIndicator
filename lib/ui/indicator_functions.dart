import 'package:flutter/cupertino.dart';

class Range {
  num end;
  num start;
  Color? color;

  @override
  String toString() {
    return "Range(start: $start end: $end)";
  }

  Range({required this.start, required this.end, this.color});
}

class RangeInfo {
  num end;
  Color? color;

  @override
  String toString() {
    return "RangeInfo(end: $end)";
  }

  RangeInfo({required this.end, this.color});
}

List<RangeInfo> checkIfRangesIsValid(List<RangeInfo> l, num min) {
  if (l.length < 2) {
    throw FlutterErrorDetails(
        exception: Exception("RANGES ERROR"),
        informationCollector: () {
          return [DiagnosticsNode.message("must have at least two ranges")];
        });
  }
  List<RangeInfo> data = [];
  data.addAll(l);
  data.sort(
    (a, b) {
      return a.end.compareTo(b.end);
    },
  );
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
        exception: Exception("RANGES ERROR"),
        informationCollector: () {
          return [DiagnosticsNode.message("Ranges must be unique")];
        });
  }
  return data;
}

// min max
//1 10
//1 2 3 4 5 6 7 8 9 10
//
