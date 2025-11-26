// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:netease_common/netease_common.dart';
import 'package:nim_chatkit/model/contact_info.dart';
import 'package:nim_chatkit/services/contact/contact_provider.dart';
import 'package:nim_core_v2/nim_core.dart';

class ContactProviderImpl extends ContactProvider {
  final subscriptions = <StreamSubscription>[];

  final StreamController<ContactInfo> _onContactUpdated =
      StreamController<ContactInfo>.broadcast();

  final StreamController<List<ContactInfo>> _onContactListComplete =
      StreamController<List<ContactInfo>>.broadcast();

  @override
  Future<ContactInfo?> getContact(String accId,
      {bool needRefresh = false, bool needFriend = true}) async {
    if (!needRefresh && contactMap[accId] != null) {
      return contactMap[accId]!;
    }
    NIMUserInfo? user = await _getUser(accId, needRefresh: needRefresh);
    if (user != null) {
      ContactInfo? contactInfo;
      if (needFriend) {
        contactInfo = await _getFriend(user);
      } else {
        contactInfo = ContactInfo(user);
      }
      //重新设置是否在黑名单
      contactInfo?.isInBlack = contactMap[accId]?.isInBlack;
      //如果没有好友信息则使用原来的好友信息
      contactInfo?.friend ??= contactMap[accId]?.friend;
      contactMap[accId] = contactInfo;
      if (needRefresh && contactInfo != null) {
        _onContactUpdated.add(contactInfo);
      }
      return contactInfo;
    } else {
      return null;
    }
  }

  Future<NIMUserInfo?> _getUser(String accId,
      {bool needRefresh = false}) async {
    if (!needRefresh) {
      var userResult = await NimCore.instance.userService.getUserList([accId]);
      if (userResult.isSuccess) {
        return userResult.data?.first;
      }
    }
    var userResult2 =
        await NimCore.instance.userService.getUserListFromCloud([accId]);
    if (userResult2.isSuccess &&
        userResult2.data != null &&
        userResult2.data!.isNotEmpty) {
      return userResult2.data!.first;
    } else {
      return null;
    }
  }

  Future<ContactInfo?> _getFriend(NIMUserInfo user) async {
    //由于请求到Friend 信息并不代表是好友，所以单独调用一次是否是好友的判断
    ContactInfo contact = ContactInfo(user);
    var friendMap =
        (await NimCore.instance.friendService.checkFriend([user.accountId!]))
            .data;
    var isFriend = friendMap?[user.accountId];
    if (isFriend == true) {
      var friendResult = await NimCore.instance.friendService
          .getFriendByIds([user.accountId!]);
      if (friendResult.isSuccess && friendResult.data?.isNotEmpty == true) {
        contact.friend = friendResult.data?.first;
      }
    }
    return contact;
  }

  void initListener() {
    onContactInfoUpdated = _onContactUpdated.stream;

    subscriptions
        .add(NimCore.instance.friendService.onFriendAdded.listen((event) {
      String userId = event.accountId;
      if (contactMap[userId] != null) {
        contactMap[userId]!.friend = event;
        _onContactUpdated.add(contactMap[userId]!);
      } else if (event.userProfile != null) {
        contactMap[userId] = ContactInfo(event.userProfile!, friend: event);
        _onContactUpdated.add(contactMap[userId]!);
      } else {
        _getUser(userId).then((value) {
          if (value != null) {
            contactMap[userId] = ContactInfo(value, friend: event);
            _onContactUpdated.add(contactMap[userId]!);
          }
        });
      }
    }));

    subscriptions
        .add(NimCore.instance.friendService.onFriendInfoChanged.listen((event) {
      String userId = event.accountId;
      if (contactMap[userId] != null) {
        contactMap[userId]!.friend = event;
        _onContactUpdated.add(contactMap[userId]!);
      } else if (event.userProfile != null) {
        contactMap[userId] = ContactInfo(event.userProfile!, friend: event);
        _onContactUpdated.add(contactMap[userId]!);
      } else {
        _getUser(userId).then((value) {
          if (value != null) {
            contactMap[userId] = ContactInfo(value, friend: event);
            _onContactUpdated.add(contactMap[userId]!);
          }
        });
      }
    }));

    subscriptions
        .add(NimCore.instance.userService.onUserProfileChanged.listen((event) {
      for (var e in event) {
        String userId = e.accountId ?? '';
        if (contactMap[userId] != null) {
          contactMap[userId]!.user = e;
        } else {
          contactMap[userId] = ContactInfo(e);
        }
        _onContactUpdated.add(contactMap[userId]!);
      }
    }));

    subscriptions
        .add(NimCore.instance.friendService.onFriendDeleted.listen((event) {
      contactMap.removeWhere((key, value) => event.accountId == key);
    }));

    //加入黑名单
    subscriptions
        .add(NimCore.instance.userService.onBlockListAdded.listen((event) {
      String userId = event.accountId ?? '';
      if (userId.isNotEmpty) {
        addBlockList(event.accountId!);
      }
      if (contactMap[userId]?.user.accountId == event.accountId &&
          contactMap[userId]?.friend != null) {
        contactMap[userId]!.isInBlack = true;
        _onContactUpdated.add(contactMap[userId]!);
      }
    }));

    //移除黑名单
    subscriptions.add(
        NimCore.instance.userService.onBlockListRemoved.listen((userId) async {
      removeBlockList(userId);
      if (contactMap[userId]?.user.accountId == userId &&
          contactMap[userId]?.friend != null) {
        contactMap[userId]!.isInBlack = false;
        _onContactUpdated.add(contactMap[userId]!);
      } else {
        //防止多端同步，断网等特殊case
        final contact = await getContact(userId, needRefresh: true);
        if (contact != null && contact.friend != null) {
          contactMap[userId] = contact;
          _onContactUpdated.add(contact);
        }
      }
    }));
  }

