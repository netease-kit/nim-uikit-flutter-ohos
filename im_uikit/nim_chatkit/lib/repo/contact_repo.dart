// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:nim_chatkit/model/contact_info.dart';
import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/contact/contact_provider.dart';
import 'package:nim_core_v2/nim_core.dart';

class ContactRepo {
  ///申请好友验证消息未读数变更
  static final StreamController<int> _addApplicationUnreadCountNotifier =
      StreamController<int>.broadcast();

  static Stream<int> get addApplicationUnreadCountNotifier =>
      _addApplicationUnreadCountNotifier.stream;

  ///获取通讯录列表数据，我的好友信息(包含黑名单)
  static Future<List<ContactInfo>> getContactList({bool userCache = false}) {
    if (userCache) {
      var cache = getIt<ContactProvider>().getContactCache();
      if (cache.isNotEmpty == true) {
        return Future(() => cache);
      }
    }
    return getIt<ContactProvider>().fetchContactList();
  }

  /// 根据账号ID，查询账号ID对应的好友信息，包括昵称、头像等数据
  static Future<ContactInfo?> getFriend(String accId) {
    return getIt<ContactProvider>().getContact(accId);
  }

  ///根据用户账号列表获取用户资料
  static Future<NIMResult<List<NIMUserInfo>>> getUserList(
      List<String> accountIds) {
    return NimCore.instance.userService.getUserList(accountIds);
  }

  ///根据用户账号列表获取用户资料
  static Future<NIMResult<List<NIMUserInfo>>> getUserListFromCloud(
      List<String> accountIds) {
    return NimCore.instance.userService.getUserListFromCloud(accountIds);
  }

  ///获取好友列表
  static Future<NIMResult<List<NIMFriend>>> getFriendList() {
    return NimCore.instance.friendService.getFriendList();
  }

  ///根据AccountId获取好友信息
  static Future<NIMResult<List<NIMFriend>>> getFriendByIds(
      List<String> accountIds) {
    return NimCore.instance.friendService.getFriendByIds(accountIds);
  }

  /// 添加好友
  static Future<NIMResult<void>> addFriend(
      String userId, NIMFriendAddMode verifyType) async {
    var isBlockList = ContactRepo.isBlockList(userId);
    if (isBlockList == true) {
      await ContactRepo.removeBlocklist(userId);
    }

    var params = NIMFriendAddParams(addMode: verifyType);
    return NimCore.instance.friendService.addFriend(userId, params);
  }

  ///删除好友
  static Future<NIMResult<void>> deleteFriend(String userId,
      {bool includeAlias = true}) async {
    var params = NIMFriendDeleteParams(deleteAlias: includeAlias);
    return getIt<ContactProvider>().deleteFriend(userId, params: params);
  }

  ///是否为好友关系
  static Future<bool> isFriend(String userId) {
    return NimCore.instance.friendService
        .checkFriend([userId]).then((value) => value.data?[userId] ?? false);
  }

  ///更新好友昵称
  static Future<NIMResult<void>> updateAlias(String userId, String alias) {
    var params = NIMFriendSetParams();
    params.alias = alias;
    return NimCore.instance.friendService.setFriendInfo(userId, params);
  }

  ///更新好友信息
  static Future<NIMResult<void>> setFriendInfo(
      String userId, NIMFriendSetParams params) {
    return NimCore.instance.friendService.setFriendInfo(userId, params);
  }

  ///更新自己的用户资料
  static Future<NIMResult<void>> updateSelfUserProfile(
      NIMUserUpdateParam param) {
    return NimCore.instance.userService.updateSelfUserProfile(param);
  }

  ///获取黑名单列表
  static Future<List<NIMUserInfo>> getBlockList() async {
    var blockAccounts = await NimCore.instance.userService.getBlockList();
    if (blockAccounts.isSuccess && blockAccounts.data != null) {
      var userList =
          await NimCore.instance.userService.getUserList(blockAccounts.data!);
      if (userList.data != null) {
        return userList.data!;
      }
    }
    return List.empty();
  }

