// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_chatkit/services/message/chat_message.dart';

class MessageDynamicResult {
  List<ChatMessage> messageList;

  bool? isReliable;

  MessageDynamicResult({required this.messageList, this.isReliable});
}
