// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:nim_core_v2/nim_core.dart';

class ChatServiceObserverRepo {
  ChatServiceObserverRepo._();

  ///单例
  static final ChatServiceObserverRepo instance = ChatServiceObserverRepo._();

  ///custom notification receiver observer
  static Stream<List<NIMCustomNotification>> observeCustomNotification() {
    return NimCore.instance.notificationService.onReceiveCustomNotifications;
  }

  /// message state change observer
  static Stream<NIMMessage> observeSendMessage() {
    return NimCore.instance.messageService.onSendMessage;
  }

  /// Message Read Receipt Observer
  static Stream<List<NIMP2PMessageReadReceipt>> observeMessageReceipt() {
    return NimCore.instance.messageService.onReceiveP2PMessageReadReceipts;
  }

  ///Team message read receipt observer
  static Stream<List<NIMTeamMessageReadReceipt>> observeTeamMessageReceipt() {
    return NimCore.instance.messageService.onReceiveTeamMessageReadReceipts;
  }

  ///Team info change observer notification
  static Stream<NIMTeam> observerTeamUpdate() {
    return NimCore.instance.teamService.onTeamInfoUpdated;
  }

  ///message attachment upload/download progress watcher
  static Stream<NIMDownloadMessageAttachmentProgress>
      observeAttachmentProgress() {
    return NimCore.instance.storageService.onMessageAttachmentDownloadProgress;
  }

  static Stream<List<NIMMessageRevokeNotification>> observeRevokeMessage() {
    return NimCore.instance.messageService.onMessageRevokeNotifications;
  }

  ///监听消息修改
  static Stream<List<NIMMessage>> observeModifyMessage() {
    return NimCore.instance.messageService.onReceiveMessagesModified;
  }

  static Stream<NIMMessagePinNotification> observeMessagePin() {
    return NimCore.instance.messageService.onMessagePinNotification;
  }

  ///message delete observer
  static Stream<List<NIMMessageDeletedNotification>> observeMessageDelete() {
    return NimCore.instance.messageService.onMessageDeletedNotifications;
  }
}
