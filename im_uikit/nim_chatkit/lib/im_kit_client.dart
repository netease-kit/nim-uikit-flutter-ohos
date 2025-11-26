// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:netease_corekit/report/xkit_report.dart';
import 'package:nim_chatkit/repo/config_repo.dart';
import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/contact/contact_provider.dart';
import 'package:nim_chatkit/services/login/im_login_service.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:path_provider/path_provider.dart';

import 'im_kit_config_center.dart';
import 'manager/subscription_manager.dart';

class IMKitClient {
  /// 是否开启Ait功能
  static bool enableAit = true;

  /// 是否开启Pin功能
  static bool enablePin = true;

  /// AI 数字人开关
  static bool enableAi = true;

  ///换行消息开关
  static bool enableRichTextMessage = true;

  static bool? _enableCloudConversation;

  /// 设置是否打开云端会话
  /// 在本身没有UI开关的情况下，可以在初始化前调用此方法设置
  static void setEnableCloudConversation(bool enable) {
    _enableCloudConversation = enable;
    return ConfigRepo.updateEnableCloudConversations(enable);
  }

  static Future<bool> get enableCloudConversation async {
    if (_enableCloudConversation != null) {
      return _enableCloudConversation!;
    } else {
      _enableCloudConversation = await ConfigRepo.getEnableCloudConversation();
      return _enableCloudConversation!;
    }
  }

  ///同步返回的会话是否开启云端会话
  static bool? isEnableCloudConversation() {
    return _enableCloudConversation;
  }

  static bool? _enableAIStream;

  /// 设置是否打开AI 流式输出
  /// 在本身没有UI开关的情况下，可以在初始化前调用此方法设置
  static void setEnableAIStream(bool enable) {
    _enableAIStream = enable;
    return ConfigRepo.updateEnableAIStream(enable);
  }

  /// 是否打开AI流式
  static Future<bool> get enableAIStream async {
    if (_enableAIStream != null) {
      return _enableAIStream!;
    } else {
      _enableAIStream = await ConfigRepo.getEnableAIStream();
      return _enableAIStream!;
    }
  }

  ///同步返回的是否支持AI流式输出
  static bool? isEnableAiStream() {
    return _enableAIStream;
  }

  static List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  static Future<bool> init(String appKey, [NIMSDKOptions? options]) async {
    XKitReporter().init(appKey: appKey, imVersion: NimCore.versionName);
    setupLocator();
    late NIMSDKOptions op;
    if (options == null) {
      final enableV2CloudConversation = await enableCloudConversation;
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        op = NIMAndroidSDKOptions(
          appKey: appKey,
          shouldSyncStickTopSessionInfos: true,
          enableTeamMessageReadReceipt: true,
          enableFcs: false,
          enableV2CloudConversation: enableV2CloudConversation,
          sdkRootDir: directory != null ? '${directory.path}/NIMFlutter' : null,
          enablePreloadMessageAttachment: true,
        );
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        op = NIMIOSSDKOptions(
          appKey: appKey,
          shouldSyncStickTopSessionInfos: true,
          enableTeamMessageReadReceipt: true,
          sdkRootDir: '${directory.path}/NIMFlutter',
          apnsCername: 'ENTERPRISE',
          pkCername: 'DEMO_PUSH_KIT',
          enableV2CloudConversation: enableV2CloudConversation,
          enablePreloadMessageAttachment: true,
        );
      }
    } else {
      op = options;
    }

    var initResult = NimCore.instance.isInitialized;
    if (!initResult) {
      var nimInitResult = await NimCore.instance.initialize(op);
      initResult = nimInitResult.isSuccess;
    }
    return initResult;
  }

  ///登录IM
  @Deprecated('请使用loginIMWithResult')
  static Future<bool> loginIM(String accountId, String token,
      {NIMLoginOption? option}) async {
    //初始化在线状态监听
    if (IMKitConfigCenter.enableOnlineStatus) {
      SubscriptionManager.instance.init();
    }
    //初始化联系人全局缓存
    getIt<ContactProvider>().init();
    return (await getIt<IMLoginService>()
            .loginIM(accountId, token, option: option))
        .isSuccess;
  }

  ///登录IM,并返回登录结果，包含错误码
  static Future<NIMResult<void>> loginIMWithResult(
      String accountId, String token,
      {NIMLoginOption? option}) async {
    //初始化在线状态监听
    if (IMKitConfigCenter.enableOnlineStatus) {
      SubscriptionManager.instance.init();
    }
    //初始化联系人全局缓存
    getIt<ContactProvider>().init();
    return (await getIt<IMLoginService>()
        .loginIM(accountId, token, option: option));
  }

  static Future<bool> logoutIM() async {
    if (IMKitConfigCenter.enableOnlineStatus) {
      await SubscriptionManager.instance.unsubscribeAll();
    }
    return getIt<IMLoginService>().logoutIM().then((result) {
      if (result.isSuccess) {
        getIt<ContactProvider>().cleanCache();
        getIt<ContactProvider>().removeListeners();
      }
      return result.isSuccess;
    });
  }

  static String? account() {
    return getIt<IMLoginService>().userInfo?.accountId;
  }

  static NIMUserInfo? getUserInfo() {
    return getIt<IMLoginService>().userInfo;
  }
}
