// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class TextUtils {
  static final regexLetterOrDigital = RegExp(r'^[0-9a-zA-Z]*$');
  static final regexLetter = RegExp(r'^[a-zA-Z]*$');
  static final regexDigital = RegExp(r'^[0-9]*$');

  static bool isEmpty(String? text) => text == null || text.isEmpty;

  static bool isNotEmpty(String? text) => text != null && text.isNotEmpty;

  static bool nonEmptyEquals(String? text1, String? text2) =>
      isNotEmpty(text1) && isNotEmpty(text2) && text1 == text2;

  static bool isLetter(String? text) =>
      isNotEmpty(text) && regexLetter.hasMatch(text!);

  static bool isDigital(String? text) =>
      isNotEmpty(text) && regexDigital.hasMatch(text!);

  static bool isLetterOrDigital(String? text) =>
      isNotEmpty(text) && regexLetterOrDigital.hasMatch(text!);
}

extension StringX on String {
  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    }
    return this;
  }

  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return substring(prefix.length);
    }
    return this;
  }

  String removeSurrounding(String prefix, String suffix) {
    if (length >= prefix.length + suffix.length &&
        startsWith(prefix) &&
        endsWith(suffix)) {
      return substring(prefix.length, length - suffix.length);
    }
    return this;
  }

  String format(List<dynamic> args) {
    return splitMapJoin(
      RegExp(r'\{\}'),
      onMatch: (m) {
        return args.removeAt(0).toString();
      },
    );
  }
}

extension StringX2 on String? {
  bool get isEmpty {
    return this == null || this!.length == 0;
  }

  /// Whether this string is not empty.
  bool get isNotEmpty {
    return this != null && this!.length > 0;
  }

  bool get isBlank {
    return this == null || this!.trim().length == 0;
  }

  bool get isNotBlank => !isBlank;

  String orElse(String other) {
    return this ?? other;
  }

  String ifEmpty(String other) {
    return isNotEmpty ? this! : other;
  }

  String ifBlank(String other) {
    return isNotBlank ? this! : other;
  }
}
