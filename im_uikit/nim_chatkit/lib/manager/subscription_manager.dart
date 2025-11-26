// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:nim_core_v2/nim_core.dart';

import '../im_kit_config_center.dart';

/// 订阅在线状态管理
class SubscriptionManager {
  SubscriptionManager._();

  static final SubscriptionManager instance = SubscriptionManager._();

  static const String logTag = "SubscriptionManager";

  Set<String> _subscriptionUsers = Set();

  StreamSubscription? _loginStatusSubscription;

  /// 添加订阅用户
  /// 只操作数据
  void addSubscriptionUser(String accountId) {
    _subscriptionUsers.add(accountId);
  }

  /// 移除订阅用户
  /// 只操作数据
  void removeSubscriptionUser(String accountId) {
    _subscriptionUsers.remove(accountId);
  }

  List<String> get subscriptionUsers => _subscriptionUsers.toList();

  /// 初始化
  void init() {
    _subscriptionUsers.clear();
    _loginStatusSubscription =
        NimCore.instance.loginService.onLoginStatus.listen((event) {
      if (event == NIMLoginStatus.loginStatusLogined &&
          _subscriptionUsers.isNotEmpty) {
        subscribeUserStatus(_subscriptionUsers.toList());
      }
    });
  }

  /// 订阅用户在线状态
  /// 时长7天
  /// 订阅后立即返回一次状态
  void subscribeUserStatus(List<String> accountIds) {
    if (!IMKitConfigCenter.enableOnlineStatus || accountIds.isEmpty) {
      return;
    }
    final option = NIMSubscribeUserStatusOption(
        accountIds: accountIds,
        duration: 7 * 24 * 60 * 60,
        immediateSync: true);
    NimCore.instance.subscriptionService
        .subscribeUserStatus(option)
        .then((result) {
      if (result.isSuccess) {
        _subscriptionUsers.addAll(accountIds);

        ///去除不成功的用户
        if (result.data?.isNotEmpty == true) {
          _subscriptionUsers.removeAll(result.data!);
        }
      }
    });
  }

  /// 取消订阅用户在线状态
  void unsubscribeUserStatus(List<String> accountIds) {
    if (accountIds.isEmpty) {
      return;
    }

    final option = NIMUnsubscribeUserStatusOption(accountIds: accountIds);
    NimCore.instance.subscriptionService
        .unsubscribeUserStatus(option)
        .then((result) {
      if (result.isSuccess) {
        _subscriptionUsers.removeAll(accountIds);

        ///不成功的加回去
        if (result.data?.isNotEmpty == true) {
          _subscriptionUsers.addAll(result.data!);
        }
      }
    });
  }

  ///取消所以订阅的用户
  Future<NIMResult<void>> unsubscribeAll() async {
    _loginStatusSubscription?.cancel();
    if (_subscriptionUsers.isEmpty) {
      return NIMResult.success();
    }
    final option =
        NIMUnsubscribeUserStatusOption(accountIds: subscriptionUsers);
    return await NimCore.instance.subscriptionService
        .unsubscribeUserStatus(option);
  }
}
