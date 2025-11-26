// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:netease_corekit/report/xkit_report.dart';
import 'package:nim_chatkit/im_kit_client.dart';
import 'package:nim_chatkit/services/message/chat_message.dart';
import 'package:nim_chatkit/services/message/nim_chat_cache.dart';
import 'package:nim_chatkit/repo/chat_service_observer_repo.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import 'message/message_revoke_info.dart';

class ChatKitClientRepo {
  ChatKitClientRepo._internal();

  static final ChatKitClientRepo instance = ChatKitClientRepo._internal();

  StreamSubscription? _msgRevokedSub;

  static init() {
    XKitReporter().register(moduleName: 'ChatKit', moduleVersion: '10.0.0');
  }

  void registerRevoke(String revokedMsgContent) {
    if (_msgRevokedSub == null) {
      _msgRevokedSub =
          ChatServiceObserverRepo.observeRevokeMessage().listen((events) {
        events.forEach((action) {
          if (action.messageRefer != null &&
              action.messageRefer!.conversationId !=
                  NIMChatCache.instance.currentChatSession?.conversationId) {
            Alog.i(
                tag: 'ChatKitClientRepo',
                content: 'received message revoke notify and save to local');
            onMessageRevokedNotify(action, revokedMsgContent);
          }
        });
      });
    }
  }

  void unregisterRevoke() {
    _msgRevokedSub?.cancel();
    _msgRevokedSub = null;
  }

  Future<NIMResult<NIMMessage>> onMessageRevokedNotify(
      NIMMessageRevokeNotification revokedMsg, String revokedMsgContent) async {
    //创建一条特殊的占位消息
    final msgResult = await MessageCreator.createTextMessage(revokedMsgContent);
    if (msgResult.isSuccess && msgResult.data != null) {
      var locationExtension = null;
      //设置撤回标识
      if (msgResult.data!.localExtension?.isNotEmpty == true) {
        locationExtension = jsonDecode(msgResult.data!.localExtension!);
        locationExtension![ChatMessage.keyRevokeMsg] = true;
      } else {
        locationExtension = {ChatMessage.keyRevokeMsg: true};
      }
      msgResult.data!.localExtension = jsonEncode(locationExtension!);
      msgResult.data!.messageConfig = NIMMessageConfig(unreadEnabled: false);
      msgResult.data!.isSelf =
          revokedMsg.messageRefer?.senderId == IMKitClient.account()
              ? true
              : false;
      //将占位消息插入到本地
      return NimCore.instance.messageService.insertMessageToLocal(
          message: msgResult.data!,
          conversationId: revokedMsg.messageRefer!.conversationId!,
          senderId: revokedMsg.messageRefer?.senderId,
          createTime: revokedMsg.messageRefer?.createTime);
    }
    return NIMResult.failure(message: 'build message error');
  }

  Future<NIMResult<NIMMessage>> onMessageRevoked(
      ChatMessage revokedMsg, String revokedMsgContent) async {
    //消息不准确，这种消息是离线时SDK返回的，但是iOS没有，所以统一不展示
    if (revokedMsg.nimMessage.senderId != IMKitClient.account() &&
        revokedMsg.nimMessage.isSelf == true) {
      return NIMResult.failure(message: 'message error');
    }

    RevokedMessageInfo? revokedMessageInfo =
        RevokedMessageInfo.getRevokedMessage(revokedMsg.nimMessage);
    //创建一条特殊的占位消息
    final msgResult = await MessageCreator.createTextMessage(revokedMsgContent);
    if (msgResult.isSuccess && msgResult.data != null) {
      var locationExtension = null;
      //设置撤回标识
      if (msgResult.data!.localExtension?.isNotEmpty == true) {
        locationExtension = jsonDecode(msgResult.data!.localExtension!);
        locationExtension![ChatMessage.keyRevokeMsg] = true;
        locationExtension![ChatMessage.keyRevokeMsgContent] =
            revokedMessageInfo?.toMap();
      } else {
        locationExtension = {
          ChatMessage.keyRevokeMsg: true,
          ChatMessage.keyRevokeMsgContent: revokedMessageInfo?.toMap()
        };
      }
      msgResult.data!.localExtension = jsonEncode(locationExtension!);
      msgResult.data!.messageConfig = NIMMessageConfig(
          unreadEnabled: false, lastMessageUpdateEnabled: true);
      msgResult.data!.isSelf =
          revokedMsg.nimMessage.senderId == IMKitClient.account()
              ? true
              : false;
      //将占位消息插入到本地
      return NimCore.instance.messageService.insertMessageToLocal(
          message: msgResult.data!,
          conversationId: revokedMsg.nimMessage.conversationId!,
          senderId: revokedMsg.nimMessage.senderId,
          createTime: revokedMsg.nimMessage.createTime);
    }
    return NIMResult.failure(message: 'build message error');
  }
}
