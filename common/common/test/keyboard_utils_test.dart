// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_common/netease_common.dart';

void main() {
  group('KeyboardUtils', () {
    test('hideKeyboard should invoke TextInput.hide method', () {
      SystemChannels.textInput
          // ignore: deprecated_member_use
          .setMockMethodCallHandler((MethodCall methodCall) async {
        expect(methodCall.method, 'TextInput.hide');
        return null;
      });

      hideKeyboard();
    });

    test('showKeyboard should invoke TextInput.show method', () {
      SystemChannels.textInput
          // ignore: deprecated_member_use
          .setMockMethodCallHandler((MethodCall methodCall) async {
        expect(methodCall.method, 'TextInput.show');
        return null;
      });

      showKeyboard();
    });

    testWidgets('dismissKeyboard should clear current TextInput focus',
        (WidgetTester tester) async {
      final focusNode = FocusNode();
      final textField = TextField(focusNode: focusNode);
      await tester.pumpWidget(textField);
      focusNode.requestFocus();
      expect(focusNode.hasFocus, isTrue);
      // dismissKeyboard();
      expect(focusNode.hasFocus, isFalse);
    });
  });
}
