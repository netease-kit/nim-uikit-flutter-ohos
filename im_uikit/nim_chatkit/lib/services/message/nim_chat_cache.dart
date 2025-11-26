// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:nim_core_v2/nim_core.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../../im_kit_client.dart';
import '../../model/contact_info.dart';
import '../../model/team_models.dart';
import '../../service_locator.dart';
import '../contact/contact_provider.dart';
import '../team/team_provider.dart';

///全局的单个会话缓存
///统一维护会话的用户信息，群信息，群成员信息，pin消息
class NIMChatCache {
  static const String logTag = 'NIMChatCache';

  NIMChatCache._();

  static NIMChatCache instance = NIMChatCache._();

  ///当前会话信息
  ChatSession? _currentChatSession;

  ///设置的次数，解决因为chat_page 生命周期导致的问题
  int wight = 0;

  ChatSession? get currentChatSession => _currentChatSession;

  //下次拉取群成员的token
  String? _nextMemberToken;

  //是否已经拉全了成员
  bool _haveFinished = false;

  //是否加载中
  bool _isLoading = false;

  void setCurrentChatSession(ChatSession chatSession) {
    if (_currentChatSession?.conversationId == chatSession.conversationId &&
        _currentChatSession?.conversationType == chatSession.conversationType) {
      Alog.d(
          tag: logTag,
          content:
              'setCurrentChatSession repeat ${chatSession.conversationId} conversationType = ${chatSession.conversationType}');
      wight++;
      return;
    }
    _isLoading = false;
    _currentChatSession = chatSession;
    _currentChatIdNotifier.add(chatSession);
    Alog.d(
        tag: logTag,
        content:
            'setCurrentChatSession success ${chatSession.conversationId} conversationType = ${chatSession.conversationType}');
    _setCurrentChatCache();
  }

  void clearCurrentChatSession(String? sessionId,
      NIMConversationType conversationType, String conversationId) {
    if (currentChatSession?.conversationId == conversationId &&
        currentChatSession?.conversationType == conversationType) {
      if (wight > 1) {
        wight--;
        Alog.d(
            tag: logTag,
            content:
                'clearCurrentChatSession wight more than 1 $conversationId conversationType = $conversationType');
        return;
      }
      _isLoading = false;
      _currentChatSession = null;
      _currentChatIdNotifier.add(null);
      Alog.d(
          tag: logTag,
          content:
              'clearCurrentChatSession success $conversationId conversationType = $conversationType');
      _setCurrentChatCache();
    }
  }

  ///当前会话信息变更
  final StreamController<ChatSession?> _currentChatIdNotifier =
      StreamController<ChatSession?>.broadcast();

  Stream<ChatSession?> get currentChatIdNotifier =>
      _currentChatIdNotifier.stream;

  ///当前联系人信息变更
  final StreamController<ContactInfo> _contactInfoNotifier =
      StreamController<ContactInfo>.broadcast();

  Stream<ContactInfo> get contactInfoNotifier => _contactInfoNotifier.stream;

  ///当前群信息变更
  final StreamController<NIMTeam> _teamInfoNotifier =
      StreamController<NIMTeam>.broadcast();

  Stream<NIMTeam> get teamInfoNotifier => _teamInfoNotifier.stream;

  ///群成员信息变更
  final StreamController<List<UserInfoWithTeam>> _teamMembersNotifier =
      StreamController<List<UserInfoWithTeam>>.broadcast();

  Stream<List<UserInfoWithTeam>> get teamMembersNotifier =>
      _teamMembersNotifier.stream;

  ///pin消息变更
  final StreamController<PinMessageEvent> _pinnedMessagesNotifier =
      StreamController<PinMessageEvent>.broadcast();

  get pinnedMessagesNotifier => _pinnedMessagesNotifier.stream;

  /// P2P 会话的对象，联系人
  ContactInfo? _contactInfo;

