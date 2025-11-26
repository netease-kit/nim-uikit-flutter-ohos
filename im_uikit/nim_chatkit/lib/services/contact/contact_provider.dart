// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:nim_chatkit/model/contact_info.dart';
import 'package:nim_core_v2/nim_core.dart';

abstract class ContactProvider {
  ///缓存的联系人列表
  Map<String, ContactInfo?> contactMap = HashMap();

  ///缓存的黑名单人列表
  List<String> blockList = [];

  ///联系人信息变更通知
  Stream<ContactInfo>? onContactInfoUpdated;

  ///联系人信息变更通知
  ///调用[fetchContactList] 之后会通过此回到返回全量的联系人数据
  Stream<List<ContactInfo>>? onContactListComplete;

  ///是否在黑名单中
  bool isBlockList(String accId);

  ///添加到黑名单中
  void addBlockList(String accId);

  ///从黑名单中移除
  void removeBlockList(String accId);

  ///返回缓存的联系人列表，限好友
  List<ContactInfo> getContactCache();

  ///返回缓存的联系人列表
  ///返回[contactMap]中key为[accId]的值
  ContactInfo? getContactInCache(String accId);

  ///返回特定用户的信息
  ///优先从缓存获取，失败则从SDK数据库本地获取，最后从服务端获取
  ///如果[needRefresh]为true，则从服务端获取
  ///如果[needFriend]为true，则获取好友信息
  Future<ContactInfo?> getContact(String accId,
      {bool needRefresh = false, bool needFriend = true});

  ///获取所有的好友联系人信息
  ///优先从缓存获取，失败则从SDK数据库本地获取，最后从服务端获取
  ///包含FriendInfo
  ///调用之后通过[onContactListComplete] 异步返回数据
  Future<List<ContactInfo>> fetchContactList();

  ///根据[accIdList] 批量获取用户信息
  ///优先从缓存获取，失败则从服务端获取
  ///不走数据库
  Future<List<ContactInfo>> fetchUserList(List<String> accIdList);

  ///初始化，建议在登录之前调用，[IMKitClient]会自动调用
  void init();

  ///释放联系人缓存信息和黑名单缓存列表，在退出登录时调用
  void cleanCache();

  ///释放监听,在退出IM模块时候调用
  void removeListeners();

  ///删除好友
  ///[accountId] 好友的accountId
  ///[includeAlias] 是否同时删除好友备注
  Future<NIMResult<void>> deleteFriend(String accountId,
      {NIMFriendDeleteParams? params});
}
