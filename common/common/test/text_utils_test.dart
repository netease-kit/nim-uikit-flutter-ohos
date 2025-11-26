// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/netease_common.dart';

void main() {
  group('TextUtils', () {
    test('isEmpty returns true for null or empty string', () {
      expect(TextUtils.isEmpty(null), isTrue);
      expect(TextUtils.isEmpty(''), isTrue);
    });

    test('isEmpty returns false for non-empty string', () {
      expect(TextUtils.isEmpty('hello'), isFalse);
    });

    test('isNotEmpty returns true for non-empty string', () {
      expect(TextUtils.isNotEmpty('hello'), isTrue);
    });

    test('isNotEmpty returns false for null or empty string', () {
      expect(TextUtils.isNotEmpty(null), isFalse);
      expect(TextUtils.isNotEmpty(''), isFalse);
    });

    test('nonEmptyEquals returns true for equal non-empty strings', () {
      expect(TextUtils.nonEmptyEquals('hello', 'hello'), isTrue);
    });

    test('nonEmptyEquals returns false for non-equal non-empty strings', () {
      expect(TextUtils.nonEmptyEquals('hello', 'world'), isFalse);
    });

    test('nonEmptyEquals returns false for empty or null strings', () {
      expect(TextUtils.nonEmptyEquals(null, 'hello'), isFalse);
      expect(TextUtils.nonEmptyEquals('', 'hello'), isFalse);
      expect(TextUtils.nonEmptyEquals('hello', null), isFalse);
      expect(TextUtils.nonEmptyEquals('hello', ''), isFalse);
    });

    test('isLetter returns true for letter string', () {
      expect(TextUtils.isLetter('hello'), isTrue);
    });

    test('isLetter returns false for non-letter string', () {
      expect(TextUtils.isLetter('123'), isFalse);
    });

    test('isLetter returns false for empty or null string', () {
      expect(TextUtils.isLetter(null), isFalse);
      expect(TextUtils.isLetter(''), isFalse);
    });

    test('isDigital returns true for digital string', () {
      expect(TextUtils.isDigital('123'), isTrue);
    });

    test('isDigital returns false for non-digital string', () {
      expect(TextUtils.isDigital('hello'), isFalse);
    });

    test('isDigital returns false for empty or null string', () {
      expect(TextUtils.isDigital(null), isFalse);
      expect(TextUtils.isDigital(''), isFalse);
    });

    test('isLetterOrDigital returns true for letter or digital string', () {
      expect(TextUtils.isLetterOrDigital('hello123'), isTrue);
    });

    test(
        'isLetterOrDigital returns false for non-letter and non-digital string',
        () {
      expect(TextUtils.isLetterOrDigital('hello!'), isFalse);
    });

    test('isLetterOrDigital returns false for empty or null string', () {
      expect(TextUtils.isLetterOrDigital(null), isFalse);
      expect(TextUtils.isLetterOrDigital(''), isFalse);
    });
  });

  group('StringX', () {
    test('removeSuffix removes suffix from string', () {
      expect('hello world'.removeSuffix('world'), equals('hello '));
    });

    test('removeSuffix returns original string if suffix not found', () {
      expect('hello world'.removeSuffix('there'), equals('hello world'));
    });

    test('removePrefix removes prefix from string', () {
      expect('hello world'.removePrefix('hello'), equals(' world'));
    });

    test('removePrefix returns original string if prefix not found', () {
      expect('hello world'.removePrefix('there'), equals('hello world'));
    });

    test('removeSurrounding removes surrounding prefix and suffix from string',
        () {
      expect('hello world'.removeSurrounding('hello', 'world'), equals(' '));
    });

    test(
        'removeSurrounding returns original string if prefix and suffix not found',
        () {
      expect('hello world'.removeSurrounding('there', 'world'),
          equals('hello world'));
    });
  });

  group('StringX2', () {
    test('isEmpty returns true for null or empty string', () {
      expect(''.isEmpty, isTrue);
      expect(null.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty string', () {
      expect('hello'.isEmpty, isFalse);
    });

    test('isNotEmpty returns true for non-empty string', () {
      expect('hello'.isNotEmpty, isTrue);
    });

    test('isNotEmpty returns false for null or empty string', () {
      expect(''.isNotEmpty, isFalse);
      expect(null.isNotEmpty, isFalse);
    });

    test('isBlank returns true for null, empty or whitespace string', () {
      expect(''.isBlank, isTrue);
      expect(null.isBlank, isTrue);
      expect('   '.isBlank, isTrue);
    });

    test('isBlank returns false for non-empty or non-whitespace string', () {
      expect('hello'.isBlank, isFalse);
      expect(' hello '.isBlank, isFalse);
    });

    test('isNotBlank returns true for non-empty or non-whitespace string', () {
      expect('hello'.isNotBlank, isTrue);
      expect(' hello '.isNotBlank, isTrue);
    });

    test('isNotBlank returns false for null, empty or whitespace string', () {
      expect(''.isNotBlank, isFalse);
      expect(null.isNotBlank, isFalse);
      expect('   '.isNotBlank, isFalse);
    });
  });
}
