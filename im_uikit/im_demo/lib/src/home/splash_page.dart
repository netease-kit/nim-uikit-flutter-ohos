// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:auth/auth.dart';
import 'package:auth/provider/login_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:im_demo/src/config.dart';
import 'package:im_demo/src/home/home_page.dart';
import 'package:im_demo/src/home/welcome_page.dart';
import 'package:nim_chatkit/im_kit_client.dart';
import 'package:nim_chatkit_ui/chat_kit_client.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:provider/provider.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../../l10n/S.dart';

class SplashPage extends StatefulWidget {
  final Uint8List? deviceToken;

  const SplashPage({Key? key, this.deviceToken}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  bool toLogin = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginModel>(
      builder: (context, loginModel, child) {
        if (loginModel.loginState == LoginState.logined) {
          return const HomePage();
        } else if (loginModel.loginState == LoginState.logout) {
          return toLogin
              ? UnifyLogin.goLoginPage(context)
              : WelcomePage(
                  showButton: true,
                  onPressed: () {
                    setState(() {
                      toLogin = true;
                    });
                  },
                );
        } else {
          if (loginModel.loginState == LoginState.logining) {
            IMKitClient.loginIMWithResult(loginModel.userInfo!.imAccid!,
                    loginModel.userInfo!.imToken!,
                    option: NIMLoginOption(
                        syncLevel: NIMDataSyncLevel.dataSyncLevelBasic))
                .then((value) {
              updateAPNsToken();
              UnifyLogin.setLoginResult(value.isSuccess);
              if (value.code == 102422) {
                Fluttertoast.showToast(msg: S.of(context).kickedOff);
              }
              if (value.isSuccess && (Platform.isAndroid || Platform.isIOS)) {
                ChatKitClient.instance.setupCallKit(
                    appKey: IMDemoConfig.AppKey,
                    accountId: loginModel.userInfo!.imAccid!);
              }
            });
          }
          return const WelcomePage();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    //init IM SDK
    _doInit(IMDemoConfig.AppKey);
  }

  ///获取loginInfo，用于自动登录。
  Future<NIMLoginInfo?> _getLoginInfo() async {
    var userInfo = await UnifyLogin.getUserInfo();
    if (userInfo != null) {
      return NIMLoginInfo(account: userInfo.imAccid!, token: userInfo.imToken!);
    } else {
      return null;
    }
  }

  void updateAPNsToken() {
    if (NimCore.instance.isInitialized &&
        Platform.isIOS &&
        widget.deviceToken != null) {
      NimCore.instance.apnsService.updateApnsToken(widget.deviceToken!);
    }
  }

  /// init depends package for app
  void _doInit(String appKey) async {
    var loginInfo = await _getLoginInfo();

    var options =
        await NIMSDKOptionsConfig.getSDKOptions(appKey, loginInfo: loginInfo);

    IMKitClient.init(appKey, options).then((success) async {
      if (success) {
        bool isDebug = await isDebugModel();
        UnifyLogin.initLoginConfig(
            appKey, 2, 7, !kReleaseMode ? true : isDebug);
        if (loginInfo == null) {
          var state =
              Provider.of<LoginModel>(context, listen: false).loginState;
          if (state == LoginState.init) {
            UnifyLogin.loginWithToken();
          }
          Alog.d(content: "loginInfo is null");
        } else {
          UnifyLogin.loginWithToken();
          Alog.d(content: "login with token");
        }
      } else {
        Alog.d(content: "im init failed");
      }
    }).catchError((e) {
      Alog.d(content: 'im init failed with error ${e.toString()}');
    });
  }
}
