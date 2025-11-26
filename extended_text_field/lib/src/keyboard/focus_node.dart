// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// The FocusNode to be used in [TextInputBindingMixin]
///
class TextInputFocusNode extends FocusNode {
  /// no system keyboard show
  /// if it's true, it stop Flutter Framework send `TextInput.show` message to Flutter Engine
  bool ignoreSystemKeyboardShow = true;
}
