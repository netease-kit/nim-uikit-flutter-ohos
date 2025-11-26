// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:nim_chatkit/manager/ai_user_manager.dart';
import 'package:nim_chatkit/model/team_models.dart';
import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/login/im_login_service.dart';
import 'package:nim_chatkit/services/team/team_provider.dart';
import 'package:nim_chatkit/repo/conversation_repo.dart';
import 'package:nim_core_v2/nim_core.dart';

import 'config_repo.dart';

class TeamRepo {
  ///申请好友验证消息未读数变更
  static final StreamController<int> _teamActionsUnreadCountNotifier =
      StreamController<int>.broadcast();

  static Stream<int> get teamActionsUnreadCountNotifier =>
      _teamActionsUnreadCountNotifier.stream;

  /// 注册群资料变动监听器
  static Stream<NIMTeam> registerTeamUpdateObserver() {
    return NimCore.instance.teamService.onTeamInfoUpdated;
  }

  /// 获取当前已经加入的群组列表
  static Future<NIMResult<List<NIMTeam>>> getJoinedTeamList(
      {List<NIMTeamType>? teamTypes}) {
    return NimCore.instance.teamService.getJoinedTeamList(teamTypes ?? []);
  }

  /// 查询群组中用户的资料（当前用户设置）
  static Future<TeamWithMember?> queryTeamWithMember(
      String teamId, String accId) async {
    var team = await NimCore.instance.teamService
        .getTeamInfo(teamId, NIMTeamType.typeNormal);
    if (team.isSuccess) {
      var teamMember = await NimCore.instance.teamService
          .getTeamMemberListByIds(teamId, NIMTeamType.typeNormal, [accId]);
      return TeamWithMember(team.data!, teamMember.data?.first);
    }
    return null;
  }

  /// 设置群消息不提醒
  static Future<bool> updateTeamNotify(String teamId, bool mute) async {
    var result = await NimCore.instance.settingsService.setTeamMessageMuteMode(
        teamId,
        NIMTeamType.typeNormal,
        mute
            ? NIMTeamMessageMuteMode.teamMessageMuteModeOn
            : NIMTeamMessageMuteMode.teamMessageMuteModeOff);
    return result.isSuccess;
  }

  ///获取群操作的未读数
  static Future<NIMResult<int>> getTeamActionsUnreadCount() async {
    final teamActionsListResult = await NimCore.instance.teamService
        .getTeamJoinActionInfoList(
            NIMTeamJoinActionInfoQueryOption(limit: 100));
    if (teamActionsListResult.data?.infos?.isNotEmpty == true) {
      final lastTime = await ConfigRepo.getTeamApplicationReadTime();
      int unreadCount = 0;
      teamActionsListResult.data?.infos?.forEach((e) {
        if ((e.timestamp ?? 0) > lastTime) {
          unreadCount++;
        }
      });
      _teamActionsUnreadCountNotifier.add(unreadCount);
      return NIMResult.success(data: unreadCount);
    }
    return NIMResult.failure(
        code: teamActionsListResult.code,
        message: teamActionsListResult.errorDetails);
  }

  static Future<bool> getTeamNotify(String teamId) async {
    var result = await NimCore.instance.settingsService.getTeamMessageMuteMode(
      teamId,
      NIMTeamType.typeNormal,
    );
    return result.data != NIMTeamMessageMuteMode.teamMessageMuteModeOn;
  }

  /// 对整个群禁言、解除禁言，对普通成员生效，只有群组、管理员有权限
  static Future<bool> muteAllMembers(String teamId, bool mute) async {
    var result = await NimCore.instance.teamService.setTeamChatBannedMode(
        teamId,
        NIMTeamType.typeNormal,
        mute
            ? NIMTeamChatBannedMode.chatBannedModeBannedNormal
            : NIMTeamChatBannedMode.chatBannedModeNone);
    return result.isSuccess;
  }

  static Future<bool> _updateTeam(
      String teamId, NIMTeamType type, NIMUpdateTeamInfoParams params) async {
    var result = await NimCore.instance.teamService
        .updateTeamInfo(teamId, type, params, null);
    return result.isSuccess;
  }

