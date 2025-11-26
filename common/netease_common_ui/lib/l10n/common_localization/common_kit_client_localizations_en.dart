// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'common_kit_client_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CommonKitClientLocalizationsEn extends CommonKitClientLocalizations {
  CommonKitClientLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get networkErrorTip =>
      'The current network is unavailable, please check your network settings.';

  @override
  String get sure => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get permissionRequestTip =>
      'Please add permissions on the settings page';

  @override
  String get webConnectError => 'Web view loading error';

  @override
  String get imagePickerRecent => 'Recent';

  @override
  String get imagePickerCamera => 'Camera';

  @override
  String get imagePickerScreenshots => 'Screenshots';

  @override
  String get permissionCameraTitle => 'The camera is used for';

  @override
  String get permissionCameraContent =>
      'Photo-taking, video records, video calls, ...';

  @override
  String get permissionStorageTitle => 'The storage is used for';

  @override
  String get permissionStorageContent => 'Files, photos, videos, ...';

  @override
  String get permissionSystemCheck =>
      'Failed to get permission. Please go to system settings to grant it.';
}
