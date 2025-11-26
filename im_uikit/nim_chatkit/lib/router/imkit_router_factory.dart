// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'imkit_router.dart';
import 'imkit_router_constants.dart';

/// 跳转到P2P会话页面
Future<T?> goToP2pChat<T extends Object?>(
    BuildContext context, String userId) async {
  var conversationId =
      (await NimCore.instance.conversationIdUtil.p2pConversationId(userId))
          .data!;

  return Navigator.pushNamed(context, RouterConstants.PATH_CHAT_PAGE,
      arguments: {
        'conversationId': conversationId,
        'conversationType': NIMConversationType.p2p
      });
}

/// 跳转到会话页面，并保持首页
void goToChatAndKeepHome(
    BuildContext context, String conversationId, NIMConversationType type,
    {NIMMessage? message}) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   // 先回到首页（清空栈）
  //   context.go('/');
  //
  //   // 再 push ChatPage
  //   Future.microtask(() {
  //     context.push(
  //       RouterConstants.PATH_CHAT_PAGE,
  //       extra: {
  //         'conversationId': conversationId,
  //         'conversationType': type,
  //         'anchor': message
  //       },
  //     );
  //   });
  // } else {
  Navigator.pushNamedAndRemoveUntil(
      context, RouterConstants.PATH_CHAT_PAGE, ModalRoute.withName('/'),
      arguments: {
        'conversationId': conversationId,
        'conversationType': type,
        'anchor': message
      });
  // }
}

/// 跳转到会话页面，并清空栈
void goToChatAndClearStack(
    BuildContext context, String teamConversationId, NIMConversationType type) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   context.go(
  //     RouterConstants.PATH_CHAT_PAGE,
  //     extra: {
  //       'conversationId': teamConversationId,
  //       'conversationType': type,
  //     },
  //   );
  // } else {
  Navigator.pushNamedAndRemoveUntil(context, RouterConstants.PATH_CHAT_PAGE,
      ModalRoute.withName(RouterConstants.PATH_CHAT_PAGE),
      arguments: {
        'conversationId': teamConversationId,
        'conversationType': type,
      });
  // }
}

/// 跳转到群聊页面
Future<T?> goToTeamChat<T extends Object?>(
    BuildContext context, String teamId) async {
  var conversationId =
      (await NimCore.instance.conversationIdUtil.teamConversationId(teamId))
          .data!;

  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_CHAT_PAGE, extra: {
  //     'conversationId': conversationId,
  //     'conversationType': NIMConversationType.team
  //   });
  // }

  return Navigator.pushNamed(context, RouterConstants.PATH_CHAT_PAGE,
      arguments: {
        'conversationId': conversationId,
        'conversationType': NIMConversationType.team
      });
}

Future<T?> goToChatPage<T extends Object?>(BuildContext context,
    String conversationId, NIMConversationType type) async {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_CHAT_PAGE,
  //       extra: {'conversationId': conversationId, 'conversationType': type});
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_CHAT_PAGE,
      arguments: {'conversationId': conversationId, 'conversationType': type});
}

Future<T?> goToContactSelector<T extends Object?>(BuildContext context,
    {int? mostCount,
    List<String>? filter,
    bool? returnContact,
    bool? includeAIUser}) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context
  //       .pushNamed(RouterConstants.PATH_CONTACT_SELECTOR_PAGE, extra: {
  //     'mostCount': mostCount,
  //     'filterUser': filter,
  //     'returnContact': returnContact,
  //     'includeAIUser': includeAIUser
  //   });
  // }
  return Navigator.pushNamed(
      context, RouterConstants.PATH_CONTACT_SELECTOR_PAGE,
      arguments: {
        'mostCount': mostCount,
        'filterUser': filter,
        'returnContact': returnContact,
        'includeAIUser': includeAIUser
      });
}

Future<T?> goToContactDetail<T extends Object?>(
    BuildContext context, String accId) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_USER_INFO_PAGE,
  //       extra: {'accId': accId});
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_USER_INFO_PAGE,
      arguments: {'accId': accId});
}

Future<T?> goToTeamDetail<T extends Object?>(
    BuildContext context, String teamId) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_TEAM_DETAIL_PAGE,
  //       extra: {'teamId': teamId});
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_TEAM_DETAIL_PAGE,
      arguments: {'teamId': teamId});
}

Future<T?> gotoMineInfoPage<T extends Object?>(BuildContext context) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_MINE_INFO_PAGE);
  // }
  return Navigator.pushNamed<T>(context, RouterConstants.PATH_MINE_INFO_PAGE);
}

Future<T?> goTeamListPage<T extends Object?>(BuildContext context,
    {bool? selectorModel}) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_MY_TEAM_PAGE,
  //       extra: {'selectorModel': selectorModel});
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_MY_TEAM_PAGE,
      arguments: {'selectorModel': selectorModel});
}

Future<T?> goAddFriendPage<T extends Object?>(
  BuildContext context,
) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_ADD_FRIEND_PAGE);
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_ADD_FRIEND_PAGE);
}

Future<T?> goGlobalSearchPage<T extends Object?>(
  BuildContext context,
) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_GLOBAL_SEARCH_PAGE);
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_GLOBAL_SEARCH_PAGE);
}

/// 跳转到聊天历史记录页面
Future<T?> goToTeamChatHistoryPage<T extends Object?>(
    BuildContext context, String teamId) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_CHAT_SEARCH_PAGE,
  //       extra: {'teamId': teamId});
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_CHAT_SEARCH_PAGE,
      arguments: {'teamId': teamId});
}

/// 跳转到群设置页面
Future<T?> goToTeamSettingPage<T extends Object?>(
    BuildContext context, String teamId) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_TEAM_SETTING_PAGE,
  //       extra: {'teamId': teamId});
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_TEAM_SETTING_PAGE,
      arguments: {'teamId': teamId});
}

/// 跳转到Pin 消息页面
Future<T?> goToPinPage<T extends Object?>(BuildContext context,
    String conversationId, NIMConversationType type, String title) {
  // if (IMKitRouter.instance.enableGoRouter) {
  //   return context.pushNamed(RouterConstants.PATH_CHAT_PIN_PAGE, extra: {
  //     'conversationId': conversationId,
  //     'conversationType': type,
  //     'chatTitle': title
  //   });
  // }
  return Navigator.pushNamed(context, RouterConstants.PATH_CHAT_PIN_PAGE,
      arguments: {
        'conversationId': conversationId,
        'conversationType': type,
        'chatTitle': title
      });
}
