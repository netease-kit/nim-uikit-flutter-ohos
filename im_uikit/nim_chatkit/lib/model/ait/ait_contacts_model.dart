// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'ait_msg.dart';

///@消息数据结构
class AitContactsModel {
  AitContactsModel();

  static const String accountAll = "ait_all";

  final Map<String, AitMsg> _aitBlocks = {};

  get aitBlocks => _aitBlocks;

  void reset() {
    _aitBlocks.clear();
  }

  ///根据删除后的Text 文案，返回删除的文本
  ///[endIndex] 删除的文本的光标所在位置
  ///[length] 删除的文本的长度
  AitMsg? deleteAitUser(String deletedText, int endIndex, int length) {
    //如果deletedText为空，直接返回
    if (deletedText.isEmpty) {
      return null;
    }
    var len = deletedText.length;
    //如果_aitBlocks 总有Value值和deletedText不匹配则返回
    AitMsg? removedBlack;
    for (var aitMsg in _aitBlocks.values) {
      for (var segment in aitMsg.segments) {
        if (endIndex < segment.start) {
          segment.start -= length;
          segment.endIndex -= length;
          continue;
        }
        if (len < segment.endIndex + 1 ||
            deletedText.substring(segment.start, segment.endIndex + 1) !=
                aitMsg.text) {
          removedBlack = AitMsg(aitMsg.text);
          removedBlack.addSegment(segment.start, segment.endIndex);
        }
      }
    }
    if (removedBlack != null) {
      _removeSegment(removedBlack, length);
    }
    return removedBlack;
  }

  ///删除aitMsg中的segment,如果aitMsg中的segment为空，则删除aitMsg
  ///同时处理其他aitMsg中的segment的位置
  ///[deletedLen] 删除的文本的长度，如果为正数则其他后面的前移，如果为负数，则其他不变
  void _removeSegment(AitMsg removedBlack, int deletedLen) {
    //删除aitMsg中的segment,如果aitMsg中的segment为空，则删除aitMsg
    final aitMsg = _aitBlocks.values
        .firstWhere((element) => element.text == removedBlack.text);
    int start = removedBlack.segments[0].start;
    int end = removedBlack.segments[0].endIndex;
    //该段文字的长度，加上删除的长度,因为其在前面已经移了deletedLen位
    int length = end - start + 1 - deletedLen;
    aitMsg.removeSegment(start, end);
    if (aitMsg.segments.isEmpty) {
      _aitBlocks.removeWhere((key, value) => value.text == aitMsg.text);
    }
    if (deletedLen > 0) {
      for (var aitMsg in _aitBlocks.values) {
        for (var segment in aitMsg.segments) {
          if (end <= segment.start) {
            segment.start -= length;
            segment.endIndex -= length;
            continue;
          }
        }
      }
    }
  }

  bool isUserBeAit(String? accId) {
    if (accId == null) {
      return false;
    }
    for (var key in _aitBlocks.keys) {
      if (key == accountAll) {
        return true;
      }
      if (key == accId) {
        return true;
      }
    }
    return false;
  }

  void fork(AitContactsModel aitContactsModel) {
    _aitBlocks.clear();
    _aitBlocks.addAll(aitContactsModel._aitBlocks);
  }

  ///根据插入后的Text 文案, segment 移位或者删除。
  void insertText(String changedText, int endIndex, int length) {
    //如果changedText为空，直接返回
    if (changedText.isEmpty) {
      return;
    }
    //@用户名中间插入文字，则需要删除此用户
    AitMsg? removedBlack;
    int start = endIndex - length;
    //移位或者删除segment
    for (var aitMsg in _aitBlocks.values) {
      for (var segment in aitMsg.segments) {
        if (start <= segment.start) {
          segment.start += length;
          segment.endIndex += length;
          continue;
        }
        if (endIndex > segment.start && endIndex <= segment.endIndex) {
          removedBlack = AitMsg(aitMsg.text);
          removedBlack.addSegment(segment.start, segment.endIndex);
          continue;
        }
      }
    }
    if (removedBlack != null) {
      _removeSegment(removedBlack, -1);
    }
  }

  void addAitMember(String account, String name, int start) {
    for (var aitMsg in _aitBlocks.values) {
      for (var segment in aitMsg.segments) {
        if (start <= segment.start) {
          segment.start += name.length;
          segment.endIndex += name.length;
          continue;
        }
      }
    }
    AitMsg? aitBlock = _aitBlocks[account];
    if (aitBlock == null) {
      aitBlock = AitMsg(name);
      _aitBlocks[account] = aitBlock;
    }
    int end = start + name.length - 1;
    aitBlock.addSegment(start, end);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    _aitBlocks.forEach((key, value) {
      map[key] = value.toMap();
    });
    return map;
  }

  factory AitContactsModel.fromMap(Map<String, dynamic> map) {
    var model = AitContactsModel();
    map.forEach((key, value) {
      model._aitBlocks[key] = AitMsg.fromMap(Map<String, dynamic>.from(value));
    });
    return model;
  }
}