  ///将该用户从黑名单中移除
  static Future<NIMResult<void>> removeBlocklist(String userId) {
    return NimCore.instance.userService.removeUserFromBlockList(userId);
  }

  ///添加用户到黑名单
  static Future<NIMResult<void>> addBlocklist(String userId) {
    return NimCore.instance.userService.addUserToBlockList(userId);
  }

  ///是否在黑名单中
  static bool isBlockList(String userId) {
    return getIt<ContactProvider>().isBlockList(userId);
  }

  /// 同意添加好友申请
  static Future<NIMResult<void>> acceptAddApplication(
      NIMFriendAddApplication application) {
    return NimCore.instance.friendService.acceptAddApplication(application);
  }

  /// 拒绝添加好友申请
  static Future<NIMResult<void>> rejectAddApplication(
      NIMFriendAddApplication application,
      {String? postscript}) {
    return NimCore.instance.friendService
        .rejectAddApplication(application, postscript ?? "");
  }

  ///查询添加好友申请列表
  static Future<NIMResult<NIMFriendAddApplicationResult>> getAddApplicationList(
      int limit,
      {int offset = 0}) {
    var option =
        NIMFriendAddApplicationQueryOption(limit: limit, offset: offset);
    return NimCore.instance.friendService.getAddApplicationList(option);
  }

  ///设置好友申请已读,调用该方法，历史数据未读数据均标记为已读
  static Future<NIMResult<void>> setAddApplicationRead() {
    return NimCore.instance.friendService
        .setAddApplicationRead()
        .then((result) {
      if (result.isSuccess) {
        _addApplicationUnreadCountNotifier.add(0);
      }
      return result;
    });
  }

  ///获取好友申请未读数量,统计所有状态为未处理，且未读的数量
  static Future<NIMResult<int>> getAddApplicationUnreadCount() {
    return NimCore.instance.friendService
        .getAddApplicationUnreadCount()
        .then((result) {
      if (result.isSuccess && result.data != null) {
        _addApplicationUnreadCountNotifier.add(result.data!);
      }
      return result;
    });
  }

  ///清空添加好友申请通知
  static Future<NIMResult<void>> clearAllAddApplication() {
    return NimCore.instance.friendService
        .clearAllAddApplication()
        .then((result) {
      if (result.isSuccess) {
        _addApplicationUnreadCountNotifier.add(0);
      }
      return result;
    });
  }

  ///注册好友增加的监听器
  static Stream<NIMFriend> registerFriendAddedObserver() {
    return NimCore.instance.friendService.onFriendAdded;
  }

  ///注册好友删除的监听器
  static Stream<NIMFriendDeletion> registerFriendDeleteObserver() {
    return NimCore.instance.friendService.onFriendDeleted;
  }

  ///注册好友更新的监听器
  static Stream<NIMFriend> registerFriendInfoChangedObserver() {
    return NimCore.instance.friendService.onFriendInfoChanged;
  }

  ///注册用户资料变更的监听器
  static Stream<List<NIMUserInfo>> registerUserProfileChangedObserver() {
    return NimCore.instance.userService.onUserProfileChanged;
  }

  ///注册黑名单添加的通知
  static Stream<NIMUserInfo> registerBlockListAddedObserver() {
    return NimCore.instance.userService.onBlockListAdded;
  }

  ///注册黑名单移除的通知
  static Stream<String> registerBlockListRemovedObserver() {
    return NimCore.instance.userService.onBlockListRemoved;
  }

  ///注册好友添加申请监听器
  static Stream<NIMFriendAddApplication>
      registerFriendAddApplicationObserver() {
    return NimCore.instance.friendService.onFriendAddApplication;
  }

  ///注册好友添加申请被拒绝监听器
  static Stream<NIMFriendAddApplication> registerFriendAddRejectedObserver() {
    return NimCore.instance.friendService.onFriendAddRejected;
  }
}
