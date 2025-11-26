// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'common_kit_client_localizations_en.dart';
import 'common_kit_client_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of CommonKitClientLocalizations
/// returned by `CommonKitClientLocalizations.of(context)`.
///
/// Applications need to include `CommonKitClientLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'common_localization/common_kit_client_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: CommonKitClientLocalizations.localizationsDelegates,
///   supportedLocales: CommonKitClientLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the CommonKitClientLocalizations.supportedLocales
/// property.
abstract class CommonKitClientLocalizations {
  CommonKitClientLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static CommonKitClientLocalizations? of(BuildContext context) {
    return Localizations.of<CommonKitClientLocalizations>(
        context, CommonKitClientLocalizations);
  }

  static const LocalizationsDelegate<CommonKitClientLocalizations> delegate =
      _CommonKitClientLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @networkErrorTip.
  ///
  /// In en, this message translates to:
  /// **'The current network is unavailable, please check your network settings.'**
  String get networkErrorTip;

  /// No description provided for @sure.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get sure;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @permissionRequestTip.
  ///
  /// In en, this message translates to:
  /// **'Please add permissions on the settings page'**
  String get permissionRequestTip;

  /// No description provided for @webConnectError.
  ///
  /// In en, this message translates to:
  /// **'Web view loading error'**
  String get webConnectError;

  /// No description provided for @imagePickerRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get imagePickerRecent;

  /// No description provided for @imagePickerCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get imagePickerCamera;

  /// No description provided for @imagePickerScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get imagePickerScreenshots;

  /// No description provided for @permissionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'The camera is used for'**
  String get permissionCameraTitle;

  /// No description provided for @permissionCameraContent.
  ///
  /// In en, this message translates to:
  /// **'Photo-taking, video records, video calls, ...'**
  String get permissionCameraContent;

  /// No description provided for @permissionStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'The storage is used for'**
  String get permissionStorageTitle;

  /// No description provided for @permissionStorageContent.
  ///
  /// In en, this message translates to:
  /// **'Files, photos, videos, ...'**
  String get permissionStorageContent;

  /// No description provided for @permissionSystemCheck.
  ///
  /// In en, this message translates to:
  /// **'Failed to get permission. Please go to system settings to grant it.'**
  String get permissionSystemCheck;
}

class _CommonKitClientLocalizationsDelegate
    extends LocalizationsDelegate<CommonKitClientLocalizations> {
  const _CommonKitClientLocalizationsDelegate();

  @override
  Future<CommonKitClientLocalizations> load(Locale locale) {
    return SynchronousFuture<CommonKitClientLocalizations>(
        lookupCommonKitClientLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_CommonKitClientLocalizationsDelegate old) => false;
}

CommonKitClientLocalizations lookupCommonKitClientLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return CommonKitClientLocalizationsEn();
    case 'zh':
      return CommonKitClientLocalizationsZh();
  }

  throw FlutterError(
      'CommonKitClientLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
