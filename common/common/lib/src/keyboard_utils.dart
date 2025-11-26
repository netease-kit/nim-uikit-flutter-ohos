// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void hideKeyboard() {
  SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
}

/// show keyboard without request TextInput focus
void showKeyboard() {
  SystemChannels.textInput.invokeMethod<void>('TextInput.show');
}

extension KeyboardX on State {
  /// hide keyboard and clear current TextInput focus
  void dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}
