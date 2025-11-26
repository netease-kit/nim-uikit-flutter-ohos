// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

extension StreamWithInitialValueExtension<T extends Object?> on Stream<T> {
  Stream<T> addInitial(T initial) {
    final controller = StreamController<T>();
    controller.onCancel = () {
      controller.close();
    };
    controller.onListen = () {
      controller.add(initial);
      controller.addStream(this);
    };
    return controller.stream;
  }
}