  get contactInfo => _contactInfo;

  /// 群会话的Team
  NIMTeam? _teamInfo;

  NIMTeam? get teamInfo => _teamInfo;

  /// 群成员
  final Map<String, UserInfoWithTeam> _teamMembers = {};

  List<UserInfoWithTeam> get teamMembers =>
      _teamMembers.isNotEmpty ? sortList(_teamMembers.values.toList())! : [];

  ///pin 消息合集
  final List<NIMMessagePin> _pinnedMessages = [];

  get pinnedMessages => _pinnedMessages;

  final subscriptions = <StreamSubscription>[];

  bool haveAitAllPrivilege() {
    if (_currentChatSession?.conversationType != NIMConversationType.team) {
      return false;
    }
    var myRole = myTeamRole();
    if (myRole == NIMTeamMemberRole.memberRoleOwner ||
        myRole == NIMTeamMemberRole.memberRoleManager) {
      return true;
    }
    var extension = teamInfo?.serverExtension;
    if (extension?.isNotEmpty == true) {
      var extMap = json.decode(extension!) as Map<String, dynamic>?;
      if (extMap != null && extMap[aitPrivilegeKey] == aitPrivilegeManager) {
        return false;
      }
    }
    return true;
  }

  ///是否有权限修改群信息
  bool hasPrivilegeToModify() {
    NIMTeam? team = teamInfo;
    var myRole = myTeamRole();
    return (team?.updateInfoMode == NIMTeamUpdateInfoMode.updateInfoModeAll) ||
        (team?.updateInfoMode == NIMTeamUpdateInfoMode.updateInfoModeManager &&
            (myRole == NIMTeamMemberRole.memberRoleManager ||
                myRole == NIMTeamMemberRole.memberRoleOwner)) ||
        getIt<TeamProvider>().isGroupTeam(team);
  }

  NIMTeamMemberRole? myTeamRole() {
    if (IMKitClient.account() != null) {
      var myTeamMember = _teamMembers[IMKitClient.account()!];
      return myTeamMember?.teamInfo.memberRole;
    }
    return null;
  }

  List<UserInfoWithTeam>? getTeamManagers() {
    return _teamMembers.values
        .toList()
        .where((element) =>
            element.teamInfo.memberRole == NIMTeamMemberRole.memberRoleManager)
        .toList();
  }

  //是否有权限邀请其他人
  bool hasPrivilegeToInvite() {
    var team = _teamInfo;
    var myTeamMember = _teamMembers[IMKitClient.account() ?? ''];
    return (team?.inviteMode == NIMTeamInviteMode.inviteModeAll) ||
        (!getIt<TeamProvider>().isGroupTeam(team) &&
            (myTeamMember?.teamInfo.memberRole ==
                    NIMTeamMemberRole.memberRoleOwner ||
                myTeamMember?.teamInfo.memberRole ==
                    NIMTeamMemberRole.memberRoleManager)) ||
        getIt<TeamProvider>().isGroupTeam(team);
  }

  void _setCurrentChatCache() async {
    if (currentChatSession == null) {
      for (var sub in subscriptions) {
        sub.cancel();
      }
      subscriptions.clear();
      _teamInfo = null;
      _contactInfo = null;
      _teamMembers.clear();
      _pinnedMessages.clear();
      wight = 0;
      return;
    }
    wight = 1;
    if (currentChatSession!.conversationType == NIMConversationType.p2p) {
      getIt<ContactProvider>()
          .getContact(await currentChatSession!.targetId)
          .then((value) {
        _contactInfo = value;
        _contactInfoNotifier.add(value!);
      });
    } else if (currentChatSession!.conversationType ==
        NIMConversationType.team) {
      //获取群信息
      NimCore.instance.teamService
          .getTeamInfo(
              await currentChatSession!.targetId, NIMTeamType.typeNormal)
          .then((value) {
        if (value.isSuccess) {
          _teamInfo = value.data;
          _teamInfoNotifier.add(teamInfo!);
        }
      });
      //获取群成员
      fetchTeamMember(await currentChatSession!.targetId);
    }
    if (IMKitClient.enablePin) {
      _fetchPinMessage(currentChatSession!.conversationId,
          currentChatSession!.conversationType);
    }
    _initListener();
  }