  /// 查询群资料
  static Future<NIMTeam?> getTeamInfo(String teamId, NIMTeamType type) {
    return NimCore.instance.teamService
        .getTeamInfo(teamId, type)
        .then((result) {
      if (result.isSuccess) {
        return result.data;
      }
      return null;
    });
  }

  /// 批量查询群资料
  static Future<List<NIMTeam>?> getTeamInfoByIds(
      List<String> teamIds, NIMTeamType type) {
    return NimCore.instance.teamService
        .getTeamInfoByIds(teamIds, type)
        .then((result) {
      if (result.isSuccess) {
        return result.data;
      }
      return null;
    });
  }

  /// 更新群头像
  static Future<bool> updateTeamIcon(
      String teamId, NIMTeamType type, String avatar) {
    NIMUpdateTeamInfoParams params = NIMUpdateTeamInfoParams();
    params.avatar = avatar;
    return _updateTeam(teamId, type, params);
  }

  /// 更新群名
  static Future<bool> updateTeamName(
      String teamId, NIMTeamType type, String name) {
    NIMUpdateTeamInfoParams params = NIMUpdateTeamInfoParams();
    params.name = name;
    return _updateTeam(teamId, type, params);
  }

  /// 更新群介绍
  static Future<bool> updateTeamIntroduce(
      String teamId, NIMTeamType type, String introduction) {
    NIMUpdateTeamInfoParams params = NIMUpdateTeamInfoParams();
    params.intro = introduction;
    return _updateTeam(teamId, type, params);
  }

  /// 更新群邀请模式
  static Future<bool> updateInviteMode(
      String teamId, NIMTeamType type, NIMTeamInviteMode inviteMode) async {
    NIMUpdateTeamInfoParams params = NIMUpdateTeamInfoParams();
    params.inviteMode = inviteMode;
    return _updateTeam(teamId, type, params);
  }

  /// 更新群资料修改模式
  static Future<bool> updateTeamInfoPrivilege(String teamId, NIMTeamType type,
      NIMTeamUpdateInfoMode updateInfoMode) async {
    NIMUpdateTeamInfoParams params = NIMUpdateTeamInfoParams();
    params.updateInfoMode = updateInfoMode;
    return _updateTeam(teamId, type, params);
  }

  /// 更新群扩展字段
  static Future<bool> updateTeamExtension(
      String teamId, NIMTeamType type, String extension) {
    NIMUpdateTeamInfoParams params = NIMUpdateTeamInfoParams();
    params.serverExtension = extension;
    return _updateTeam(teamId, type, params);
  }

  /// 更新入群模式
  static Future<bool> updateBeInviteMode(
      String teamId, NIMTeamType type, bool isNeed) {
    NIMUpdateTeamInfoParams params = NIMUpdateTeamInfoParams();
    params.agreeMode = isNeed
        ? NIMTeamAgreeMode.agreeModeAuth
        : NIMTeamAgreeMode.agreeModeNoAuth;
    return _updateTeam(teamId, type, params);
  }

  /// 更新申请同意
  static Future<bool> updateApplyAgreeMode(
      String teamId, NIMTeamType type, bool isNeed) {
    NIMUpdateTeamInfoParams params = NIMUpdateTeamInfoParams();
    params.joinMode =
        isNeed ? NIMTeamJoinMode.joinModeApply : NIMTeamJoinMode.joinModeFree;
    return _updateTeam(teamId, type, params);
  }

  ///申请加入群
  static Future<NIMResult<NIMTeam>> applyJoinTeam(
      String teamId, NIMTeamType teamType,
      {String? postscript}) async {
    return NimCore.instance.teamService
        .applyJoinTeam(teamId, teamType, postscript);
  }

