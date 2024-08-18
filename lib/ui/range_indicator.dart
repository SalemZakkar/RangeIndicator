import 'dart:math';

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

  const RangeIndicator(
      {super.key,
      required this.ranges,
      this.axis = Axis.horizontal,
      required this.min,
      required this.onChanged,
      this.initialValue,
      this.railWidth = 5,
      this.thumbRadius = 15});

  @override
  State<RangeIndicator> createState() => _RangeIndicatorState();
}

class _RangeIndicatorState extends State<RangeIndicator> {
  List<RangeInfo> ranges = [];

  bool initiated = false;
  GlobalKey keyV = GlobalKey(), keyH = GlobalKey();

  @override
  void didUpdateWidget(covariant RangeIndicator oldWidget) {
    if (oldWidget.ranges.length != widget.ranges.length) {
      initiated = false;
      init();
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  init() {
    if (initiated) {
      return;
    }
    initiated = true;
    start = widget.min.toDouble();
    ranges = checkIfRangesIsValid(widget.ranges, start);
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
    List<Range> r = [Range(start: start, end: ranges.first.end)];
    for (int i = 1; i < ranges.length; i++) {
      r.addAll([Range(start: ranges[i - 1].end, end: ranges[i].end)]);
    }
    widget.onChanged.call(r);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                              ),
                          ],
                        ),
                      ),
              ),
              for (int i = 1; i < ranges.length; i++)
                Positioned(
                  left: widget.axis == Axis.horizontal ? getPush(i) : null,
                  top: widget.axis == Axis.vertical ? getPush(i) : 1,
                  child: _Thumb(
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
      required this.positionChanged});

  @override
  State<_Thumb> createState() => _ThumbState();
}

class _ThumbState extends State<_Thumb> {
  void listen(Offset details, bool vertical) {
    {
      double k = vertical ? details.dy : details.dx;
      double safeRatio = (widget.radius) / widget.maxPixels;
      double ratio = (k - (widget.cord)) / (widget.maxPixels);

      if (ratio * widget.ruler + widget.start <
          widget.minimum + (safeRatio * (widget.ruler + widget.start))) {
        return;
      }
      if (ratio * widget.ruler + widget.start >
          widget.maximum - (safeRatio * (widget.ruler + widget.start))) {
        return;
      }
      double value = (ratio * widget.ruler) + widget.start;
      widget.positionChanged.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      onTapDown: (det) {
        // print(det.globalPosition.dy);
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
          height: widget.radius - 12,
          width: widget.radius - 12,
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
  final Axis axis;

  const _Rail({
    this.color,
    required this.width,
    required this.height,
    required this.start,
    required this.end,
    required this.axis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
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
