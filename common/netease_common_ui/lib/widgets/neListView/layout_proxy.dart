// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'notification.dart';

/// @desc    Pass up the Size information of the child node
class ItemSizeInfoNotifier extends SingleChildRenderObjectWidget {
  const ItemSizeInfoNotifier({
    Key? key,
    this.id,
    required Widget? child,
  }) : super(key: key, child: child);
  final String? id;

  @override
  InitialRenderSizeChangedWithCallback createRenderObject(
      BuildContext context) {
    return InitialRenderSizeChangedWithCallback(
        onLayoutChangedCallback: (size) {
      LayoutInfoNotification(id, size).dispatch(context);
    });
  }
}

class InitialRenderSizeChangedWithCallback extends RenderProxyBox {
  InitialRenderSizeChangedWithCallback({
    RenderBox? child,
    required this.onLayoutChangedCallback,
  }) : super(child);

  final Function(Size size) onLayoutChangedCallback;

  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (size != _oldSize) onLayoutChangedCallback(size);
    _oldSize = size;
  }
}
