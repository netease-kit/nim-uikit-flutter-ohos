// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'frame_separate_task.dart';
import 'layout_proxy.dart';
import 'size_cache_widget.dart';

/// @desc   Framing component, which renders the child node in a separate frame
///         after the placeholder is rendered in the first frame
class FrameSeparateWidget extends StatefulWidget {
  const FrameSeparateWidget({
    Key? key,
    this.id,
    this.placeHolder,
    required this.builder,
  }) : super(key: key);

  factory FrameSeparateWidget.builder({
    Key? key,
    String? id,
    Widget? placeHolder,
    required WidgetBuilder builder,
  }) =>
      FrameSeparateWidget(
        id: id,
        key: key,
        placeHolder: placeHolder,
        builder: builder,
      );

  /// The placeholder widget sets components that are as close to the actual widget as possible
  final Widget? placeHolder;

  /// Identifies its own ID, used in a scenario where size information is stored
  final String? id;

  /// Signature for a function that creates a widget.
  /// The builder has a higher priority, prioritize using builder before child.
  final WidgetBuilder builder;

  @override
  FrameSeparateWidgetState createState() => FrameSeparateWidgetState();
}

class FrameSeparateWidgetState extends State<FrameSeparateWidget> {
  Widget? result;

  @override
  void initState() {
    super.initState();
    result = widget.placeHolder ??
        Container(
          height: 20,
        );
    final Map<String, Size>? size = SizeCacheWidget.of(context)?.itemsSizeCache;
    Size? itemSize;
    if (size != null && size.containsKey(widget.id)) {
      itemSize = size[widget.id];
    }
    if (itemSize != null) {
      result = SizedBox(
        width: itemSize.width,
        height: itemSize.height,
        child: result,
      );
    }
    transformWidget();
  }

  @override
  void didUpdateWidget(FrameSeparateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    transformWidget();
  }

  @override
  Widget build(BuildContext context) {
    return ItemSizeInfoNotifier(id: widget.id, child: result);
  }

  void transformWidget() {
    SchedulerBinding.instance.addPostFrameCallback((Duration t) {
      FrameSeparateTaskQueue.instance!.scheduleTask(() {
        if (mounted) {
          setState(() {
            result = widget.builder.call(context);
          });
        }
      }, Priority.animation, () => !mounted, id: widget.id);
    });
  }
}
