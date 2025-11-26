// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'frame_separate_task.dart';

import 'notification.dart';

/// @desc    <int,Size> > Cache child node information
class SizeCacheWidget extends StatefulWidget {
  const SizeCacheWidget({Key? key, required this.child, this.estimateCount = 0})
      : super(key: key);
  final Widget child;

  /// Estimate the number of children on the screen, which is used to set the size of the frame queue
  /// Optimizes the list of items on the current screen for delayed response in fast scrolling scenarios
  /// If the estimateCount is 0, the default value is 10
  /// for task size
  final int estimateCount;

  static SizeCacheWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<SizeCacheWidgetState>();
  }

  @override
  SizeCacheWidgetState createState() => SizeCacheWidgetState();
}

class SizeCacheWidgetState extends State<SizeCacheWidget> {
  /// Stores the Size of the child node's report
  Map<String, Size> itemsSizeCache = <String, Size>{};

  @override
  void initState() {
    super.initState();
    setSeparateFramingTaskQueue();
  }

  @override
  void didUpdateWidget(SizeCacheWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setSeparateFramingTaskQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext ctx) {
        return NotificationListener<LayoutInfoNotification>(
          onNotification: (LayoutInfoNotification notification) {
            saveLayoutInfo(notification.index, notification.size);
            return true;
          },
          child: widget.child,
        );
      },
    );
  }

  void saveLayoutInfo(String? id, Size size) {
    if (id != null) {
      itemsSizeCache[id] = size;
    }
  }

  void setSeparateFramingTaskQueue() {
    if (widget.estimateCount != 0) {
      FrameSeparateTaskQueue.instance!.maxTaskSize = widget.estimateCount;
    } else {
      FrameSeparateTaskQueue.instance!.maxTaskSize = defaultMaxTaskSize;
    }
  }

  @override
  void dispose() {
    FrameSeparateTaskQueue.instance!.resetMaxTaskSize();
    super.dispose();
  }
}
