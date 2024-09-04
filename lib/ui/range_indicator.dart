import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
  final num? segment;
  final RangeType rangeType;
  final num unBoundedPush;

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
      this.unBoundedPush = 0});

  @override
  State<RangeIndicator> createState() => _RangeIndicatorState();
}

class _RangeIndicatorState extends State<RangeIndicator> {
  List<RangeInfo> ranges = [];
  bool initiated = false;
  GlobalKey keyV = GlobalKey(), keyH = GlobalKey();
  bool viewHeader = false;

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
      // setState(() {
      //   viewHeader = false;
      // });
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
    viewHeader = true;
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

  double calcThumbSafePush(int i) {
    if (i == ranges.length - 1) {
      return 0;
    }
    if (getPush(i + 1) - getPush(i) <( widget.thumbRadius / 4)) {
      return widget.thumbRadius / 2 + calcThumbSafePush(i + 1);
    }
    return 0;
  }

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
    List<Range> r = [
      Range(
          start: widget.numberBuilder.call(start),
          end: widget.numberBuilder.call(ranges.first.end))
    ];
    for (int i = 1; i < ranges.length; i++) {
      r.addAll([
        Range(
            start: widget.numberBuilder.call(ranges[i - 1].end + k),
            end: widget.numberBuilder.call(ranges[i].end))
      ]);
    }
    widget.onChanged.call(r);
  }

  Widget _getNumberHeadersH() {
    return SizedBox(
      height: widget.axis == Axis.horizontal ? 14 : null,
      width: widget.axis == Axis.vertical ? 14 : null,
      // width: 14,
      child: Stack(
        children: [
          Positioned(
            left: widget.axis == Axis.horizontal ? 0 : null,
            top: widget.axis == Axis.vertical ? 0 : null,
            child: Text(
              widget.rangeType == RangeType.unBounded ||
                      widget.rangeType == RangeType.unBoundedMin
                  ? "∞"
                  : widget.numberBuilder.call(start).toStringAsFixed(0),
              style: TextStyle(color: ranges.first.color, fontSize: 11),
            ),
          ),
          Positioned(
            right: widget.axis == Axis.horizontal ? 0 : null,
            bottom: widget.axis == Axis.vertical ? 0 : null,
            child: Text(
              widget.rangeType == RangeType.unBounded ||
                      widget.rangeType == RangeType.unBoundedMax
                  ? "∞"
                  : widget.numberBuilder
                      .call(ranges.last.end)
                      .toStringAsFixed(0),
              style: TextStyle(color: ranges.last.color, fontSize: 11),
            ),
          ),
          for (int i = 0; i < ranges.length - 1; i++)
            Positioned(
              left: widget.axis == Axis.horizontal
                  ? getPush(i) + getPixelsForEach(i)
                  : null,
              top: widget.axis == Axis.vertical
                  ? getPush(i) + getPixelsForEach(i)
                  : null,
              // top: 4,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: widget.numberBuilder
                        .call(ranges[i].end)
                        .toStringAsFixed(0),
                    // text: 10.toString(),
                    style: TextStyle(color: ranges[i].color, fontSize: 9),
                  ),
                  TextSpan(
                    text:
                        ' ${widget.numberBuilder.call(ranges[i].end + (widget.segment ?? 0)).toString()}',
                    style: TextStyle(color: ranges[i + 1].color, fontSize: 9),
                  )
                ]),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ColOrRow(
      axis: widget.axis,
      children: [
        viewHeader ? _getNumberHeadersH() : const SizedBox(),
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
                                    from:
                                        i == 0 ? widget.min : ranges[i - 1].end,
                                    to: ranges[i].end,
                                  ),
                              ],
                            ),
                            onBuild: (val) {
                              setState(() {
                                startXY = val;
                              });
                            })
                        : RailBuilder(
                            axis: widget.axis,
                            onBuild: (val) {
                              setState(() {
                                startXY = val;
                              });
                            },
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
                                    from:
                                        i == 0 ? widget.min : ranges[i - 1].end,
                                    to: ranges[i].end,
                                  ),
                              ],
                            ),
                          ),
                  ),
                  for (int i = 1; i < ranges.length; i++)
                    Positioned(
                      left: widget.axis == Axis.horizontal
                          ? getPush(i) - calcThumbSafePush(i)
                          : null,
                      top: widget.axis == Axis.vertical ? getPush(i) : 1,
                      child: _Thumb(
                          maximumViolated: () {
                            if (i != ranges.length - 1) {
                              return;
                            }
                            if (widget.rangeType == RangeType.unBounded ||
                                widget.rangeType == RangeType.unBoundedMax) {
                              RangeInfo r = ranges.last;
                              ranges[ranges.length - 1] = RangeInfo(
                                  end: r.end + widget.unBoundedPush,
                                  color: r.color);
                              initiated = false;
                              init(initial: ranges, initialMin: start);
                              setState(() {});
                            }
                          },
                          minimumViolated: () {
                            if (i != 1) {
                              return;
                            }
                            if (widget.rangeType == RangeType.unBounded ||
                                widget.rangeType == RangeType.unBoundedMin) {
                              initiated = false;
                              start -= widget.unBoundedPush;
                              init(initial: ranges, initialMin: start);
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
      required this.positionChanged});

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
      double safeRatio = (widget.radius / 2) / widget.maxPixels;
      double ratio = (k - (widget.cord)) / (widget.maxPixels);
      if (ratio * widget.ruler + widget.start <
          widget.minimum + (safeRatio * (widget.ruler + widget.start.abs()))) {
        widget.minimumViolated.call();
        return;
      }
      if (ratio * widget.ruler + widget.start >
          widget.maximum - (safeRatio * (widget.ruler + widget.start.abs()))) {
        widget.maximumViolated.call();
        return;
      }
      double value = (ratio * widget.ruler) + widget.start;
      widget.positionChanged.call(value);
    }
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
  final ValueChanged onBuild;

  const RailBuilder(
      {super.key,
      required this.child,
      required this.onBuild,
      required this.axis});

  @override
  State<RailBuilder> createState() => _RailBuilderState();
}

class _RailBuilderState extends State<RailBuilder> {
  RenderBox? _initializedRenderBox;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializedRenderBox = context.findRenderObject() as RenderBox?;
      final t = -_initializedRenderBox!.getTransformTo(null).getTranslation();
      widget.onBuild
          .call(widget.axis == Axis.horizontal ? t.x.abs() : t.y.abs());
    });
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
