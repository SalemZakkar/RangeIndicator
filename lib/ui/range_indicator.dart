import 'dart:math';
import 'package:flutter/material.dart';
import 'package:range_indicator/ui/range_render.dart';

import 'indicator_functions.dart';

class RangeIndicator extends StatefulWidget {
  final List<RangeInfo> ranges;
  final double? initialValue;
  final Axis axis;
  final num min;
  final ValueChanged<List<Range>> onChanged;
  final double thumbRadius;
  final double railWidth;
  final bool enable;
  final num Function(num n) numberBuilder;
  final ValueChanged<num>? onMinChanged;
  final ValueChanged<num>? onMaxChanged;
  final num? segment;
  final num? safeZone;
  final RangeType rangeType;
  final num unBoundedPush;
  final Duration? animationsDuration;
  final RangeIndicatorController? controller;

  const RangeIndicator(
      {super.key,
      required this.ranges,
      this.axis = Axis.horizontal,
      required this.min,
      required this.onChanged,
      required this.numberBuilder,
      this.initialValue,
      this.railWidth = 5,
      this.enable = true,
      this.segment,
      this.thumbRadius = 15,
      required this.rangeType,
      this.animationsDuration,
      this.safeZone,
      this.unBoundedPush = 0,
      this.onMaxChanged,
      this.onMinChanged,
      this.controller});

  @override
  State<RangeIndicator> createState() => _RangeIndicatorState();
}

class _RangeIndicatorState extends State<RangeIndicator> {
  List<RangeInfo> ranges = [];
  bool initiated = false;
  GlobalKey keyV = GlobalKey(), keyH = GlobalKey();

