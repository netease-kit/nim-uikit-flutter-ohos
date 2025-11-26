// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

class CommonColors {
  static const color_333333 = Color(0xff333333);
  static const color_666666 = Color(0xff666666);
  static const color_999999 = Color(0xff999999);
  static const color_007aff = Color(0xff007aff);
  static const color_8f8f8f = Color(0xff8f8f8f);
  static const color_337eff = Color(0xff337eff);
  static const color_656a72 = Color(0xff656a72);
  static const color_c5c9d2 = Color(0xffc5c9d2);
  static const color_f5f8fc = Color(0xfff5f8fc);
  static const color_cccccc = Color(0xffcccccc);
  static const color_a8abb6 = Color(0xffa8abb6);
  static const color_a8adb6 = Color(0xffa8adb6);
  static const color_dbe0e8 = Color(0xffdbe0e8);
  static const color_b3b7bc = Color(0xffb3b7bc);
  static const color_dee0e2 = Color(0xffdee0e2);
  static const color_e9eff5 = Color(0xffE9EFF5);

  // avatar colors
  static const color_60cfa7 = Color(0xff60cfa7);
  static const color_53c3f3 = Color(0xff53c3f3);
  static const color_537ff4 = Color(0xff537ff4);
  static const color_854fe2 = Color(0xff854fe2);
  static const color_be65d9 = Color(0xffbe65d9);
  static const color_e9749d = Color(0xffe9749d);
  static const color_f9b751 = Color(0xfff9b751);
}

extension String2Color on String {
  Color toColor() {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
