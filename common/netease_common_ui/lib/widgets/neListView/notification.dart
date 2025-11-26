// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// size information
class LayoutInfoNotification extends Notification {
  LayoutInfoNotification(this.index, this.size);

  final Size size;
  final String? index;
}
