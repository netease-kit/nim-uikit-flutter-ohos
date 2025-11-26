// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/netease_common.dart';

void main() {
  group('StringHash', () {
    test('md5', () {
      expect('hello'.md5, equals('5d41402abc4b2a76b9719d911017c592'));
      expect('world'.md5, equals('7d793037a0760186574b0282f2f435e7'));
      expect(''.md5, equals('d41d8cd98f00b204e9800998ecf8427e'));
    });

    test('sha1', () {
      expect('hello'.sha1, equals('aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d'));
      expect('world'.sha1, equals('7c211433f02071597741e6ff5a8ea34789abbf43'));
      expect(''.sha1, equals('da39a3ee5e6b4b0d3255bfef95601890afd80709'));
    });
  });
}
