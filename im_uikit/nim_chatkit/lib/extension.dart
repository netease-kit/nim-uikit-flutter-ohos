// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:nim_core_v2/nim_core.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

extension TypeValue on NIMMessageType {
  int getValue() {
    int type = -1;
    switch (this) {
      case NIMMessageType.text:
        type = 0;
        break;
      case NIMMessageType.image:
        type = 1;
        break;
      case NIMMessageType.audio:
        type = 2;
        break;
      case NIMMessageType.video:
        type = 3;
        break;
      case NIMMessageType.location:
        type = 4;
        break;
      case NIMMessageType.file:
        type = 6;
        break;
      case NIMMessageType.avChat:
        type = 7;
        break;
      case NIMMessageType.notification:
        type = 5;
        break;
      case NIMMessageType.tip:
        type = 10;
        break;
      case NIMMessageType.robot:
        type = 11;
        break;
      case NIMMessageType.call:
        type = 12;
        break;
      case NIMMessageType.custom:
        type = 100;
        break;
    }
    return type;
  }
}

extension ConversationTypeEx on NIMConversationType {
  static NIMConversationType getTypeFromValue(int? value) {
    switch (value) {
      case 1:
        return NIMConversationType.p2p;
      case 2:
        return NIMConversationType.team;
      case 3:
        return NIMConversationType.superTeam;
    }
    return NIMConversationType.unknown;
  }

  int getValue() {
    switch (this) {
      case NIMConversationType.p2p:
        return 1;
      case NIMConversationType.team:
        return 2;
      case NIMConversationType.superTeam:
        return 3;
    }
    return 0;
  }
}

extension NIMMessageEXT on NIMMessage {
  bool isFileDownload() {
    if (attachment is NIMMessageFileAttachment) {
      final filePath = (attachment as NIMMessageFileAttachment).path;
      Alog.d(
          tag: 'ChatKit',
          moduleName: 'MessageExt',
          content: 'is File downloaded -->> path:$filePath');

      if (filePath?.isNotEmpty != true) {
        return false;
      }
      File file = File(filePath!);
      if (file.existsSync()) {
        return true;
      }
    }
    return false;
  }

  bool isSameMessage(NIMMessage? other) {
    if (other != null) {
      if (messageServerId != null &&
          messageServerId != '-1' &&
          other.messageServerId != null &&
          other.messageServerId != '-1') {
        return messageServerId == other.messageServerId;
      } else {
        return messageClientId == other.messageClientId;
      }
    }
    return false;
  }
}

extension ConversationInfoExt on NIMConversation {
  bool isSame(NIMConversation? conversation) {
    if (this == conversation) {
      return true;
    }
    return this.conversationId == conversation?.conversationId;
  }
}