  @override
  void didUpdateWidget(covariant RangeIndicator oldWidget) {
    if (widget.rangeType != oldWidget.rangeType) {
      initiated = false;
      init();
      setState(() {});
    }
    if (oldWidget.ranges.length != widget.ranges.length) {
      initiated = false;
      init();
      setState(() {});
    }
    if (isDiffLists(oldWidget.ranges, widget.ranges)) {
      initiated = false;
      init();
      setState(() {});
    }
    if (oldWidget.min != widget.min) {
      initiated = false;
      init();
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    init();
    widget.controller?.addListener(() {
      if (widget.controller?.isRefresh == true) {
        initiated = false;
        init(initialMin: start, initial: widget.ranges);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.dispose();
  }

  void init({List<RangeInfo>? initial, num? initialMin}) {
    if (initiated) {
      return;
    }
    initiated = true;
    start = initialMin?.toDouble() ?? widget.min.toDouble();
    ranges = checkIfRangesIsValid(initial ?? widget.ranges, widget.rangeType);
    end = ranges.last.end.toDouble();
    ruler = (end - start).abs();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      update();
    });
  }

  double totalWidth = 0,
      totalHeight = 0,
      start = 0,
      end = 0,
      disZero = 0,
      ruler = 0,
      padding = 20,
      startXY = 0;

  double getPixelsForEach(int i) {
    double e = 0, s = 0;
    if (i == 0) {
      s = start;
      e = ranges[i].end.toDouble();
    } else {
      s = ranges[i - 1].end.toDouble();
      e = ranges[i].end.toDouble();
    }

    return ((e - s) / (ruler)) *
        ((widget.axis == Axis.horizontal ? totalWidth : totalHeight) - padding);
  }

  double getPixelsForEachValue(num val) {
    return (val / (ruler)) *
        ((widget.axis == Axis.horizontal ? totalWidth : totalHeight) - padding);
  }

  // double calcThumbSafePush(int i) {
  //   if (i == ranges.length - 1) {
  //     return 0;
  //   }
  //   if (getPush(i + 1) - getPush(i) < (widget.thumbRadius / 4)) {
  //     return widget.thumbRadius / 2 + calcThumbSafePush(i + 1);
  //   }
  //   return 0;
  // }

  double getPush(int i) {
    double f = 0;
    if (i == 0) {
      return 0;
    }
    for (int j = 0; j < i; j++) {
      f += getPixelsForEach(j);
    }
    return f;
  }

  void update() {
    num k = widget.numberBuilder(widget.segment ?? 0);
    List<Range> r = [];
    if (widget.rangeType == RangeType.unBounded ||
        widget.rangeType == RangeType.unBoundedMin) {
      r.add(Range.unBoundedMin(
        end: widget.numberBuilder.call(ranges.first.end),
      ));
    } else {
      r.add(Range.normal(
          start: widget.numberBuilder.call(start),
          end: widget.numberBuilder.call(ranges.first.end)));
    }
    for (int i = 1; i < ranges.length - 1; i++) {
      r.addAll([
        Range.normal(
            start: widget.numberBuilder.call(ranges[i - 1].end + k),
            end: widget.numberBuilder.call(ranges[i].end))
      ]);
    }
    if (widget.rangeType == RangeType.unBounded ||
        widget.rangeType == RangeType.unBoundedMax) {
      r.addAll([
        Range.unBoundedMax(
          start: widget.numberBuilder.call(ranges[ranges.length - 2].end + k),
        )
      ]);
    } else {
      r.add(Range.normal(
        start: widget.numberBuilder.call(ranges[ranges.length - 2].end + k),
        end: widget.numberBuilder.call(ranges[ranges.length - 1].end + k),
      ));
    }
    widget.onChanged.call(r);
  }

  @override
  Widget build(BuildContext context) {
    return MeasureSize(
      onChange: (offset) {
        setState(() {
          startXY = widget.axis == Axis.horizontal
              ? offset.dx.abs()
              : offset.dy.abs();
        });
      },
      child: SizedBox(
        width: widget.axis == Axis.horizontal
            ? MediaQuery.of(context).size.width
            : null,
        height: widget.axis == Axis.vertical
            ? MediaQuery.of(context).size.height
            : null,
        child: _ColOrRow(
          axis: widget.axis,
          children: [
            Container(
              alignment: Alignment.center,
              // color: Colors.red,
              width: widget.axis == Axis.horizontal
                  ? null
                  : max(widget.thumbRadius, widget.railWidth) + 1,
              height: widget.axis == Axis.vertical
                  ? null
                  : max(widget.thumbRadius, widget.railWidth) + 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  totalWidth = constraints.maxWidth;
                  totalHeight = constraints.maxHeight;
                  init();
                  return Stack(
                    children: [
                      SizedBox(
                        width: widget.axis == Axis.horizontal
                            ? null
                            : max(widget.thumbRadius, widget.railWidth) + 1,
                        height: widget.axis == Axis.vertical
                            ? null
                            : max(widget.thumbRadius, widget.railWidth) + 1,
                        child: widget.axis == Axis.horizontal
                            ? RailBuilder(
                                axis: widget.axis,
                                child: Row(
                                  key: keyH,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (int i = 0; i < ranges.length; i++)
                                      _Rail(
                                        start: i,
                                        axis: widget.axis,
                                        end: ranges.length,
                                        width: getPixelsForEach(i),
                                        height: widget.railWidth,
                                        color: ranges[i].color,
                                        from: i == 0
                                            ? widget.min
                                            : ranges[i - 1].end,
                                        to: ranges[i].end,
                                      ),
                                  ],
                                ),
                                // onBuild: (val) {
                                //   setState(() {
                                //     startXY = val;
                                //   });
                                // }
                              )
                            : RailBuilder(
                                axis: widget.axis,
                                // onBuild: (val) {
                                //   setState(() {
                                //     startXY = val;
                                //   });
                                // },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    for (int i = 0; i < ranges.length; i++)
                                      _Rail(
                                        start: i,
                                        axis: widget.axis,
                                        end: ranges.length,
                                        height: getPixelsForEach(i),
                                        width: widget.railWidth,
                                        color: ranges[i].color,
                                        from: i == 0
                                            ? widget.min
                                            : ranges[i - 1].end,
                                        to: ranges[i].end,
                                      ),
                                  ],
                                ),
                              ),
                      ),
                      for (int i = 1; i < ranges.length; i++)
                        Positioned(
                          left: widget.axis == Axis.horizontal
                              ? getPush(i)
                              : null,
                          top: widget.axis == Axis.vertical ? getPush(i) : 1,
                          child: _Thumb(
                              safeZone: widget.safeZone,
                              maximumViolated: () {
                                if (i != ranges.length - 1) {
                                  return;
                                }
                                if (widget.rangeType == RangeType.unBounded ||
                                    widget.rangeType ==
                                        RangeType.unBoundedMax) {
                                  RangeInfo r = ranges.last;
                                  ranges[ranges.length - 1] = RangeInfo(
                                      end: r.end + widget.unBoundedPush,
                                      color: r.color);

                                  initiated = false;
                                  init(initial: ranges, initialMin: start);
                                  widget.onMaxChanged?.call(widget.numberBuilder
                                      .call(r.end + widget.unBoundedPush));
                                  setState(() {});
                                }
                              },
                              minimumViolated: () {
                                if (i != 1) {
                                  return;
                                }
                                if (widget.rangeType == RangeType.unBounded ||
                                    widget.rangeType ==
                                        RangeType.unBoundedMin) {
                                  initiated = false;
                                  start -= widget.unBoundedPush;
                                  init(initial: ranges, initialMin: start);
                                  widget.onMinChanged
                                      ?.call(widget.numberBuilder.call(start));
                                  setState(() {});
                                }
                              },
                              enable: widget.enable,
                              cord: startXY,
                              radius: widget.thumbRadius,
                              start: start,
                              axis: widget.axis,
                              maximum: ranges[i].end,
                              minimum: i - 1 == 0 ? start : ranges[i - 2].end,
                              color: ranges[i - 1].color,
                              maxPixels: widget.axis == Axis.horizontal
                                  ? totalWidth
                                  : totalHeight,
                              ruler: ruler,
                              positionChanged: (val) {
                                setState(() {
                                  ranges[i - 1].end = val;
                                });
                                update();
                              }),
                        )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatefulWidget {
  final Color? color;
  final num minimum, maximum;
  final double maxPixels;
  final double ruler;
  final double start;
  final double radius;
  final Axis axis;
  final double cord;
  final ValueChanged<double> positionChanged;
  final VoidCallback minimumViolated, maximumViolated;
  final bool enable;
  final num? safeZone;

  const _Thumb(
      {this.color,
      required this.maximum,
      required this.minimum,
      required this.maxPixels,
      required this.ruler,
      required this.start,
      required this.radius,
      required this.axis,
      required this.cord,
      required this.enable,
      required this.maximumViolated,
      required this.minimumViolated,
      required this.positionChanged,
      this.safeZone});

  @override
  State<_Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<_Thumb> {
  void listen(Offset details, bool vertical) {
    {
      if (!widget.enable) {
        return;
      }
      double k = vertical ? details.dy : details.dx;
      // double safeRatio = (widget.radius / 2) / widget.maxPixels;
      double ratio = (k - (widget.cord)) / (widget.maxPixels);
      if (ratio * widget.ruler + widget.start <
          widget.minimum + (widget.safeZone ?? 0)) {
        widget.minimumViolated.call();
        return;
      }
      if (ratio * widget.ruler + widget.start >
          widget.maximum - (widget.safeZone ?? 0)) {
        widget.maximumViolated.call();
        return;
      }
      double value = (ratio * widget.ruler) + widget.start;
      widget.positionChanged.call(value);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: widget.axis == Axis.horizontal
          ? (details) {
              listen(details.globalPosition, false);
            }
          : null,
      onVerticalDragUpdate: widget.axis == Axis.vertical
          ? (details) {
              // print(details.globalPosition.dy);
              listen(details.globalPosition, true);
            }
          : null,
      onHorizontalDragDown: (details) {
        // listen(details.globalPosition, true);
      },
      child: Container(
        height: widget.radius,
        width: widget.radius,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color ?? Theme.of(context).primaryColor),
        alignment: Alignment.center,
        child: Container(
          // padding: const EdgeInsets.all(5),
          height: widget.radius - 8,
          width: widget.radius - 8,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor),
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final Color? color;
  final double width, height;
  final int start, end;
  final num from, to;
  final Axis axis;

  const _Rail({
    this.color,
    required this.width,
    required this.height,
    required this.start,
    required this.end,
    required this.axis,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: max(height, 0),
      width: max(width, 0),
      decoration: BoxDecoration(
          color: color ?? Theme.of(context).primaryColor,
          borderRadius: axis == Axis.horizontal
              ? BorderRadius.only(
                  topLeft: start == 0
                      ? const Radius.circular(50)
                      : const Radius.circular(0),
                  bottomLeft: start == 0
                      ? const Radius.circular(50)
                      : const Radius.circular(0),
                  topRight: start == end - 1
                      ? const Radius.circular(50)
                      : const Radius.circular(0),
                  bottomRight: start == end - 1
                      ? const Radius.circular(50)
                      : const Radius.circular(0),
                )
              : BorderRadius.only(
                  topLeft: start == 0
                      ? const Radius.circular(50)
                      : const Radius.circular(0),
                  bottomLeft: start == end - 1
                      ? const Radius.circular(50)
                      : const Radius.circular(0),
                  topRight: start == 0
                      ? const Radius.circular(50)
                      : const Radius.circular(0),
                  bottomRight: start == end - 1
                      ? const Radius.circular(50)
                      : const Radius.circular(0),
                )),
    );
  }
}

class RailBuilder extends StatefulWidget {
  final Axis axis;
  final Widget child;

  // final ValueChanged onBuild;

  const RailBuilder(
      {super.key,
      required this.child,
      // required this.onBuild,
      required this.axis});

  @override
  State<RailBuilder> createState() => _RailBuilderState();
}

class _RailBuilderState extends State<RailBuilder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _ColOrRow extends StatelessWidget {
  final List<Widget> children;
  final Axis axis;

  const _ColOrRow({required this.axis, required this.children});

  @override
  Widget build(BuildContext context) {
    return axis == Axis.horizontal
        ? Column(
            children: children,
          )
        : Row(
            children: children,
          );
  }
}

class RangeIndicatorController extends ChangeNotifier {
  bool _r = false;

  bool get isRefresh {
    bool t = _r;
    _r = false;
    return t;
  }

  void update() {
    _r = true;
    notifyListeners();
  }
}
