// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/netease_common.dart';

void main() {
  group('EventBus', () {
    late EventBus eventBus;

    setUp(() {
      eventBus = EventBus();
    });

    test('subscribe and emit', () {
      var eventName = 'test';
      var eventArg = 'hello';
      var callbackCalled = false;
      var callback = (arg) {
        expect(arg, equals(eventArg));
        callbackCalled = true;
      };
      eventBus.subscribe(eventName, callback);
      eventBus.emit(eventName, eventArg);
      expect(callbackCalled, isTrue);
    });

    test('unsubscribe', () {
      var eventName = 'test';
      var callbackCalled = false;
      var callback = (arg) {
        callbackCalled = true;
      };
      eventBus.subscribe(eventName, callback);
      eventBus.unsubscribe(eventName, callback);
      eventBus.emit(eventName);
      expect(callbackCalled, isFalse);
    });

    test('unsubscribe all', () {
      var eventName = 'test';
      var callbackCalled = false;
      var callback = (arg) {
        callbackCalled = true;
      };
      eventBus.subscribe(eventName, callback);
      eventBus.unsubscribe(eventName);
      eventBus.emit(eventName);
      expect(callbackCalled, isFalse);
    });

    test('subscribe multiple callbacks', () {
      var eventName = 'test';
      var eventArg = 'hello';
      var callback1Called = false;
      var callback2Called = false;
      var callback1 = (arg) {
        expect(arg, equals(eventArg));
        callback1Called = true;
      };
      var callback2 = (arg) {
        expect(arg, equals(eventArg));
        callback2Called = true;
      };
      eventBus.subscribe(eventName, callback1);
      eventBus.subscribe(eventName, callback2);
      eventBus.emit(eventName, eventArg);
      expect(callback1Called, isTrue);
      expect(callback2Called, isTrue);
    });

    test('emit non-existing event', () {
      var eventName = 'test';
      eventBus.emit(eventName);
      expect(true, isTrue);
    });
  });
}
