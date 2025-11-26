// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/src/time_utils.dart';

void main() {
  group('MillisTimeFormatter', () {
    test('formatToTimeString should format milliseconds to time string', () {
      final milliseconds = 1643587200000; // 2022-01-31 00:00:00
      final formattedTime =
          milliseconds.formatToTimeString('yyyy-MM-dd HH:mm:ss');
      expect(formattedTime, equals('2022-01-31 08:00:00'));
    });
  });

  group('DateTimeFormatter', () {
    test('formatToTimeString should format DateTime to time string', () {
      final dateTime = DateTime(2022, 1, 31, 0, 0, 0);
      final formattedTime = dateTime.formatToTimeString('yyyy-MM-dd HH:mm:ss');
      expect(formattedTime, equals('2022-01-31 00:00:00'));
    });
  });
}