  Future<void> fetchAllMember(String tId) async {
    while (_haveFinished != true) {
      await fetchTeamMember(tId,
          loadMore: _nextMemberToken?.isNotEmpty == true);
    }
  }

  ///获取群成员
  Future<void> fetchTeamMember(String tId, {bool loadMore = false}) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    if (loadMore && _haveFinished) {
      _isLoading = false;
      return;
    }
    if (currentChatSession?.conversationType == NIMConversationType.team &&
        tId == (await currentChatSession?.targetId)) {
      var option = NIMTeamMemberQueryOption(
          limit: 1000,
          roleQueryType: NIMTeamMemberRoleQueryType.memberRoleQueryTypeAll);

      if (loadMore) {
        option.nextToken = _nextMemberToken;
      } else {
        _nextMemberToken = null;
      }

      //获取群成员
      var memberResult = await getIt<TeamProvider>().queryMemberList(
          await currentChatSession!.targetId, NIMTeamType.typeNormal,
          option: option);

      if (memberResult.isSuccess && memberResult.data != null) {
        _nextMemberToken = memberResult.data!.nextToken;

        _haveFinished = memberResult.data!.finished;

        if (!loadMore) {
          _teamMembers.clear();
        }
        for (var member in memberResult.data!.memberList) {
          _teamMembers[member.teamInfo.accountId] = member;
        }
        //确保获取本人的成员信息
        if (!_teamMembers.containsKey(IMKitClient.account()!)) {
          final myInfo = await getMyTeamMember(tId);
          if (myInfo != null) {
            _teamMembers[IMKitClient.account()!] = myInfo;
          }
        }
        _teamMembersNotifier.add(sortList(_teamMembers.values.toList())!);
      }
    } else {
      Alog.e(
          tag: logTag,
          content:
              'fetchTeamMember error currentSessionId =  ${currentChatSession?.conversationId} tid =  $tId conversationType = ${currentChatSession?.conversationType}');
    }
    _isLoading = false;
  }

  UserInfoWithTeam? getTeamMember(String? account, String tid) {
    if (account?.isNotEmpty == true) {
      final member = _teamMembers[account];
      if (member?.teamInfo.teamId == tid) {
        return member;
      }
    }

    return null;
  }

  Future<UserInfoWithTeam?> getMyTeamMember(String tid,
      {bool refresh = false}) async {
    final myMember = getTeamMember(IMKitClient.account(), tid);
    if (myMember != null && !refresh) {
      return myMember;
    } else if (IMKitClient.account() != null) {
      final teamMemberResult = await NimCore.instance.teamService
          .getTeamMemberListByIds(
              tid, NIMTeamType.typeNormal, [IMKitClient.account()!]);
      if (teamMemberResult.isSuccess && teamMemberResult.data?.first != null) {
        final myInfo = UserInfoWithTeam(
            IMKitClient.getUserInfo(), teamMemberResult.data!.first);
        _teamMembers[IMKitClient.account()!] = myInfo;
        return myInfo;
      }
    }
    return null;
  }

  void _initListener() {
    //昵称更新
    var contactChange = getIt<ContactProvider>().onContactInfoUpdated;
    if (currentChatSession?.conversationType == NIMConversationType.p2p) {
      if (contactChange != null) {
        subscriptions.add(contactChange.listen((e) async {
          if (currentChatSession?.conversationType == NIMConversationType.p2p &&
              e.user.accountId == (await currentChatSession?.targetId)) {
            _contactInfo = e;
            _contactInfoNotifier.add(contactInfo!);
          }
        }));
      }
    } else if (currentChatSession?.conversationType ==
        NIMConversationType.team) {
      subscriptions.addAll([
        //群信息同步完成，更新自己的身份
        NimCore.instance.teamService.onSyncFinished.listen((team) {
          if (teamInfo?.teamId.isNotEmpty == true) {
            getMyTeamMember(teamInfo!.teamId, refresh: true);
          }
        }),

        //群信息
        NimCore.instance.teamService.onTeamInfoUpdated.listen((team) {
          if (team.teamId == teamInfo?.teamId) {
            _teamInfo = team;
            _teamInfoNotifier.add(teamInfo!);
          }
        }),
        //群成员退出
        NimCore.instance.teamService.onTeamMemberLeft.listen((event) async {
          for (var member in event) {
            if (member.teamId == (await currentChatSession?.targetId)) {
              _teamMembers.remove(member.accountId);
              _teamMembersNotifier.add(sortList(_teamMembers.values.toList())!);
            }
          }
        }),
        //群成员移除
        NimCore.instance.teamService.onTeamMemberKicked.listen((event) async {
          for (var member in event.teamMembers) {
            if (member.teamId == (await currentChatSession?.targetId)) {
              _teamMembers.remove(member.accountId);
              _teamMembersNotifier.add(sortList(_teamMembers.values.toList())!);
            }
          }
        }),
        //群成员增加或者更新
        NimCore.instance.teamService.onTeamMemberJoined.listen((event) async {
          for (var member in event) {
            if (member.teamId == (await currentChatSession?.targetId)) {
              var change = getTeamMember(member.accountId, member.teamId);
              if (change == null) {
                var userInfo =
                    await getIt<ContactProvider>().getContact(member.accountId);
                var teamMember = UserInfoWithTeam(userInfo?.user, member);
                teamMember.alias = userInfo?.friend?.alias;
                _teamMembers[member.accountId] = teamMember;
              } else {
                _teamMembers[member.accountId]?.teamInfo = member;
              }
              _teamMembersNotifier.add(sortList(_teamMembers.values.toList())!);
            }
          }
        }),
        NimCore.instance.teamService.onTeamMemberInfoUpdated
            .listen((event) async {
          for (var member in event) {
            if (member.teamId == (await currentChatSession?.targetId)) {
              var change = getTeamMember(member.accountId, member.teamId);
              if (change == null) {
                var userInfo =
                    await getIt<ContactProvider>().getContact(member.accountId);
                var teamMember = UserInfoWithTeam(userInfo?.user, member);
                teamMember.alias = userInfo?.friend?.alias;
                _teamMembers[member.accountId] = teamMember;
              } else {
                _teamMembers[member.accountId]?.teamInfo = member;
              }
              _teamMembersNotifier.add(sortList(_teamMembers.values.toList())!);
            }
          }
        }),
        if (contactChange != null)
          //用户信息变更
          contactChange.listen((e) {
            if (currentChatSession?.conversationType ==
                NIMConversationType.team) {
              var member = _teamMembers[e.user.accountId];
              if (member != null) {
                _teamMembers[e.user.accountId]?.userInfo = e.user;
                _teamMembers[e.user.accountId]?.alias = e.friend?.alias;
                _teamMembersNotifier
                    .add(sortList(_teamMembers.values.toList())!);
              }
            }
          }),
      ]);
    }

    if (IMKitClient.enablePin) {
      subscriptions.add(NimCore.instance.messageService.onMessagePinNotification
          .listen((event) {
        if (event.pin?.messageRefer?.conversationId ==
                currentChatSession?.conversationId &&
            event.pin?.messageRefer?.conversationType ==
                _currentChatSession?.conversationType) {
          NIMMessagePinState? state = event.pinState;
          if (state == NIMMessagePinState.pinned) {
            _pinnedMessages.add(event.pin!);
          } else if (state == NIMMessagePinState.notPinned) {
            _pinnedMessages
                .removeWhere((element) => _isSameMessage(element, event.pin!));
          } else {
            var index = _pinnedMessages
                .indexWhere((element) => _isSameMessage(element, event.pin!));
            if (index >= 0) {
              _pinnedMessages[index] = event.pin!;
            } else {
              _pinnedMessages.add(event.pin!);
            }
          }
          var type = PinEventType.init;
          if (event.pinState == NIMMessagePinState.notPinned) {
            type = PinEventType.remove;
          }
          if (event.pinState == NIMMessagePinState.pinned) {
            type = PinEventType.add;
          }
          _pinnedMessagesNotifier
              .add(PinMessageEvent(_pinnedMessages, event, type));
        }
      }));
    }

    //数据同步完成拉一次
    subscriptions.add(NimCore.instance.loginService.onDataSync.listen((event) {
      if (event.type == NIMDataSyncType.nimDataSyncMain &&
          event.state == NIMDataSyncState.nimDataSyncStateCompleted) {
        if (IMKitClient.enablePin) {
          _fetchPinMessage(currentChatSession!.conversationId,
              currentChatSession!.conversationType);
        }
      }
    }));
  }

  bool _sameMessage(NIMMessagePin pin, NIMMessage msg) {
    if (pin.messageRefer?.messageServerId != null &&
        pin.messageRefer?.messageServerId != '-1' &&
        msg.messageServerId != null &&
        msg.messageServerId != '-1') {
      return pin.messageRefer?.messageServerId == msg.messageServerId;
    } else {
      return pin.messageRefer?.messageClientId == msg.messageClientId;
    }
  }

  bool _isSameMessage(NIMMessagePin pin, NIMMessagePin pin2) {
    if (pin.messageRefer?.messageServerId != null &&
        pin.messageRefer?.messageServerId != '-1' &&
        pin2.messageRefer?.messageServerId != null &&
        pin2.messageRefer?.messageServerId != '-1') {
      return pin.messageRefer?.messageServerId ==
          pin2.messageRefer?.messageServerId;
    } else {
      return pin.messageRefer?.messageClientId ==
          pin2.messageRefer?.messageClientId;
    }
  }

  ///获取Pin 的消息列表
  void _fetchPinMessage(
      String conversationId, NIMConversationType conversationType) {
    NimCore.instance.messageService
        .getPinnedMessageList(conversationId: conversationId)
        .then((value) {
      if (conversationId != currentChatSession?.conversationId ||
          conversationType != currentChatSession?.conversationType) {
        return;
      }
      if (value.isSuccess && value.data != null) {
        _pinnedMessages.clear();
        _pinnedMessages.addAll(value.data!);
        _pinnedMessagesNotifier
            .add(PinMessageEvent(_pinnedMessages, null, PinEventType.init));
      } else if (!value.isSuccess) {
        Alog.e(
            tag: logTag,
            content:
                'queryMessagePinForSession error ${value.code} ${value.errorDetails}');
      }
    });
  }
}

enum PinEventType {
  add,
  remove,
  update,
  init,
}

class PinMessageEvent {
  List<NIMMessagePin> pinMessages;

  NIMMessagePinNotification? notification;

  PinEventType type;

  PinMessageEvent(this.pinMessages, this.notification, this.type);
}

class ChatSession {
  //会话目标，如果是p2p为对方账号
  //如果是 team 为teamId
  String? _sessionId;

  Future<String> get targetId async {
    if (_sessionId != null) {
      return _sessionId!;
    }
    _sessionId = (await NimCore.instance.conversationIdUtil
            .conversationTargetId(conversationId))
        .data!;
    return _sessionId!;
  }

  //会话类型
  NIMConversationType conversationType;

  //会话ID
  String conversationId;

  ChatSession(this._sessionId, this.conversationType, this.conversationId);
}
