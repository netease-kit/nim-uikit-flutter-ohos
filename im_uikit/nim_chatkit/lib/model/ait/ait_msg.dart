// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

///@消息
class AitMsg {
  ///在@消息中展示的文本
  String text;

  List<AitSegment> segments = [];

  AitMsg(this.text);

  void addSegment(int start, int end, {bool broken = false}) {
    segments.add(AitSegment(start, end, broken: broken));
  }

  void removeSegment(int start, int end) {
    segments.removeWhere(
        (element) => element.start == start && element.endIndex == end);
  }

  bool valid() {
    if (segments.isEmpty) {
      return false;
    }
    for (AitSegment segment in segments) {
      if (!segment.broken) {
        return true;
      }
    }
    return false;
  }

  toMap() {
    return {'text': text, 'segments': segments.map((e) => e.toMap()).toList()};
  }

  factory AitMsg.fromMap(Map<String, dynamic> map) {
    return AitMsg(map['text'])
      ..segments = (map['segments'] as List)
          .map((e) => AitSegment.fromMap(Map<String, dynamic>.from(e)))
          .toList();
  }
}

class AitSegment {
  ///@消息的起始位置
  int start;

  ///@消息的结束位置
  int endIndex;

  bool broken;

  AitSegment(this.start, this.endIndex, {this.broken = false});

  toMap() {
    return {'start': start, 'end': endIndex, 'broken': broken};
  }

  factory AitSegment.fromMap(Map<String, dynamic> map) {
    return AitSegment(map['start'], map['end'], broken: map['broken']);
  }
}
