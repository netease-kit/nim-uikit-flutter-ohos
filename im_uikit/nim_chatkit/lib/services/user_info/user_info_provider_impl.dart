// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_chatkit/services/user_info/user_info_provider.dart';
import 'package:nim_core_v2/nim_core.dart';

class UserInfoProviderImpl extends UserInfoProvider {
  @override
  Future<NIMResult<void>> updateUserInfo(NIMUserUpdateParam params) {
    return NimCore.instance.userService.updateSelfUserProfile(params);
  }

  @override
  Future<List<NIMUserInfo>?> fetchUserInfo(List<String> accountList) async {
    var res = await NimCore.instance.userService.getUserList(accountList);
    if (res.isSuccess && res.data != null) {
      return res.data;
    }
    return null;
  }
}
