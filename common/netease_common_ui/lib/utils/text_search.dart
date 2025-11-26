// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

class TextSearcher {
  /// 构建搜索字体组成的文本
  /// [content] 文本内容
  /// [keyword] 搜索关键字
  /// [normalStyle] 正常文本样式
  /// [highStyle] 搜索关键字文本样式
  static Widget hitWidget(String content, String keyword, TextStyle normalStyle,
      TextStyle highStyle) {
    var hitInfo = TextSearcher.search(content, keyword);
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: hitInfo == null
          ? TextSpan(text: content, style: normalStyle)
          : TextSpan(children: [
              if (hitInfo.start > 0)
                TextSpan(
                  text: content.substring(0, hitInfo.start),
                  style: normalStyle,
                ),
              TextSpan(
                  text: content.substring(hitInfo.start, hitInfo.end),
                  style: highStyle),
              if (hitInfo.end <= content.length - 1)
                TextSpan(
                    text: content.substring(hitInfo.end), style: normalStyle)
            ]),
    );
  }

  static RecordHitInfo? search(String target, String query) {
    var index = kmpSearch(target, query);
    if (index >= 0) {
      return RecordHitInfo(index, index + query.length);
    }
    return null;
  }

  static int kmpSearch(String text, String pattern) {
    var m = pattern.length;
    var n = text.length;
    if (pattern.isEmpty) {
      return -1;
    }
    // j: the current index of pattern
    var j = 0;
    for (var it = 0; it < n; it++) {
      var i = it;
      while (j > 0 && text[i] != pattern[j]) {
        j = pi(j - 1, pattern = pattern);
      }
      if (text[i] == pattern[j]) {
        j++;
      }
      if (j == m) {
        return i - m + 1;
      }
    }
    return -1;
  }

  static int pi(int j, String pattern) {
    if (j == 0) return 0;
    for (var k = 1; k < pattern.length; k++) {
      while (
          pattern[j] != pattern[pi(j - 1, pattern)] && pi(j - 1, pattern) > 0) {
        return pi(pi(j - 1, pattern) - 1, pattern);
      }

      if (pattern[j] == pattern[pi(j - 1, pattern)]) {
        return pi(j - 1, pattern) + 1;
      }
    }

    return 0;
  }
}

class RecordHitInfo {
  int start;
  int end;

  RecordHitInfo(this.start, this.end);
}
