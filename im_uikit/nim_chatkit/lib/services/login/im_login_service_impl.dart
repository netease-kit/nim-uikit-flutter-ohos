// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:nim_chatkit/services/login/im_login_service.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class IMLoginServiceImpl extends IMLoginService {
  List<StreamSubscription> subs = List.empty(growable: true);

  bool isAutoLogin = true;

  final StreamController<NIMLoginStatus> _onLoginStatusChanged =
      StreamController<NIMLoginStatus>.broadcast();

  @override
  Future<NIMResult<void>> loginIM(String accountId, String token,
      {NIMLoginOption? option}) async {
    isAutoLogin = false;
    setUserListener();
    NIMLoginOption? innerOption;
    if (option == null) {
      innerOption = NIMLoginOption();
    } else {
      innerOption = option;
    }
    var result = await NimCore.instance.loginService
        .login(accountId, token, innerOption);
    if (result.isSuccess) {
      await syncUserInfo(accountId);
      return result;
    } else {
      return result;
    }
  }

  void setUserListener() {
    loginStatus = _onLoginStatusChanged.stream;

    subs.add(NimCore.instance.userService.onUserProfileChanged.listen((event) {
      for (var user in event) {
        if (user.accountId == userInfo?.accountId) {
          userInfo = user;
        }
      }
    }));
    subs.add(NimCore.instance.loginService.onLoginStatus.listen((event) {
      _onLoginStatusChanged.add(event);
      status = event;
    }));
  }

  void removeUserListener() {
    for (var sub in subs) {
      sub.cancel();
    }
  }

  @override
  Future<NIMUserInfo?> getUserInfo({bool userCache = false}) async {
    if (userCache && userInfo != null) {
      return userInfo;
    }
    var account = userInfo?.accountId;
    if (account != null) {
      var res = await NimCore.instance.userService.getUserList([account]);
      if (res.isSuccess) {
        userInfo = res.data?.first;
      }
    }
    return userInfo;
  }

  @override
  Future<NIMResult<void>> logoutIM() {
    return NimCore.instance.loginService.logout().then((value) {
      if (value.isSuccess) {
        removeUserListener();
      }
      return value;
    });
  }

  @override
  Future<void> syncUserInfo(String account) async {
    //如果是自动登录，先设置监听
    if (isAutoLogin) {
      setUserListener();
      _onLoginStatusChanged.add(NIMLoginStatus.loginStatusLogined);
      status = NIMLoginStatus.loginStatusLogined;
    }
    //1, 先从本地取
    var localUserInfoResult =
        await NimCore.instance.userService.getUserList([account]);
    if (localUserInfoResult.data != null &&
        localUserInfoResult.data?.isNotEmpty == true) {
      userInfo = localUserInfoResult.data?.first;
    } else {
      //本地取不到再从云端取
      var userResult =
          await NimCore.instance.userService.getUserListFromCloud([account]);
      if (userResult.isSuccess && userResult.data != null) {
        userInfo = userResult.data?.first;
      }
    }
    Alog.i(
        tag: 'LoginService',
        content: 'syncUserInfo result ==> ${userInfo?.toJson()}');
  }
}
