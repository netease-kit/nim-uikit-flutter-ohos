// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:nim_chatkit/services/team/team_provider.dart';
import 'package:nim_core_v2/nim_core.dart';

import '../../im_kit_config_center.dart';
import '../../model/team_models.dart';
import '../../service_locator.dart';
import '../contact/contact_provider.dart';
import '../login/im_login_service.dart';

class TeamProviderImpl extends TeamProvider {
  final List<String> teamDefaultIcons = [
    'https://yx-web-nosdn.netease.im/common/2425b4cc058e5788867d63c322feb7ac/groupAvatar1.png',
    'https://yx-web-nosdn.netease.im/common/62c45692c9771ab388d43fea1c9d2758/groupAvatar2.png',
    'https://yx-web-nosdn.netease.im/common/d1ed3c21d3f87a41568d17197760e663/groupAvatar3.png',
    'https://yx-web-nosdn.netease.im/common/e677d8551deb96723af2b40b821c766a/groupAvatar4.png',
    'https://yx-web-nosdn.netease.im/common/fd6c75bb6abca9c810d1292e66d5d87e/groupAvatar5.png'
  ];

  @override
  Future<NIMCreateTeamResult?> createTeam(List<String> inviteeAccountIds,
      {String? postscript,
      List<String>? selectNames,
      NIMCreateTeamParams? createTeamParams,
      String? iconUrl,
      bool isGroup = false,
      NIMAntispamConfig? antispamConfig}) async {
    NIMCreateTeamParams innerParams;
    if (createTeamParams != null) {
      innerParams = createTeamParams;
    } else {
      if (isGroup) {
        innerParams = NIMCreateTeamParams(
          name: _getTeamName(selectNames),
          teamType: NIMTeamType.typeNormal,
          joinMode: NIMTeamJoinMode.joinModeFree,
          inviteMode: NIMTeamInviteMode.inviteModeAll,
          agreeMode: NIMTeamAgreeMode.agreeModeNoAuth,
          updateInfoMode: NIMTeamUpdateInfoMode.updateInfoModeAll,
          updateExtensionMode:
              NIMTeamUpdateExtensionMode.updateExtensionModeAll,
          serverExtension: json.encode({TeamProvider.imUIKitGroup: true}),
          avatar: iconUrl ?? teamDefaultIcons[Random().nextInt(5)],
        );
      } else {
        innerParams = NIMCreateTeamParams(
          name: _getTeamName(selectNames),
          teamType: NIMTeamType.typeNormal,
          inviteMode: NIMTeamInviteMode.inviteModeManager,
          agreeMode: TeamKitConfigCenter.teamAgreeMode,
          joinMode: TeamKitConfigCenter.teamJoinMode,
          updateInfoMode: NIMTeamUpdateInfoMode.updateInfoModeManager,
          avatar: iconUrl ?? teamDefaultIcons[Random().nextInt(5)],
        );
      }
    }
    return (await NimCore.instance.teamService.createTeam(
            innerParams, inviteeAccountIds, postscript, antispamConfig))
        .data;
  }

  String _getTeamName(List<String>? selectName) {
    var teamName = selectName?.sublist(0, min(selectName.length, 30)).join('、');
    var user = getIt<IMLoginService>().userInfo;
    var tmp = user?.name ?? user?.accountId ?? '';
    if (tmp.isNotEmpty) {
      teamName = '$tmp、$teamName';
    }
    return teamName?.substring(0, min(teamName.length, 30)) ?? '';
  }

  @override
  Future<NIMResult<TeamMemberInfoListResult>> queryMemberList(
      String teamId, NIMTeamType type,
      {NIMTeamMemberQueryOption? option}) async {
    if (option == null) {
      option = NIMTeamMemberQueryOption(
          roleQueryType: NIMTeamMemberRoleQueryType.memberRoleQueryTypeAll);
    }

    var memberList = await NimCore.instance.teamService
        .getTeamMemberList(teamId, type, option);
    if (memberList.isSuccess && memberList.data?.memberList != null) {
      var results = memberList.data!.memberList!
          .map((e) => UserInfoWithTeam(null, e))
          .toList();
      //先使用本地缓存数据填充用户信息和好友信息
      _fillUserInfoWithLocalCache(results);
      //剩余本地没有用户信息的用户在使用远端用户信息填充
      var accIdList = results
          .where((element) => element.userInfo == null)
          .map((e) => e.teamInfo.accountId)
          .toList();
      int totalCount = accIdList.length;
      int maxCount = 150;
      int startIndex = 0;
      int endIndex = min(totalCount, startIndex + maxCount);
      //remote 接口一次最多150个，分批请求
      while (startIndex < endIndex) {
        var map =
            await _getUserInfoMap(accIdList.sublist(startIndex, endIndex));
        results.where((element) => element.userInfo == null).forEach((element) {
          element.userInfo = map[element.teamInfo.accountId];
        });
        startIndex = endIndex;
        endIndex = min(totalCount, endIndex + maxCount);
      }
      var infoResult = TeamMemberInfoListResult(
          finished: memberList.data!.finished,
          nextToken: memberList.data!.nextToken,
          memberList: results);
      return NIMResult.success(data: infoResult);
    }
    return NIMResult(memberList.code, null, memberList.errorDetails);
  }

  Future<Map<String, NIMUserInfo>> _getUserInfoMap(
      List<String> accIdList) async {
    var result = await NimCore.instance.userService.getUserList(accIdList);
    HashMap<String, NIMUserInfo> map = HashMap();
    if (result.isSuccess) {
      result.data?.forEach((e) {
        map[e.accountId!] = e;
      });
    }
    return map;
  }

  void _fillUserInfoWithLocalCache(List<UserInfoWithTeam> users) {
    if (getIt<ContactProvider>().contactMap.isNotEmpty) {
      for (var user in users) {
        var localInfo =
            getIt<ContactProvider>().getContactInCache(user.teamInfo.accountId);
        if (localInfo != null) {
          user.userInfo = localInfo.user;
          user.alias = localInfo.friend?.alias;
        }
      }
    }
  }

  @override
  bool isGroupTeam(NIMTeam? team) {
    if (team?.serverExtension == TeamProvider.imUIKitGroup) {
      return true;
    }
    String? extension = team?.serverExtension;
    if (extension?.isNotEmpty == true) {
      var extMap = json.decode(extension!) as Map<String, dynamic>?;
      if (extMap != null) {
        return extMap[TeamProvider.imUIKitGroup] == true;
      }
    }
    return false;
  }
}
