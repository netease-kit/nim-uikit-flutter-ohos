// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nim_chatkit/model/ait/ait_contacts_model.dart';
import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/login/im_login_service.dart';
import 'package:nim_chatkit/services/message/chat_message.dart';
import 'package:nim_chatkit/services/message/nim_chat_cache.dart';
import 'package:nim_core_v2/nim_core.dart';

import 'database_helper.dart';

///管理session列表的@消息处理
class AitServer {
  AitServer._();

  static AitServer? _instance;

  static AitServer get instance => _instance ??= AitServer._();

  /// 当前会话id, 用于判断是否需要保存@消息
  String? _currentConversationId;

  // 添加互斥锁，确保同步安全
  bool _isLocked = false;

  final StreamController<AitSession?> _onSessionAitUpdated =
      StreamController<AitSession?>.broadcast();

  get onSessionAitUpdated => _onSessionAitUpdated.stream;

  /// 获取锁的私有方法
  Future<void> _acquireLock() async {
    while (_isLocked) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
    _isLocked = true;
  }

  /// 释放锁的私有方法
  void _releaseLock() {
    _isLocked = false;
  }

  void initListener() {
    NIMChatCache.instance.currentChatIdNotifier.listen((chatSession) {
      _currentConversationId = chatSession?.conversationId;
      // 不为空代表进入会话页面，清除当前会话的@消息
      if (chatSession?.conversationId != null) {
        clearAitMessage(chatSession!.conversationId);
        _onSessionAitUpdated
            .add(AitSession(chatSession.conversationId, isAit: false));
      }
    });

    // 监听收到消息
    NimCore.instance.messageService.onReceiveMessages.listen((event) async {
      for (var message in event) {
        if (message.conversationType == NIMConversationType.team &&
                message.conversationId != _currentConversationId
            // && e.status != NIMMessageStatus.read
            ) {
          var remoteExtension = null;
          if (message.serverExtension?.isNotEmpty == true) {
            remoteExtension = jsonDecode(message.serverExtension!);
          }
          var aitMap = remoteExtension?[ChatMessage.keyAitMsg] as Map?;
          if (aitMap != null) {
            final aitContact =
                AitContactsModel.fromMap(aitMap.cast<String, dynamic>());
            final myId =
                (await getIt<IMLoginService>().getUserInfo(userCache: true))
                        ?.accountId ??
                    '';
            if (aitContact.isUserBeAit(myId)) {
              saveAitMessage(
                      message.conversationId!, message.messageClientId!, myId)
                  .then((value) {
                _onSessionAitUpdated.add(AitSession(message.conversationId!,
                    messageId: message.messageClientId!));
              });
            }
          }
        }
      }
    });

    // 消息撤回
    NimCore.instance.messageService.onMessageRevokeNotifications
        .listen((msgRevokeNotifications) {
      for (var messageNotify in msgRevokeNotifications) {
        if (messageNotify.messageRefer?.conversationType ==
            NIMConversationType.team) {
          var remoteExtension = null;
          if (messageNotify.serverExtension?.isNotEmpty == true) {
            remoteExtension = jsonDecode(messageNotify.serverExtension!);
          }
          if (remoteExtension?[ChatMessage.keyAitMsg] != null) {
            var aitMap = (remoteExtension![ChatMessage.keyAitMsg] as Map)
                .cast<String, dynamic>();
            final aitContact = AitContactsModel.fromMap(aitMap);
            final myId = getIt<IMLoginService>().userInfo?.accountId;
            var conversationId = messageNotify.messageRefer?.conversationId;
            var clientId = messageNotify.messageRefer?.messageClientId;
            if (conversationId != null &&
                clientId != null &&
                aitContact.isUserBeAit(myId)) {
              _onSessionAitUpdated.add(AitSession(conversationId,
                  isAit: false,
                  messageId: messageNotify.messageRefer?.messageClientId));
              DatabaseHelper.instance
                  .deleteMessage(conversationId, clientId, myId!);
            }
          }
        }
      }
    });
  }

  /// 保存@消息 - 线程安全版本
  Future<bool> saveAitMessage(
      String conversationId, String messageId, String myId) async {
    await _acquireLock();
    try {
      if (conversationId == _currentConversationId) {
        return false;
      }
      return (await DatabaseHelper.instance
              .insertAitMessage(conversationId, messageId, myId)) >
          0;
    } finally {
      _releaseLock();
    }
  }

  /// 删除session中所有@消息
  Future<int> clearAitMessage(String conversationId) {
    final myId = getIt<IMLoginService>().userInfo?.accountId;
    if (myId == null) {
      return Future.value(0);
    }
    return DatabaseHelper.instance.clearSessionAitMessage(conversationId, myId);
  }

  ///新的会话是否是ai会话
  bool isNewAitConversation(NIMConversation conversation) {
    if (conversation.type == NIMConversationType.team &&
        conversation.conversationId != _currentConversationId) {
      var remoteExtension = null;
      if (conversation.lastMessage?.serverExtension?.isNotEmpty == true) {
        remoteExtension =
            jsonDecode(conversation.lastMessage!.serverExtension!);
      }
      var aitMap = remoteExtension?[ChatMessage.keyAitMsg] as Map?;
      if (aitMap != null) {
        final aitContact =
            AitContactsModel.fromMap(aitMap.cast<String, dynamic>());
        final myId = getIt<IMLoginService>().userInfo?.accountId ?? "";
        if (aitContact.isUserBeAit(myId)) {
          return true;
        }
      }
    }
    return false;
  }

  /// 获取session是否是ai消息
  Future<bool> isAitConversation(String conversationId, String myId) async {
    final msgList = await DatabaseHelper.instance
        .queryMessageIdsBySessionId(conversationId, myId);
    return msgList.isNotEmpty;
  }

  /// 获取所有@会话 - 线程安全版本
  Future<List<String>> getAllAitSession(String myId) async {
    await _acquireLock();
    try {
      return await DatabaseHelper.instance.queryAllAitSession(myId);
    } finally {
      _releaseLock();
    }
  }
}

class AitSession {
  final String sessionId;
  final String? messageId;
  final bool isAit;

  AitSession(this.sessionId, {this.messageId, this.isAit = true});
}
