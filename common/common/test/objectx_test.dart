// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/netease_common.dart';

void main() {
  group('ObjectX', () {
    test('guard returns correct value when not null', () {
      final value = 'hello';
      final result = value.guard<int>((v) => v.length);
      expect(result, equals(5));
    });

    test('guard returns null when null', () {
      final value = null;
      final result = value.guard<int>((v) => v.length);
      expect(result, isNull);
    });

    test('safeCast returns correct value when castable', () {
      final value = 'hello';
      final result = value.safeCast<Object>();
      expect(result, equals(value));
    });

    test('safeCast returns null when not castable', () {
      final value = 'hello';
      final result = value.safeCast<int>();
      expect(result, isNull);
    });
  });

  group('IterableX', () {
    test('copy returns a new list with the same elements', () {
      final list = [1, 2, 3];
      final copy = list.copy();
      expect(copy, equals(list));
      expect(copy, isNot(same(list)));
    });

    test('firstOrNull returns first element when not empty', () {
      final list = [1, 2, 3];
      final result = list.firstOrNull;
      expect(result, equals(1));
    });

    test('firstOrNull returns null when empty', () {
      final list = [];
      final result = list.firstOrNull;
      expect(result, isNull);
    });

    test('lastOrNull returns last element when not empty', () {
      final list = [1, 2, 3];
      final result = list.lastOrNull;
      expect(result, equals(3));
    });

    test('lastOrNull returns null when empty', () {
      final list = [];
      final result = list.lastOrNull;
      expect(result, isNull);
    });

    test('mapIndexed returns correct values', () {
      final list = ['a', 'b', 'c'];
      final result = list.mapIndexed((index, value) => '$index$value');
      expect(result, equals(['0a', '1b', '2c']));
    });
  });

  group('ListX', () {
    test('getOrNull returns element at index when in range', () {
      final list = [1, 2, 3];
      final result = list.getOrNull(1);
      expect(result, equals(2));
    });

    test('getOrNull returns null when index out of range', () {
      final list = [1, 2, 3];
      final result = list.getOrNull(3);
      expect(result, isNull);
    });
  });

  group('MapX', () {
    test('getOrDefault returns value when key exists and is correct type', () {
      final map = {'a': 1, 'b': 2};
      final result = map.getOrDefault<int>('a', 0);
      expect(result, equals(1));
    });

    test('getOrDefault returns default value when key does not exist', () {
      final map = {'a': 1, 'b': 2};
      final result = map.getOrDefault<int>('c', 0);
      expect(result, equals(0));
    });

    test('getOrDefault returns default value when value is not correct type',
        () {
      final map = {'a': 1, 'b': '2'};
      final result = map.getOrDefault<int>('b', 0);
      expect(result, equals(0));
    });

    test('getOrCompute returns value when key exists and is correct type', () {
      final map = {'a': 1, 'b': 2};
      final result = map.getOrCompute<int>('a', () => 0);
      expect(result, equals(1));
    });

    test('getOrCompute returns computed value when key does not exist', () {
      final map = {'a': 1, 'b': 2};
      final result = map.getOrCompute<int>('c', () => 0);
      expect(result, equals(0));
    });

    test('getOrCompute returns computed value when value is not correct type',
        () {
      final map = {'a': 1, 'b': '2'};
      final result = map.getOrCompute<int>('b', () => 0);
      expect(result, equals(0));
    });

    test('withValue calls onValue when key exists and is correct type', () {
      final map = {'a': 1, 'b': 2};
      var called = false;
      map.withValue<int>('a', (value) {
        expect(value, equals(1));
        called = true;
      });
      expect(called, isTrue);
    });

    test('withValue does not call onValue when key does not exist', () {
      final map = {'a': 1, 'b': 2};
      var called = false;
      map.withValue<int>('c', (value) {
        called = true;
      });
      expect(called, isFalse);
    });

    test('withValue does not call onValue when value is not correct type', () {
      final map = {'a': 1, 'b': '2'};
      var called = false;
      map.withValue<int>('b', (value) {
        called = true;
      });
      expect(called, isFalse);
    });

    test('withValueOrDefault calls onValue when key exists and is correct type',
        () {
      final map = {'a': 1, 'b': 2};
      var called = false;
      map.withValueOrDefault<int>('a', (value) {
        expect(value, equals(1));
        called = true;
      }, 0);
      expect(called, isTrue);
    });

    test(
        'withValueOrDefault calls onValue with default value when key does not exist',
        () {
      final map = {'a': 1, 'b': 2};
      var called = false;
      map.withValueOrDefault<int>('c', (value) {
        expect(value, equals(0));
        called = true;
      }, 0);
      expect(called, isTrue);
    });

    test(
        'withValueOrDefault calls onValue with default value when value is not correct type',
        () {
      final map = {'a': 1, 'b': '2'};
      var called = false;
      map.withValueOrDefault<int>('b', (value) {
        expect(value, equals(0));
        called = true;
      }, 0);
      expect(called, isTrue);
    });
  });
}
