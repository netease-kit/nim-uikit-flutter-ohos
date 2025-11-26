// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class CustomMessageType {
  ///合并转发消息
  static const int customMergeMessageType = 101;

  ///多行文本消息
  static const int customMultiLineMessageType = 102;
}

class CustomMessageKey {
  ///自定义消息的type key
  static const String type = 'type';

  ///自定义消息的data key
  static const String data = 'data';
}
