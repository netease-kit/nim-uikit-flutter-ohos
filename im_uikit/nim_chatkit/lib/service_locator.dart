// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:get_it/get_it.dart';
import 'package:nim_chatkit/services/contact/contact_provider.dart';
import 'package:nim_chatkit/services/contact/contact_provider_impl.dart';
import 'package:nim_chatkit/services/login/im_login_service.dart';
import 'package:nim_chatkit/services/login/im_login_service_impl.dart';
import 'package:nim_chatkit/services/team/team_provider.dart';
import 'package:nim_chatkit/services/team/team_provider_impl.dart';
import 'package:nim_chatkit/services/user_info/user_info_provider.dart';
import 'package:nim_chatkit/services/user_info/user_info_provider_impl.dart';

final getIt = GetIt.instance;
bool isInitialized = false;

void setupLocator() {
  if (isInitialized) {
    return;
  }
  getIt.registerLazySingleton<UserInfoProvider>(() => UserInfoProviderImpl());
  // getIt.registerLazySingleton<MessageProvider>(() => MessageProviderImpl());
  getIt.registerLazySingleton<ContactProvider>(() => ContactProviderImpl());
  getIt.registerLazySingleton<IMLoginService>(() => IMLoginServiceImpl());
  getIt.registerLazySingleton<TeamProvider>(() => TeamProviderImpl());
  isInitialized = true;
}
