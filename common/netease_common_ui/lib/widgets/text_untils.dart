// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:netease_common_ui/utils/string_utils.dart';

/// 截取字符串，但是不截断emoji表情
/// [lessLen] 长度修正，如果不为0 则可绘制长度减去修正长度
Widget getSingleMiddleEllipsisText(String? data,
    {TextStyle? style, int? endLen, int? lessLen}) {
  return LayoutBuilder(builder: (context, constrain) {
    String info = data ?? "";
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: info, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    //超出宽度
    final exceedWidth =
        (textPainter.size.width - constrain.maxWidth + (lessLen ?? 0)).toInt();
    if (exceedWidth > 0) {
      //每个字符的宽度
      final preTextSize = textPainter.size.width / info.length;
      //超出的长度
      final exceedLength = exceedWidth ~/ preTextSize;
      //最终的长度
      final maxLen = info.length - exceedLength;
      if (endLen == null) {
        endLen = (info.length - exceedLength - 3) ~/ 2;
      }
      final index = maxLen - endLen! - 3;
      info =
          info.subStringWithMaxLength(maxLen, startLen: index, endLen: endLen!);
    }
    return Text(
      info,
      maxLines: 1,
      style: style,
    );
  });
}
