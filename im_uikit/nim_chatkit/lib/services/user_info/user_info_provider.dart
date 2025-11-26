// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_core_v2/nim_core.dart';

abstract class UserInfoProvider {
  Future<NIMResult<void>> updateUserInfo(NIMUserUpdateParam params);

  /// 根据accountId,远程拉取用户信息
  Future<List<NIMUserInfo>?> fetchUserInfo(List<String> accountList);
}
