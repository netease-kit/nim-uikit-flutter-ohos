// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/netease_common.dart';

void main() {
  group('NEResult', () {
    test('success', () {
      final result = NEResult.success();
      expect(result.code, equals(0));
      expect(result.msg, isNull);
      expect(result.data, isNull);
      expect(result.isSuccess(), isTrue);
    });

    test('successWith', () {
      final result = NEResult.successWith('data');
      expect(result.code, equals(0));
      expect(result.msg, isNull);
      expect(result.data, equals('data'));
      expect(result.isSuccess(), isTrue);
    });

    test('failure', () {
      final result = NEResult<String>(code: 1, msg: 'error');
      expect(result.code, equals(1));
      expect(result.msg, equals('error'));
      expect(result.data, isNull);
      expect(result.isSuccess(), isFalse);
    });

    test('toString', () {
      final successResult = NEResult.successWith('data');
      expect(successResult.toString(), equals('Success(data)'));

      final failureResult = NEResult<String>(code: 1, msg: 'error');
      expect(failureResult.toString(), equals('Failure(1, error)'));
    });

    test('nonNullData', () {
      final result = NEResult.successWith('data');
      expect(result.nonNullData, equals('data'));
    });
  });

  group('CommonResultExtension', () {
    test('onFailure', () {
      final failureResult = NEResult<String>(code: 1, msg: 'error');
      var called = false;
      failureResult.onFailure((code, msg) {
        expect(code, equals(1));
        expect(msg, equals('error'));
        called = true;
      });
      expect(called, isTrue);

      final successResult = NEResult.successWith('data');
      successResult.onFailure((code, msg) {
        fail('should not be called');
      });
    });
  });

  group('ObjectResultExtension', () {
    test('map', () {
      final result = NEResult.successWith('data');
      final mappedResult = result.map<int>((data) => data.length);
      expect(mappedResult.code, equals(0));
      expect(mappedResult.msg, isNull);
      expect(mappedResult.data, equals(4));
      expect(mappedResult.isSuccess(), isTrue);
    });

    test('onSuccess', () {
      final result = NEResult.successWith('data');
      var called = false;
      result.onSuccess((data) {
        expect(data, equals('data'));
        called = true;
      });
      expect(called, isTrue);

      final failureResult = NEResult<String>(code: 1, msg: 'error');
      failureResult.onSuccess((data) {
        fail('should not be called');
      });
    });
  });

  group('VoidResultExtension', () {
    test('map', () {
      final result = NEResult<void>(code: 0);
      final mappedResult = result.map<int>(() => 1);
      expect(mappedResult.code, equals(0));
      expect(mappedResult.msg, isNull);
      expect(mappedResult.data, equals(1));
      expect(mappedResult.isSuccess(), isTrue);
    });

    test('cast', () {
      final result = NEResult<void>(code: 0);
      final castResult = result.cast<int>();
      expect(castResult.code, equals(0));
      expect(castResult.msg, isNull);
      expect(castResult.data, isNull);
      expect(castResult.isSuccess(), isTrue);
    });

    test('onSuccess', () {
      final result = NEResult<void>(code: 0);
      var called = false;
      result.onSuccess(() {
        called = true;
      });
      expect(called, isTrue);

      final failureResult = NEResult<String>(code: 1, msg: 'error');
      failureResult.onSuccess(() {
        fail('should not be called');
      } as void Function(String p1));
    });
  });

  group('CommonFutureResultExtension', () {
    test('onFailure', () async {
      final failureResult =
          Future.value(NEResult<String>(code: 1, msg: 'error'));
      var called = false;
      final result = await failureResult.onFailure((code, msg) async {
        expect(code, equals(1));
        expect(msg, equals('error'));
        called = true;
      });
      expect(called, isTrue);
      expect(result.code, equals(1));
      expect(result.msg, equals('error'));
      expect(result.data, isNull);
      expect(result.isSuccess(), isFalse);

      final successResult = Future.value(NEResult.successWith('data'));
      final result2 = await successResult.onFailure((code, msg) async {
        fail('should not be called');
      });
      expect(result2.code, equals(0));
      expect(result2.msg, isNull);
      expect(result2.data, equals('data'));
      expect(result2.isSuccess(), isTrue);
    });
  });

  group('ObjectFutureResultExtension', () {
    test('onSuccess', () async {
      final result = Future.value(NEResult.successWith('data'));
      var called = false;
      final result2 = await result.onSuccess((data) async {
        expect(data, equals('data'));
        called = true;
      });
      expect(called, isTrue);
      expect(result2.code, equals(0));
      expect(result2.msg, isNull);
      expect(result2.data, equals('data'));
      expect(result2.isSuccess(), isTrue);

      final failureResult =
          Future.value(NEResult<String>(code: 1, msg: 'error'));
      final result3 = await failureResult.onSuccess((data) async {
        fail('should not be called');
      });
      expect(result3.code, equals(1));
      expect(result3.msg, equals('error'));
      expect(result3.data, isNull);
      expect(result3.isSuccess(), isFalse);
    });

    test('map', () async {
      final result = Future.value(NEResult.successWith('data'));
      final mappedResult = await result.map<int>((data) async => data.length);
      expect(mappedResult.code, equals(0));
      expect(mappedResult.msg, isNull);
      expect(mappedResult.data, equals(4));
      expect(mappedResult.isSuccess(), isTrue);

      final failureResult =
          Future.value(NEResult<String>(code: 1, msg: 'error'));
      final mappedResult2 =
          await failureResult.map<int>((data) async => data.length);
      expect(mappedResult2.code, equals(1));
      expect(mappedResult2.msg, equals('error'));
      expect(mappedResult2.data, isNull);
      expect(mappedResult2.isSuccess(), isFalse);
    });
  });

  group('VoidFutureResultExtension', () {
    test('onSuccess', () async {
      final result = Future.value(NEResult<void>(code: 0));
      var called = false;
      final result2 = await result.onSuccess(() async {
        called = true;
      });
      expect(called, isTrue);
      expect(result2.code, equals(0));
      expect(result2.msg, isNull);
      // expect(result2.data, isNull);
      expect(result2.isSuccess(), isTrue);

      final failureResult =
          Future.value(NEResult<String>(code: 1, msg: 'error'));
      final result3 = await failureResult.onSuccess(() async {
        fail('should not be called');
      } as FutureOr<void> Function(String));
      expect(result3.code, equals(1));
      expect(result3.msg, equals('error'));
      expect(result3.data, isNull);
      expect(result3.isSuccess(), isFalse);
    });

    test('map', () async {
      final result = Future.value(NEResult<void>(code: 0));
      final mappedResult = await result.map<int>(() async => 1);
      expect(mappedResult.code, equals(0));
      expect(mappedResult.msg, isNull);
      expect(mappedResult.data, equals(1));
      expect(mappedResult.isSuccess(), isTrue);

      final failureResult =
          Future.value(NEResult<String>(code: 1, msg: 'error'));
      final mappedResult2 = await failureResult.map<int>((_) async => 1);
      expect(mappedResult2.code, equals(1));
      expect(mappedResult2.msg, equals('error'));
      expect(mappedResult2.data, isNull);
      expect(mappedResult2.isSuccess(), isFalse);
    });
  });
}
