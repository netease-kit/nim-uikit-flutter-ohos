// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_chatkit/im_kit_client.dart';
import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/login/im_login_service.dart';
import 'package:nim_core_v2/nim_core.dart';

extension FriendUserNotifyInfo on NIMFriendAddApplication {
  Future<NIMUserInfo?> getFromUser() async {
    if (applicantAccountId == null) {
      return null;
    } else {
      var accountId = applicantAccountId;
      if (applicantAccountId == getIt<IMLoginService>().userInfo?.accountId) {
        accountId = operatorAccountId;
      }

      if (accountId != null) {
        var userResult =
            await NimCore.instance.userService.getUserList([accountId]);
        if (userResult.isSuccess &&
            userResult.data != null &&
            userResult.data!.isNotEmpty) {
          return userResult.data!.first;
        } else {
          final userCloudResult = await NimCore.instance.userService
              .getUserListFromCloud([accountId]);
          if (userCloudResult.isSuccess &&
              userCloudResult.data != null &&
              userCloudResult.data!.isNotEmpty) {
            return userCloudResult.data!.first;
          }
        }
      }
    }
    return null;
  }

  Future<NotifyExtension> getNotifyExt() async {
    var user = await getFromUser();
    return NotifyExtension(fromUser: user);
  }
}

extension TeamUserNotifyInfo on NIMTeamJoinActionInfo {
  Future<NIMUserInfo?> getOperatorUser() async {
    if (operatorAccountId == null) {
      return null;
    } else {
      var accountId = operatorAccountId;
      if (operatorAccountId == getIt<IMLoginService>().userInfo?.accountId) {
        return IMKitClient.getUserInfo();
      }

      if (accountId != null) {
        var userResult =
            await NimCore.instance.userService.getUserList([accountId]);
        if (userResult.isSuccess &&
            userResult.data != null &&
            userResult.data!.isNotEmpty) {
          return userResult.data!.first;
        } else {
          final userCloudResult = await NimCore.instance.userService
              .getUserListFromCloud([accountId]);
          if (userCloudResult.isSuccess &&
              userCloudResult.data != null &&
              userCloudResult.data!.isNotEmpty) {
            return userCloudResult.data!.first;
          }
        }
      }
    }
    return null;
  }

  Future<NIMTeam?> getTeamInfo() async {
    return (await NimCore.instance.teamService.getTeamInfo(teamId, teamType))
        .data;
  }

  Future<NotifyExtension> getNotifyExt() async {
    final user = await getOperatorUser();
    final team = await getTeamInfo();
    return NotifyExtension(fromUser: user, team: team);
  }
}

class NotifyExtension {
  NIMUserInfo? fromUser;

  NIMTeam? team;

  NotifyExtension({this.fromUser, this.team});
}
