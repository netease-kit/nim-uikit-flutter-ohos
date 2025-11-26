// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/login/im_login_service.dart';
import 'package:nim_core_v2/nim_core.dart';

///message model for chatKit
class ChatMessage {
  ///是否未撤回消息
  static const keyRevokeMsg = 'message/isRevokedMsg';

  ///撤回消息的显示内容，包括文案和回复消息的内容
  static const keyRevokeMsgContent = 'message/revokeMsgContent';

  ///回复消息的key
  static const keyReplyMsgKey = 'yxReplyMsg';

  static const keyImageType = 'ImageType';

  static const keyAitMsg = 'yxAitMsg';

  ///换行消息的key
  static const keyMultiLineTitle = 'title';

  static const keyMultiLineBody = 'body';

  NIMMessage nimMessage;

  NIMMessagePin? pinOption;
  NIMUserInfo? fromUser;

  ///only for send case
  ///仅用于发送时存储，方便重发时使用,不可用于展示
  NIMMessage? replyMsg;

  /// 群消息已读回执的已读数
  int? ackCount;

  /// 是否为撤回消息
  bool get isRevoke {
    if (nimMessage.localExtension?.isNotEmpty == true) {
      Map<String, dynamic>? extension =
          jsonDecode(nimMessage.localExtension!) as Map<String, dynamic>?;

      if (extension?[keyRevokeMsg] == true) {
        return true;
      }
    }
    return false;
  }

  /// 群消息已读回执的未读数
  int? unAckCount;

  ChatMessage(this.nimMessage, {this.pinOption, this.replyMsg});

  String? getPinAccId() {
    if (pinOption != null) {
      return pinOption!.operatorId ??
          getIt<IMLoginService>().userInfo!.accountId;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (other is ChatMessage) {
      return nimMessage.messageClientId == other.nimMessage.messageClientId;
    }
    return false;
  }

  @override
  int get hashCode => nimMessage.messageClientId.hashCode;

  String getNickName() {
    String name = nimMessage.senderId ?? '';
    if (fromUser?.name?.isNotEmpty == true) {
      name = fromUser!.name!;
    }
    return name;
  }
}
