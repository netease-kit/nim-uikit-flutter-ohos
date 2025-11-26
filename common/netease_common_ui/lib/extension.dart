// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common_ui/l10n/S.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

extension IntExt on int {
  String formatTimeMMSS() {
    String mm = (this / 60).truncate().toString().padLeft(2, '0');
    String ss = (this % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String formatDateTime() {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    DateTime now = DateTime.now();
    String format = 'HH:mm';
    if (dateTime.year != now.year) {
      format = 'yy-MM-dd HH:mm';
    } else if (dateTime.day != now.day) {
      format = 'MM-dd HH:mm';
    }
    return DateFormat(format).format(dateTime);
  }
}
