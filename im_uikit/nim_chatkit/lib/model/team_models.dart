// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_core_v2/nim_core.dart';

const String aitPrivilegeAll = 'all';

const String aitPrivilegeManager = 'manager';

const String aitPrivilegeKey = 'yxAllowAt';

//最后一次操作
const String lastOption = 'lastOpt';

class TeamWithMember {
  NIMTeam team;
  NIMTeamMember? teamMember;

  TeamWithMember(this.team, this.teamMember);
}

class UserInfoWithTeam {
  NIMUserInfo? userInfo;
  NIMTeamMember teamInfo;
  String? alias;

  int searchPoint = 0;

  UserInfoWithTeam(this.userInfo, this.teamInfo);

  String getName({bool needAlias = true, bool needTeamNick = true}) {
    if (needAlias && alias != null && alias!.isNotEmpty) {
      return alias!;
    }
    if (needTeamNick &&
        teamInfo.teamNick != null &&
        teamInfo.teamNick!.isNotEmpty) {
      return teamInfo.teamNick!;
    }
    if (userInfo != null) {
      if (userInfo!.name != null && userInfo!.name!.isNotEmpty) {
        return userInfo!.name!;
      }
      return userInfo!.accountId ?? "";
    }
    return teamInfo.accountId;
  }

  String? getAvatar() {
    return userInfo?.avatar;
  }

  @override
  bool operator ==(Object other) =>
      other is UserInfoWithTeam &&
      teamInfo.accountId == other.teamInfo.accountId;

  @override
  int get hashCode => teamInfo.accountId.hashCode;
}

///特定规则排序群成员
///群主>管理员>普通成员
///加入时间早的在前面
List<UserInfoWithTeam>? sortList(List<UserInfoWithTeam>? memberList) {
  memberList?.sort((a, b) {
    if (a.teamInfo.memberRole == NIMTeamMemberRole.memberRoleOwner) {
      return -1;
    } else if (b.teamInfo.memberRole == NIMTeamMemberRole.memberRoleOwner) {
      return 1;
    } else if (a.teamInfo.memberRole == NIMTeamMemberRole.memberRoleManager &&
        b.teamInfo.memberRole != NIMTeamMemberRole.memberRoleManager) {
      return -1;
    } else if (a.teamInfo.memberRole != NIMTeamMemberRole.memberRoleManager &&
        b.teamInfo.memberRole == NIMTeamMemberRole.memberRoleManager) {
      return 1;
    } else if (a.teamInfo.joinTime == 0) {
      return 1;
    } else if (b.teamInfo.joinTime == 0) {
      return -1;
    }
    return a.teamInfo.joinTime - b.teamInfo.joinTime;
  });
  return memberList;
}
