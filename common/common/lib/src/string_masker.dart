// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

///
/// 字符串掩码工具类
/// 用于对敏感信息进行掩码处理，例如手机号、AppKey等。
///
class StringMasker {
  static String? maskString(
    String? originalText, {
    int unmaskedPrefixLength = 4,
    int unmaskedSuffixLength = 4,
    String maskingCharacter = '*',
  }) {
    if (originalText == null || originalText.isEmpty) {
      return originalText;
    }

    // 如果字符串太短，不足以进行掩码处理，则返回原字符串
    if (originalText.length <= unmaskedPrefixLength + unmaskedSuffixLength) {
      return originalText;
    }

    // 计算需要替换的部分的长度
    final maskedSectionLength =
        originalText.length - unmaskedPrefixLength - unmaskedSuffixLength;

    // 构建掩码部分
    final maskedSection = maskingCharacter * maskedSectionLength;

    // 拼接结果
    return originalText.substring(0, unmaskedPrefixLength) +
        maskedSection +
        originalText.substring(originalText.length - unmaskedSuffixLength);
  }

  static String? maskSensitiveKeyInString(
    String? originalText,
    String? sensitiveKey,
  ) {
    if (originalText == null || originalText.isEmpty) {
      return originalText;
    }
    if (sensitiveKey?.isNotEmpty ?? false) {
      return originalText.replaceAll(
          sensitiveKey!, StringMasker.maskString(sensitiveKey) ?? '');
    }
    return originalText;
  }
}
