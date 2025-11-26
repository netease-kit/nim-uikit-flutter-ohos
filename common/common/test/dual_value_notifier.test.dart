// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/netease_common.dart';

void main() {
  group('DualValueNotifier', () {
    test('should notify listeners when value changes', () {
      final notifier = DualValueNotifier<int>(0);
      var notified = false;
      notifier.addListener(() {
        notified = true;
      });
      notifier.value = 1;
      expect(notified, isTrue);
    });

    test('should not notify listeners when value does not change', () {
      final notifier = DualValueNotifier<int>(0);
      var notified = false;
      notifier.addListener(() {
        notified = true;
      });
      notifier.value = 0;
      expect(notified, isFalse);
    });

    test('should have correct before and current values', () {
      final notifier = DualValueNotifier<int>(0);
      notifier.value = 1;
      expect(notifier.before, equals(0));
      expect(notifier.current, equals(1));
    });

    test('should skip first change notification', () {
      final notifier = DualValueNotifier<int>(0);
      final decider = SkipFirstChange();
      notifier.setNotifyDecider(decider);
      var notified = false;
      notifier.addListener(() {
        notified = true;
      });
      notifier.value = 1;
      expect(notified, isFalse);
      // decider._firstNotify = false;
      notifier.value = 2;
      expect(notified, isTrue);
    });

    test('should not set multiple notify deciders', () {
      final notifier = DualValueNotifier<int>(0);
      final decider1 = SkipFirstChange();
      final decider2 = SkipFirstChange();
      expect(() => notifier.setNotifyDecider(decider1), returnsNormally);
      expect(() => notifier.setNotifyDecider(decider2), throwsAssertionError);
    });
  });
}