  @override
  void removeListeners() {
    for (var element in subscriptions) {
      element.cancel();
    }
    subscriptions.clear();
  }

  /// 按步长分块
  List<List<T>> splitList<T>(List<T> list, {int chunkSize = 150}) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, list.length);
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  @override
  Future<List<ContactInfo>> fetchContactList() async {
    var friendResult = await NimCore.instance.friendService.getFriendList();
    cleanCache();
    blockList = (await NimCore.instance.userService.getBlockList()).data ?? [];
    if (friendResult.isSuccess && friendResult.data != null) {
      final friendList = friendResult.data!;

      //获取需要拉取userInfo的好友列表
      final lackUserInfoFriends =
          friendList.where((friend) => friend.userProfile == null).toList();
      final friendAccList =
          lackUserInfoFriends.map((e) => e.accountId).toList();
      List<NIMUserInfo> userList = [];
      for (var accIds in splitList(friendAccList)) {
        final users = await NimCore.instance.userService.getUserList(accIds);
        if (users.isSuccess && users.data != null) {
          userList += users.data!;
        }
      }

      //填充ContactInfo 列表
      List<ContactInfo> contactList = friendList.map((e) {
        final contact = ContactInfo(
            e.userProfile ??
                userList.firstWhereOrNull(
                    (element) => element.accountId == e.accountId) ??
                NIMUserInfo(accountId: e.accountId),
            friend: e,
            isInBlack: blockList.contains(e.accountId) == true);
        contactMap[e.accountId] = contact;
        return contact;
      }).toList();
      _onContactListComplete.add(contactList);
      return contactList;
    } else {
      return List.empty();
    }
  }

  @override
  void cleanCache() {
    contactMap.clear();
    blockList.clear();
  }

  @override
  bool isBlockList(String accId) {
    return blockList.contains(accId);
  }

  @override
  void addBlockList(String accId) {
    if (blockList.contains(accId) == false) {
      blockList.add(accId);
    }
  }

  @override
  void removeBlockList(String accId) {
    if (blockList.contains(accId) == true) {
      blockList.remove(accId);
    }
  }

  @override
  List<ContactInfo> getContactCache() {
    return contactMap.values
        .where((e) => e != null && e.friend != null)
        .map((value) => value!)
        .toList();
  }

  @override
  ContactInfo? getContactInCache(String accId) {
    return contactMap[accId];
  }

  @override
  Future<List<ContactInfo>> fetchUserList(List<String> accIdList) async {
    final List<String> fetchList =
        accIdList.where((element) => contactMap[element] == null).toList();

    if (fetchList.isNotEmpty) {
      int start = 0;
      int end = fetchList.length > 150 ? 150 : fetchList.length;
      while (start < fetchList.length) {
        final fetchResult = await NimCore.instance.userService
            .getUserListFromCloud(fetchList.sublist(start, end));
        if (fetchResult.isSuccess && fetchResult.data != null) {
          for (var e in fetchResult.data!) {
            contactMap[e.accountId!] = ContactInfo(e);
          }
        }
        start = end;
        end = start + 150;
        if (end > fetchList.length) {
          end = fetchList.length;
        }
      }
    }

    return accIdList.map((e) => contactMap[e]!).toList();
  }

  @override
  Future<NIMResult<void>> deleteFriend(String accountId,
      {NIMFriendDeleteParams? params}) {
    return NimCore.instance.friendService
        .deleteFriend(accountId, params)
        .then((value) {
      //do nothing
      return value;
    });
  }

  @override
  void init() {
    onContactListComplete = _onContactListComplete.stream;
    if (Platform.isAndroid) {
      subscriptions.add(
          NimCore.instance.localConversationService.onSyncStarted.listen((e) {
        fetchContactList();
      }));
    } else {
      subscriptions
          .add(NimCore.instance.loginService.onDataSync.listen((event) {
        if (event.type == NIMDataSyncType.nimDataSyncMain &&
            event.state == NIMDataSyncState.nimDataSyncStateCompleted) {
          fetchContactList();
        }
      }));
    }

    initListener();
  }
}
