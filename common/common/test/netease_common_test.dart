// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/netease_common.dart';

void main() {
  group('DualValueNotifier', () {
    test('value', () {
      final notifier = DualValueNotifier<int>(0);
      expect(notifier.value, equals(0));
      notifier.value = 1;
      expect(notifier.value, equals(1));
    });
  });
}
