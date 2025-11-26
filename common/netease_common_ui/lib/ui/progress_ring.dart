// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing(
      {Key? key,
      required this.progress,
      required this.max,
      this.ringWidth,
      this.color,
      this.size = 16.0,
      this.startImage,
      this.finishImage})
      : super(key: key);

  final int progress;
  final int max;
  final double? ringWidth;
  final Color? color;
  final double size;
  final Widget? startImage;
  final Widget? finishImage;

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (progress == 0 && startImage != null) {
      result = startImage!;
    } else if (progress == max && finishImage != null) {
      result = finishImage!;
    } else {
      result = RepaintBoundary(
        child: CustomPaint(
          painter: _CircleProgressPainter(
              progress: progress / max, width: ringWidth, color: color),
        ),
      );
    }
    return SizedBox(
      height: size,
      width: size,
      child: result,
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  _CircleProgressPainter({required this.progress, this.width, this.color});

  final double progress;
  final double? width;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = width ?? 1
      ..color = color ?? Colors.blue;

    // draw circle
    canvas.drawArc(rect, 0, pi * 2, false, paint);

    // draw progress
    paint.style = PaintingStyle.fill;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, true, paint);
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        width != oldDelegate.width ||
        color != oldDelegate.color;
  }
}
