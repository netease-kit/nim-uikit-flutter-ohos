// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nim_core_v2/nim_core.dart';

import 'contact_info.dart';

class RecentForward {
  String sessionId;
  NIMConversationType sessionType;
  int time;
  NIMTeam? team;
  ContactInfo? friend;

  RecentForward(this.sessionId, this.sessionType)
      : time = DateTime.now().millisecondsSinceEpoch;

  String getName() {
    if (team != null) {
      return team!.name;
    } else if (friend != null) {
      final n = friend!.getName();
      if (n.isNotEmpty) return n;
    }
    return sessionId;
  }

  String? getAvatar() {
    if (team != null) {
      return team!.avatar;
    } else if (friend != null) {
      return friend!.user.avatar;
    }
    return null;
  }

  int getCount() {
    if (team != null) {
      return team!.memberCount;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'sessionType':
          NIMConversationTypeClass(conversationType: sessionType).toValue(),
      'time': time,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentForward &&
        other.sessionId == sessionId &&
        other.sessionType == sessionType;
  }

  @override
  int get hashCode => Object.hash(sessionId, sessionType);

  static RecentForward? _fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final String id = (json['sessionId'] ?? '').toString();
    final int st = json['sessionType'] is int
        ? json['sessionType'] as int
        : int.tryParse(json['sessionType']?.toString() ?? '') ?? 0;
    final rf = RecentForward(id, NIMConversationTypeClass.fromEnumInt(st));
    final tRaw = json['time'];
    if (tRaw is int) {
      rf.time = tRaw;
    } else {
      rf.time = int.tryParse(tRaw?.toString() ?? '') ??
          DateTime.now().millisecondsSinceEpoch;
    }
    if (rf.sessionId.isEmpty || rf.sessionType == NIMConversationType.unknown) {
      return null;
    }
    return rf;
  }

  static List<Map<String, dynamic>>? toJsonList(
      List<RecentForward>? recentForwards) {
    if (recentForwards == null) return null;
    return recentForwards.map((e) => e.toJson()).toList();
  }

  static List<RecentForward> fromJsonArray(List<dynamic> jsonArray) {
    final List<RecentForward> result = [];
    for (final item in jsonArray) {
      Map<String, dynamic>? obj;
      if (item is Map<String, dynamic>) {
        obj = item;
      } else if (item is Map) {
        obj = Map<String, dynamic>.from(item);
      } else {
        obj = null;
      }
      final rf = _fromJson(obj);
      if (rf != null) {
        result.add(rf);
      }
    }
    return result;
  }
}
