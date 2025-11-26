// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_core_v2/nim_core.dart';

class ContactInfo {
  NIMUserInfo user;
  NIMFriend? friend;

  bool? isInBlack;

  bool isOnline = false;

  ContactInfo(this.user, {this.friend, this.isInBlack});

  String getName({bool needAlias = true}) {
    if (needAlias && friend != null && (friend!.alias?.isNotEmpty == true)) {
      return friend!.alias!;
    } else if (user.name?.isNotEmpty == true) {
      return user.name!;
    } else {
      return user.accountId!;
    }
  }

  @override
  int get hashCode => user.accountId.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ContactInfo) {
      return user.accountId == other.user.accountId;
    }
    return false;
  }
}
