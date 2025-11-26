// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_chatkit/model/contact_info.dart';
import 'package:nim_chatkit/model/search_info.dart';

import '../repo/text_search.dart';
import 'hit_type.dart';

class FriendSearchInfo extends SearchInfo {
  ContactInfo contact;

  FriendSearchInfo(
      {required this.contact,
      HitType hitType = HitType.none,
      RecordHitInfo? hitInfo})
      : super(hitType: hitType, hitInfo: hitInfo);

  @override
  SearchType getType() {
    return SearchType.contact;
  }
}
