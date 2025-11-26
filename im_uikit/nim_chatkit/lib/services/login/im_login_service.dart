// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_core_v2/nim_core.dart';

///IM登录服务接口
abstract class IMLoginService {
  NIMUserInfo? userInfo;

  ///登录状态
  NIMLoginStatus status = NIMLoginStatus.loginStatusUnlogin;

  ///登录状态变更，主要用于状态同步完成回调
  Stream<NIMLoginStatus>? loginStatus;

  ///手动登录IM
  Future<NIMResult<void>> loginIM(String accountId, String token,
      {NIMLoginOption? option});

  ///同步用户信息，调用手动登录IM的时候会自动调用
  ///如果使用IM的自动登录功能，成功之后可以调用此方法同步用户信息
  Future<void> syncUserInfo(String account);

  ///登出IM
  Future<NIMResult<void>> logoutIM();

  ///获取用户信息
  Future<NIMUserInfo?> getUserInfo({bool userCache = false});
}
