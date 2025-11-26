// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

extension NimString on String {
  /// 截取字符串，但是不截断emoji表情
  /// emoji表情占两个字符，high+low
  String subStringWithoutEmoji(int start, [int? end]) {
    var relStart = start;
    var relEnd = end ?? length;
    if (start != 0) {
      int c = this[start].codeUnitAt(0);
      // 如果是低位代理，则开始位置直接放弃表情
      if (isLowSurrogate(c)) {
        relStart++;
      }
    }
    if (end != null && end < length) {
      int c = this[end].codeUnitAt(0);
      // 如果是低位代理，则结束位置向后移动一位，包含表情
      if (isLowSurrogate(c)) {
        relEnd++;
      }
    }
    return substring(relStart, relEnd);
  }

  /// 根据最大字符限制截取字符串
  /// 例：xx...xx
  /// emoji表情按一个字符算，不截取
  String subStringWithMaxLength(int maxLen,
      {int startLen = 2, int endLen = 2, String ellipsis = '...'}) {
    if (length <= maxLen) {
      return this;
    }
    int firstIndex = startLen;
    if (startLen <= 0) {
      firstIndex = 0;
    } else {
      int startChar = this[firstIndex].codeUnitAt(0);
      if (isLowSurrogate(startChar)) {
        firstIndex++;
      }
    }
    int lastIndex = length - endLen;
    if (endLen <= 0 || lastIndex < 0) {
      lastIndex = length - 1;
    } else {
      int endChar = this[lastIndex].codeUnitAt(0);
      if (isLowSurrogate(endChar)) {
        lastIndex--;
      }
    }
    if (lastIndex <= firstIndex) {
      return this;
    }
    return substring(0, firstIndex) + ellipsis + substring(lastIndex);
  }

  bool isHighSurrogate(int codeUnit) {
    return codeUnit >= 0xD800 && codeUnit <= 0xDBFF;
  }

  bool isLowSurrogate(int codeUnit) {
    return codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
  }
}
