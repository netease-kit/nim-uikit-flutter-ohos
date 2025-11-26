// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

extension TextEditingControllerEx on TextEditingController {
  /// Check that the [selection] is inside of the bounds of [text].
  bool isSelectionWithinTextBounds(TextSelection selection) {
    return selection.start <= text.length && selection.end <= text.length;
  }

  /// Check that the [selection] is inside of the composing range.
  bool isSelectionWithinComposingRange(TextSelection selection) {
    return selection.start >= value.composing.start &&
        selection.end <= value.composing.end;
  }
}
