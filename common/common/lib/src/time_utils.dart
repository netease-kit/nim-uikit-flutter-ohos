// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:intl/intl.dart';

extension MillisTimeFormatter on int {
  String formatToTimeString(String dateFormat) {
    return DateFormat(dateFormat)
        .format(DateTime.fromMillisecondsSinceEpoch(this));
  }
}

extension DateTimeFormatter on DateTime {
  String formatToTimeString(String dateFormat) {
    return DateFormat(dateFormat).format(this);
  }
}

StreamController<Object> createOneMinuteTickStreamController() {
  final controller = StreamController<Object>.broadcast();
  controller.onListen = () async {
    final nowTime = DateTime.now();
    final nextTime = DateTime(
      nowTime.year,
      nowTime.month,
      nowTime.day,
      nowTime.hour,
      nowTime.minute,
    ).add(const Duration(minutes: 1));
    controller.add(const Object());
    await Future.delayed(nextTime.difference(nowTime));
    while (true) {
      if (controller.isClosed) return;
      controller.add(const Object());
      await Future.delayed(const Duration(minutes: 1));
    }
  };
  return controller;
}
