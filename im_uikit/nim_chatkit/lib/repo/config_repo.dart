// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:nim_chatkit/utils/preference_utils.dart';
import 'package:nim_core_v2/nim_core.dart';

class ConfigRepo {
  static const int audioPlayEarpiece = 0;
  static const int audioPlayOutside = 1;

  static const String readStatus = "show_read_status";
  static const String audioPlayMode = "audio_play_mode";
  static const String toggleNotification = "toggle_notification";
  static const String ringToggle = "ring_toggle";
  static const String vibrateToggle = "vibrate_toggle";
  static const String statusConfig = "status_bar_notification_config";
  static const String enableCloudConversation = 'enable_cloud_conversation';

  static const String enableAIStream = 'enable_ai_stream';

  static const String teamApplicationReadTime = 'team_application_read_time';

  static const String uiLanguage = 'uikit_language';

  ///语言设置变更回调
  static final StreamController<String> _languageChangedNotifier =
      StreamController<String>.broadcast();

  static Stream<String> get languageChangedNotifier =>
      _languageChangedNotifier.stream;

  /// 获取语言设置
  static Future<String?> getLanguage() async {
    String? language = await PreferenceUtils.getStringEx(uiLanguage, null);
    if (language != null) {
      _languageChangedNotifier.add(language);
    }
    return language;
  }

  /// 更新语言设置
  static void updateLanguage(String language) {
    _languageChangedNotifier.add(language);
    PreferenceUtils.saveString(uiLanguage, language);
  }

  static Future<bool> getShowReadStatus() async {
    return await PreferenceUtils.getBool(readStatus, true);
  }

  static void updateShowReadStatus(bool show) {
    PreferenceUtils.saveBool(readStatus, show);
  }

  /// 获取是否打开云端会话
  static Future<bool> getEnableCloudConversation() async {
    return await PreferenceUtils.getBool(enableCloudConversation, false);
  }

  /// 设置是否打开云端会话
  static void updateEnableCloudConversations(bool enable) {
    PreferenceUtils.saveBool(enableCloudConversation, enable);
  }

  /// 获取是否打开AI流式输出
  static Future<bool> getEnableAIStream() async {
    return await PreferenceUtils.getBool(enableAIStream, true);
  }

  /// 设置是否打开AI流式输出
  static void updateEnableAIStream(bool enable) {
    PreferenceUtils.saveBool(enableAIStream, enable);
  }

  ///获取群申请的已读回执时间
  static Future<int> getTeamApplicationReadTime() async {
    return await PreferenceUtils.getInt(teamApplicationReadTime, 0);
  }

  ///更新群申请的已读回执时间
  static void updateTeamApplicationReadTime(int time) {
    PreferenceUtils.saveInt(teamApplicationReadTime, time);
  }

  static Future<int> getAudioPlayModel() async {
    return await PreferenceUtils.getInt(audioPlayMode, audioPlayOutside);
  }

  static Future<void> updateAudioPlayMode(int mode) async {
    await PreferenceUtils.saveInt(audioPlayMode, mode);
  }

  static Future<bool> getMixNotification() async {
    final result = await NimCore.instance.settingsService.getDndConfig();
    return result.data?.dndOn == false;
  }

  static Future<bool> updateMixNotification(bool value,
      {bool? showDetail}) async {
    NIMDndConfig config = NIMDndConfig(
        dndOn: !value,
        fromH: 0,
        fromM: 0,
        toH: 23,
        toM: 59,
        showDetail: showDetail);
    final result = await NimCore.instance.settingsService.setDndConfig(config);
    return result.isSuccess;
  }

  static updateMessageNotification(bool value) {
    NimCore.instance.settingsService.enableNotificationAndroid(
        enableRegularNotification: value,
        enableRevokeMessageNotification: value);
  }

  static Future<bool> getRingToggle() async {
    return await PreferenceUtils.getBool(ringToggle, true);
  }

  static void updateRingToggle(bool mode) async {
    PreferenceUtils.saveBool(ringToggle, mode);
    _updateStatusBarNotificationConfigInternal('ring', mode);
  }

  static Future<bool> getVibrateToggle() async {
    return await PreferenceUtils.getBool(vibrateToggle, true);
  }

  static void updateVibrateToggle(bool mode) async {
    PreferenceUtils.saveBool(vibrateToggle, mode);
    _updateStatusBarNotificationConfigInternal('vibrate', mode);
  }

  ///获取不展示详情
  static Future<bool> isPushShowNoDetail() async {
    var res = await NimCore.instance.settingsService.getDndConfig();
    NIMStatusBarNotificationConfig? config =
        await getStatusBarNotificationConfig();
    if (res.isSuccess) {
      return res.data?.showDetail == false && config?.hideContent == true;
    }
    return false;
  }

  static Future<bool> updatePushShowNoDetail(bool mode) async {
    var res = await NimCore.instance.settingsService
        .setDndConfig(NIMDndConfig(showDetail: !mode));
    if (res.isSuccess) {
      _updateStatusBarNotificationConfigInternal('hideContent', mode);
    }
    return res.isSuccess;
  }

  static Future<NIMStatusBarNotificationConfig?>
      getStatusBarNotificationConfig() async {
    String json = await PreferenceUtils.getString(statusConfig, '');
    if (json.isEmpty) {
      return null;
    }
    Map<String, dynamic> map = jsonDecode(json);
    NIMStatusBarNotificationConfig config =
        NIMStatusBarNotificationConfig.fromMap(map);
    return config;
  }

  static saveStatusBarNotificationConfig(NIMStatusBarNotificationConfig config,
      {bool saveToNative = true}) {
    String tmp = jsonEncode(config.toMap());
    PreferenceUtils.saveString(statusConfig, tmp);
    if (saveToNative) {
      NimCore.instance.settingsService.updateNotificationConfigAndroid(config);
    }
  }

  static _updateStatusBarNotificationConfigInternal(
      String key, dynamic value) async {
    NIMStatusBarNotificationConfig? config =
        await getStatusBarNotificationConfig();
    config ??= NIMStatusBarNotificationConfig();
    var tmp = config.toMap();
    tmp[key] = value;
    saveStatusBarNotificationConfig(
        NIMStatusBarNotificationConfig.fromMap(tmp));
  }
}
