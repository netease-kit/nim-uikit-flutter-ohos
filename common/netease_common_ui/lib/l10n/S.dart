// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netease_common_ui/l10n/common_localization/common_kit_client_localizations_en.dart';
import '../base/default_language.dart';
import 'common_localization/common_kit_client_localizations.dart';
import 'common_localization/common_kit_client_localizations_zh.dart';

class S {
  static const LocalizationsDelegate<CommonKitClientLocalizations> delegate =
      CommonKitClientLocalizations.delegate;

  static CommonKitClientLocalizations of([BuildContext? context]) {
    CommonKitClientLocalizations? localizations;
    if (CommonUIDefaultLanguage.commonDefaultLanguage == languageZh) {
      return CommonKitClientLocalizationsZh();
    }
    if (CommonUIDefaultLanguage.commonDefaultLanguage == languageEn) {
      return CommonKitClientLocalizationsEn();
    }
    if (context != null) {
      localizations = CommonKitClientLocalizations.of(context);
    }
    if (localizations == null) {
      var local = PlatformDispatcher.instance.locale;
      try {
        localizations = lookupCommonKitClientLocalizations(local);
      } catch (e) {
        localizations = CommonKitClientLocalizationsEn();
      }
    }
    return localizations;
  }
}
