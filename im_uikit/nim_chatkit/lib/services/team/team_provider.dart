// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_core_v2/nim_core.dart';

import '../../model/team_models.dart';

abstract class TeamProvider {
  static const imUIKitGroup = 'im_ui_kit_group';

  ///默认群组创建的最大成员数
  static const defaultTeamLimit = 2000;

  ///默认群组创建时的最大邀请成员数
  static const createTeamInviteLimit = 200;

  ///创建群组
  ///[inviteeAccountIds]选中的账号,创建team的时候将邀请
  ///[selectNames]选中者的名称，将用于生成team 名称
  ///[postscript]邀请他人附言
  ///[isGroup]是否讨论组
  ///[createTeamParams]创建群组的params，如果[createTeamParams]不为空,则[createTeamParams]生效，以上可选参数将失效
  Future<NIMCreateTeamResult?> createTeam(List<String> inviteeAccountIds,
      {String? postscript,
      List<String>? selectNames,
      NIMCreateTeamParams? createTeamParams,
      String? iconUrl,
      bool isGroup = false,
      NIMAntispamConfig? antispamConfig});

  ///查询群成员列表
  ///[teamId]群id
  Future<NIMResult<TeamMemberInfoListResult>> queryMemberList(
      String teamId, NIMTeamType type,
      {NIMTeamMemberQueryOption? option});

  ///是否是讨论组
  bool isGroupTeam(NIMTeam? team);
}

/// 查询群成员列表结果
class TeamMemberInfoListResult {
  /// 数据是否拉取完毕
  bool finished;

  /// 下一次查询的偏移量
  String? nextToken;

  /// 群组成员列表

  List<UserInfoWithTeam> memberList;

  TeamMemberInfoListResult({
    required this.finished,
    this.nextToken,
    required this.memberList,
  });
}
