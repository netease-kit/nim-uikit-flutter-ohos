// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:nim_chatkit/model/contact_info.dart';
import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/contact/contact_provider.dart';
import 'package:nim_chatkit/services/team/team_provider.dart';
import 'package:nim_chatkit/repo/text_search.dart';
import 'package:nim_core_v2/nim_core.dart';

import '../model/friend_search_info.dart';
import '../model/hit_type.dart';
import '../model/team_search_info.dart';

class SearchRepo {
  SearchRepo._();

  static final SearchRepo instance = SearchRepo._();

  /// 获取好友列表
  Future<List<ContactInfo?>?> _getContactList() async {
    var cache = getIt<ContactProvider>().getContactCache();
    if (cache.isNotEmpty == true) {
      return Future(() => cache);
    }
    return getIt<ContactProvider>().fetchContactList();
  }

  /// 查询好友，从姓名、昵称和账号中进行匹配
  Future<List<FriendSearchInfo>> searchFriend(String text) async {
    var contactList = (await _getContactList())
        ?.where((element) => element?.friend != null)
        .toList();
    if (contactList?.isNotEmpty == true) {
      List<FriendSearchInfo> resultList = List.empty(growable: true);
      for (var contact in contactList!) {
        if (contact?.friend?.alias?.isNotEmpty == true) {
          var record = TextSearcher.search(contact!.friend!.alias!, text);
          if (record != null) {
            resultList.add(FriendSearchInfo(
                contact: contact, hitInfo: record, hitType: HitType.alias));
            continue;
          }
        }

        if (contact?.user.name?.isNotEmpty == true) {
          var record = TextSearcher.search(contact!.user.name!, text);
          if (record != null) {
            resultList.add(FriendSearchInfo(
                contact: contact, hitInfo: record, hitType: HitType.userName));
            continue;
          }
        }
        if (contact?.user.accountId?.isNotEmpty == true) {
          var record = TextSearcher.search(contact!.user.accountId!, text);
          if (record != null) {
            resultList.add(FriendSearchInfo(
                contact: contact, hitInfo: record, hitType: HitType.account));
            continue;
          }
        }
      }
      return resultList;
    } else {
      return List.empty();
    }
  }

  /// 查询群组
  Future<List<TeamSearchInfo>> searchTeam(String text) async {
    var teamList =
        await await NimCore.instance.teamService.searchTeamByKeyword(text);
    if (teamList == null || teamList.data == null) {
      return List.empty();
    } else {
      List<TeamSearchInfo> resultList = List.empty(growable: true);
      for (var team in teamList.data!) {
        var hit = TextSearcher.search(team.name ?? '', text);
        if (hit != null && team.isValidTeam) {
          resultList.add(TeamSearchInfo(
              team: team, hitInfo: hit, hitType: HitType.teamName));
          continue;
        }
      }
      resultList.sort((a, b) {
        if (getIt<TeamProvider>().isGroupTeam(a.team)) {
          return 1;
        } else {
          return -1;
        }
      });
      return resultList;
    }
  }
}
