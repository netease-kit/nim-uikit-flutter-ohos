// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import '../repo/text_search.dart';
import 'hit_type.dart';

abstract class SearchInfo {
  RecordHitInfo? hitInfo;
  HitType hitType;

  SearchInfo({this.hitType = HitType.none, this.hitInfo});

  SearchType getType();
}

enum SearchType { contact, normalTeam, advancedTeam }
