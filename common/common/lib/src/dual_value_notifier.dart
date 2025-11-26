// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

abstract class NotifyDecider extends ChangeNotifier {
  bool updateShouldNotify();
}

class SkipFirstChange extends NotifyDecider {
  bool _firstNotify = true;

  @override
  bool updateShouldNotify() {
    if (_firstNotify) {
      _firstNotify = false;
      return false;
    }
    return true;
  }
}

class DualValueNotifier<T> extends ValueNotifier<T> {
  DualValueNotifier(T value)
      : _before = value,
        super(value);

  T _before;

  T get before => _before;

  T get current => value;

  NotifyDecider? _notifyDecider;

  void setNotifyDecider(NotifyDecider? decider) {
    assert(_notifyDecider == null || decider == null,
        'Cannot set multiple notify decider.');
    if (_notifyDecider != null) {
      _notifyDecider!.removeListener(_onDeciderChangeMind);
    }
    _notifyDecider = decider;
    if (decider != null) {
      decider.addListener(_onDeciderChangeMind);
    }
  }

  void _onDeciderChangeMind() {
    if (_before != value) {
      notifyListeners();
    }
  }

  @override
  set value(T newValue) {
    if (value != newValue) {
      _before = value;
    }
    super.value = newValue;
  }

  @override
  void notifyListeners() {
    if (_notifyDecider?.updateShouldNotify() ?? true) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _notifyDecider = null;
    super.dispose();
  }
}
