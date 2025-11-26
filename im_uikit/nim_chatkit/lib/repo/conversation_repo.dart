// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:nim_chatkit/im_kit_client.dart';
import 'package:nim_core_v2/nim_core.dart';

class ConversationRepo {
  ConversationRepo._();

  static ConversationRepo instance = ConversationRepo._();

  final subscriptions = <StreamSubscription?>[];

  ///开启异步回调的session 数量阀值
  static int syncLimit = 100;

  /// 查询会话列表，支持传入Comparator对会话列表进行排序
  static Future<NIMConversationResult?> getConversationList(
      int offset, int limit) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    var _result;
    if (enableCloud) {
      _result = await NimCore.instance.conversationService
          .getConversationList(offset, limit);
    } else {
      _result = await NimCore.instance.localConversationService
          .getConversationList(offset, limit);
    }

    if (_result.isSuccess) {
      return _result.data;
    }
    return null;
  }

  /// 设置当前会话
  static Future<NIMResult<void>> setCurrentConversation(
      String conversationId) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      return NIMResult.failure(message: 'not support');
    } else {
      return NimCore.instance.localConversationService
          .setCurrentConversation(conversationId);
    }
  }

  /// 根据会话ID获取会话信息
  static Future<NIMResult<NIMConversation>> getConversation(
      String conversationId) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      return NimCore.instance.conversationService
          .getConversation(conversationId);
    } else {
      return NimCore.instance.localConversationService
          .getConversation(conversationId);
    }
  }

  /// 根据会话ID获取会话列表
  static Future<NIMResult<List<NIMConversation>>> getConversationListByIds(
      List<String> conversationIds) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      return NimCore.instance.conversationService
          .getConversationListByIds(conversationIds);
    } else {
      return NimCore.instance.localConversationService
          .getConversationListByIds(conversationIds);
    }
  }

  /// 清除当前会话的未读数
  static clearSessionUnreadCount(String conversationId) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      NimCore.instance.conversationService
          .clearUnreadCountByIds([conversationId]);
    } else {
      NimCore.instance.localConversationService
          .clearUnreadCountByIds([conversationId]);
    }
  }

  /// 会话置顶
  static Future<NIMResult<void>> addStickTop(String conversationId) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      return NimCore.instance.conversationService
          .stickTopConversation(conversationId, true);
    } else {
      return NimCore.instance.localConversationService
          .stickTopConversation(conversationId, true);
    }
  }

  /// 移除置顶
  static Future<NIMResult<void>> removeStickTop(String conversationId) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      return NimCore.instance.conversationService
          .stickTopConversation(conversationId, false);
    } else {
      return NimCore.instance.localConversationService
          .stickTopConversation(conversationId, false);
    }
  }

  /// 会话置顶操作
  static Future<NIMResult<void>> stickTopConversation(
      String conversationId, bool stickTop) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      return NimCore.instance.conversationService
          .stickTopConversation(conversationId, stickTop);
    } else {
      return NimCore.instance.localConversationService
          .stickTopConversation(conversationId, stickTop);
    }
  }

  /// 删除会话
  static void deleteConversation(
      String conversationId, bool clearMessage) async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      NimCore.instance.conversationService
          .deleteConversation(conversationId, clearMessage);
    } else {
      NimCore.instance.localConversationService
          .deleteConversation(conversationId, clearMessage);
    }
  }

  /// 获取消息未读数
  static Future<NIMResult<int>> getMsgUnreadCount() async {
    final enableCloud = await IMKitClient.enableCloudConversation;
    if (enableCloud) {
      return NimCore.instance.conversationService.getTotalUnreadCount();
    } else {
      return NimCore.instance.localConversationService.getTotalUnreadCount();
    }
  }

  /// 会话同步开始
  static Stream<void> onSyncStarted() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onSyncStarted;
    } else {
      return NimCore.instance.localConversationService.onSyncStarted;
    }
  }

  /// 会话同步完成
  static Stream<void> onSyncFinished() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onSyncFinished;
    } else {
      return NimCore.instance.localConversationService.onSyncFinished;
    }
  }

  /// 会话同步失败
  static Stream<void> onSyncFailed() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onSyncFailed;
    } else {
      return NimCore.instance.localConversationService.onSyncFailed;
    }
  }

  /// 会话创建
  static Stream<NIMConversation> onConversationCreated() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onConversationCreated;
    } else {
      return NimCore.instance.localConversationService.onConversationCreated;
    }
  }

  /// 会话删除
  static Stream<List<String>> onConversationDeleted() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onConversationDeleted;
    } else {
      return NimCore.instance.localConversationService.onConversationDeleted;
    }
  }

  /// 会话更新
  static Stream<List<NIMConversation>> onConversationChanged() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onConversationChanged;
    } else {
      return NimCore.instance.localConversationService.onConversationChanged;
    }
  }

  /// 会话未读消息计数更新
  static Stream<int> onTotalUnreadCountChanged() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onTotalUnreadCountChanged;
    } else {
      return NimCore
          .instance.localConversationService.onTotalUnreadCountChanged;
    }
  }

  /// 未读数改变回调
  static Stream<UnreadChangeFilterResult> onUnreadCountChangedByFilter() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onUnreadCountChangedByFilter;
    } else {
      return NimCore
          .instance.localConversationService.onUnreadCountChangedByFilter;
    }
  }

  /// 账号多端登录会话已读时间戳标记通知 账号A登录设备D1, D2, D1会话已读时间戳标记，同步到D2成
  static Stream<ReadTimeUpdateResult> onConversationReadTimeUpdated() {
    if (IMKitClient.isEnableCloudConversation() == true) {
      return NimCore.instance.conversationService.onConversationReadTimeUpdated;
    } else {
      return NimCore
          .instance.localConversationService.onConversationReadTimeUpdated;
    }
  }
}
