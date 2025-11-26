// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/team/team_provider.dart';
import 'package:nim_chatkit/model/search_info.dart';
import 'package:nim_core_v2/nim_core.dart';

import '../repo/text_search.dart';
import 'hit_type.dart';

class TeamSearchInfo extends SearchInfo {
  NIMTeam team;

  TeamSearchInfo(
      {required this.team,
      HitType hitType = HitType.none,
      RecordHitInfo? hitInfo})
      : super(hitType: hitType, hitInfo: hitInfo);

  @override
  SearchType getType() {
    if (!getIt<TeamProvider>().isGroupTeam(team)) {
      return SearchType.advancedTeam;
    } else {
      return SearchType.normalTeam;
    }
  }
}
