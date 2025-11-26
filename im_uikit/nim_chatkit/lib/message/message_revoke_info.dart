// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:nim_chatkit/model/ait/ait_contacts_model.dart';
import 'package:nim_chatkit/services/message/chat_message.dart';
import 'package:nim_chatkit/message/message_helper.dart';
import 'package:nim_core_v2/nim_core.dart';

import 'message_reply_info.dart';

class RevokedMessageInfo {
  //重新编辑的文本
  String? reeditMessage;

  //需要回复的消息
  String? replyMsgId;

  //撤回消息中包含的@的用户
  AitContactsModel? aitContactsModel;

  Map<String, String?>? multiLineMessage;

  //撤回时间
  int? revokeTime;

  RevokedMessageInfo(
      {this.reeditMessage,
      this.replyMsgId,
      this.aitContactsModel,
      this.multiLineMessage,
      this.revokeTime});

  static RevokedMessageInfo? getRevokedMessage(NIMMessage message) {
    RevokedMessageInfo? revokedMessageInfo;
    var textMsg =
        message.messageType == NIMMessageType.text ? message.text : null;
    var multiMap = MessageHelper.parseMultiLineMessage(message);
    if (textMsg?.isNotEmpty == true || multiMap?.isNotEmpty == true) {
      revokedMessageInfo = RevokedMessageInfo(
          reeditMessage: textMsg,
          multiLineMessage: multiMap,
          revokeTime: DateTime.now().millisecondsSinceEpoch);
      Map<String, dynamic>? ext;
      if (message.serverExtension?.isNotEmpty == true) {
        ext = jsonDecode(message.serverExtension!);
      }
      var replyMessageInfoMap = ext?[ChatMessage.keyReplyMsgKey] as Map?;
      if (replyMessageInfoMap != null) {
        revokedMessageInfo.replyMsgId = ReplyMessageInfo.fromMap(
                replyMessageInfoMap.cast<String, dynamic>())
            .idClient;
      }
      if (message.threadReply != null) {
        final refer = message.threadReply!;
        revokedMessageInfo.replyMsgId = refer.messageClientId;
      }
      var aitInfo = ext?[ChatMessage.keyAitMsg] as Map?;
      if (aitInfo != null) {
        revokedMessageInfo.aitContactsModel =
            AitContactsModel.fromMap(aitInfo.cast<String, dynamic>());
      }
    }
    return revokedMessageInfo;
  }

  factory RevokedMessageInfo.fromMap(Map<String, dynamic> map) {
    return RevokedMessageInfo(
      reeditMessage: map['reeditMessage'] as String?,
      replyMsgId: map['replyMsgId'] as String?,
      multiLineMessage: ((map['multiLineMessage'] as Map?) == null)
          ? null
          : (map['multiLineMessage'] as Map).cast<String, String?>(),
      aitContactsModel: ((map['aitContactsModel'] as Map?) == null)
          ? null
          : AitContactsModel.fromMap(
              (map['aitContactsModel'] as Map).cast<String, dynamic>()),
      revokeTime: map['revokeTime'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reeditMessage': this.reeditMessage,
      'replyMsgId': this.replyMsgId,
      'aitContactsModel': this.aitContactsModel?.toMap(),
      'multiLineMessage': this.multiLineMessage,
      'revokeTime': this.revokeTime
    };
  }
}