  /// 退出群
  static Future<bool> quitTeam(String teamId, NIMTeamType type) async {
    var teamResult =
        await NimCore.instance.teamService.getTeamInfo(teamId, type);
    // 讨论组的退出逻辑
    //1，判断是否为讨论组，非讨论组直接退出
    //2, 判断是否为创建者，非创建者直接退出
    //3, 判断是否成员数大于1，如果不大于1直接解散，且不能是数字人
    //4，请求成员列表，将群转给第一个成员，并退出
    if (getIt<TeamProvider>().isGroupTeam(teamResult.data)) {
      var team = teamResult.data;
      if (team?.ownerAccountId == getIt<IMLoginService>().userInfo?.accountId) {
        //如果群人员人数大于1，则先转让
        //无法转让则解散
        if ((team?.memberCount ?? 0) > 1) {
          final option = NIMTeamMemberQueryOption(
              roleQueryType: NIMTeamMemberRoleQueryType.memberRoleQueryTypeAll);
          var membersResult = (await NimCore.instance.teamService
                  .getTeamMemberList(teamId, type, option))
              .data;
          if (membersResult?.memberList?.isNotEmpty == true) {
            var newOwner = membersResult?.memberList?.firstWhereOrNull(
                (element) =>
                    element.accountId !=
                        getIt<IMLoginService>().userInfo?.accountId &&
                    !AIUserManager.instance.isAIUser(element.accountId));
            if (newOwner != null) {
              var resTrans = await NimCore.instance.teamService
                  .transferTeamOwner(teamId, type, newOwner.accountId, true);
              return resTrans.isSuccess;
            }
          }
        }
        var resDismiss =
            await NimCore.instance.teamService.dismissTeam(teamId, type);
        return resDismiss.isSuccess;
      }
    }
    var res = await NimCore.instance.teamService.leaveTeam(teamId, type);
    return res.isSuccess;
  }

  /// 解散群，只有创建者有此权限
  static Future<bool> dismissTeam(String teamId, NIMTeamType type) async {
    var res = await NimCore.instance.teamService.dismissTeam(teamId, type);
    return res.isSuccess;
  }

  /// 会话是否置顶
  static Future<bool> isStickTop(String teamId, NIMTeamType type) async {
    final conversationId =
        (await NimCore.instance.conversationIdUtil.teamConversationId(teamId))
            .data!;
    final conversation =
        (await ConversationRepo.getConversation(conversationId)).data;
    return conversation?.stickTop == true;
  }

  /// 更新群中，用户的昵称
  static Future<bool> updateMemberNick(String teamId, NIMTeamType teamType,
      String accountId, String teamNick) async {
    var res = await NimCore.instance.teamService
        .updateTeamMemberNick(teamId, teamType, accountId, teamNick);
    return res.isSuccess;
  }

  /// 邀请用户入群
  static Future<NIMResult<List<String>>> inviteUser(
      String teamId,
      NIMTeamType teamType,
      List<String> inviteeAccountIds,
      String? postscript) {
    return NimCore.instance.teamService
        .inviteMember(teamId, teamType, inviteeAccountIds, postscript);
  }

  /// 会话置顶
  static Future<NIMResult<void>> addStickTop(String teamId) async {
    final conversationId =
        (await NimCore.instance.conversationIdUtil.teamConversationId(teamId))
            .data!;
    return ConversationRepo.stickTopConversation(conversationId, true);
  }

  /// 移除置顶
  static Future<NIMResult<void>> removeStickTop(String teamId) async {
    final conversationId =
        (await NimCore.instance.conversationIdUtil.teamConversationId(teamId))
            .data!;
    return ConversationRepo.stickTopConversation(conversationId, false);
  }

  /// 添加管理员
  static Future<NIMResult<void>> addTeamManager(
      String teamId, NIMTeamType teamType, List<String> memberAccountIds) {
    return NimCore.instance.teamService.updateTeamMemberRole(teamId, teamType,
        memberAccountIds, NIMTeamMemberRole.memberRoleManager);
  }

  /// 移除管理员
  static Future<NIMResult<void>> removeTeamManager(
      String teamId, NIMTeamType teamType, List<String> memberAccountIds) {
    return NimCore.instance.teamService.updateTeamMemberRole(
        teamId, teamType, memberAccountIds, NIMTeamMemberRole.memberRoleNormal);
  }

  /// 移除群成员
  static Future<NIMResult<void>> removeTeamMembers(
      String teamId, NIMTeamType teamType, List<String>? memberAccountIds) {
    return NimCore.instance.teamService
        .kickMember(teamId, teamType, memberAccountIds);
  }

  ///设置群申请已读,调用该方法，历史数据未读数据均标记为已读
  static void setTeamActionInfosRead() {
    ConfigRepo.updateTeamApplicationReadTime(
        DateTime.now().millisecondsSinceEpoch);
    _teamActionsUnreadCountNotifier.add(0);
  }
}
