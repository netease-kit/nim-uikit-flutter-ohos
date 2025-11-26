// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_plugin_core_kit;

typedef MessageSender = Function(NIMMessage session);

///消息输入的Action
class MessageInputAction {
  int weight;

  /// item type
  String type;

  /// item icon
  Widget icon;

  /// item title
  String? title;

  /// item click callback
  Function(
      BuildContext context, String sessionId, NIMConversationType sessionType,
      {MessageSender? messageSender})? onTap;

  List<Permission>? permissions;
  //权限拒绝后的提示
  String? deniedTip;

  bool Function(NIMConversationType sessionType)? enable;

  MessageInputAction(
      {required this.type,
      required this.icon,
      this.title,
      this.onTap,
      this.permissions,
      this.deniedTip,
      this.weight = 0,
      this.enable});
}

///消息长按弹框菜单的Action
class MessagePopupMenuAction {
  /// item icon
  Widget icon;

  /// item title
  String? title;

  /// item click callback
  Function(BuildContext context, NIMMessage message)? onTap;

  MessagePopupMenuAction({required this.icon, this.title, this.onTap});
}
