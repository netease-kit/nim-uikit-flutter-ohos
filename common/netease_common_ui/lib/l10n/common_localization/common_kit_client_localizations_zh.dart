// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'common_kit_client_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class CommonKitClientLocalizationsZh extends CommonKitClientLocalizations {
  CommonKitClientLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get networkErrorTip => '当前网络不可用，请检查你的网络设置。';

  @override
  String get sure => '确认';

  @override
  String get cancel => '取消';

  @override
  String get takePhoto => '拍照';

  @override
  String get choosePhoto => '选择照片';

  @override
  String get permissionRequestTip => '请在设置页面添加权限';

  @override
  String get webConnectError => '网页加载错误';

  @override
  String get imagePickerRecent => '最近';

  @override
  String get imagePickerCamera => '相机';

  @override
  String get imagePickerScreenshots => '截屏';

  @override
  String get permissionCameraTitle => '相机权限使用说明';

  @override
  String get permissionCameraContent => '用户拍照，视频录制， 视频通话等场景';

  @override
  String get permissionStorageTitle => '存储权限使用说明';

  @override
  String get permissionStorageContent => '用户获取文件、图片、视频等场景';

  @override
  String get permissionSystemCheck => '权限获取失败，请前往系统设置页面设置';
}
