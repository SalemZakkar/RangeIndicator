import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetCordChange = void Function(Offset offset);

class MeasureCordsRenderObject extends RenderProxyBox {
  Offset? oldPosition;
  OnWidgetCordChange onChange;
  MeasureCordsRenderObject(this.onChange);

  @override
  void performLayout() async {
    super.performLayout();
    Offset newPos = const Offset(0, 0);
    Completer completer = Completer();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      final k = child?.getTransformTo(null).getTranslation();
      newPos = Offset(k!.x.abs(), k.y.abs());
      completer.complete(null);
    });
    await completer.future;
    if (oldPosition == newPos) return;

    oldPosition = newPos;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newPos);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetCordChange onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureCordsRenderObject(onChange);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant MeasureCordsRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}
