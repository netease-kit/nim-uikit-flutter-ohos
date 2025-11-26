// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_core_v2/nim_core.dart';

///uikit 配置类
class IMKitConfigCenter {
  ///群开关，打开后可以使用群相关服务
  static bool enableTeam = true;

  ///是否在离开群后删除会话
  static bool deleteTeamSessionWhenLeave = true;

  ///是否开启用户在线状态监听
  static bool enableOnlineStatus = true;

  ///支持呼叫功能，呼叫组件初始化后设置为true
  static bool enableCallKit = false;
}

///群配置类,创建高级群的时候生效
class TeamKitConfigCenter {
  /// 邀请入群时是否需要被邀请人的同意模式定义
  static NIMTeamAgreeMode teamAgreeMode = NIMTeamAgreeMode.agreeModeNoAuth;

  /// 申请入群的模式
  static NIMTeamJoinMode teamJoinMode = NIMTeamJoinMode.joinModeFree;
}
