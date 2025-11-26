// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:nim_chatkit/model/custom_type_constant.dart';
import 'package:nim_core_v2/nim_core.dart';

class MessageHelper {
  static Map<String, String?>? parseMultiLineMessage(NIMMessage message) {
    if (message.messageType == NIMMessageType.custom &&
        message.attachment?.raw?.isNotEmpty == true) {
      Map<String, dynamic>? data = jsonDecode(message.attachment!.raw!);
      if (data?[CustomMessageKey.type] ==
              CustomMessageType.customMultiLineMessageType &&
          data?[CustomMessageKey.data] is Map) {
        return (data![CustomMessageKey.data] as Map).cast<String, String?>();
      }
    }

    return null;
  }
}

//话单消息定义
class BillMessage {
  static const int voiceBill = 1;

  static const int videoBill = 2;

  //  通话完成：1
  //   通话取消：2
  //   通话拒绝：3
  //   超时未接听：4
  //   对方忙： 5
  static const int callStatusFinished = 1;

  static const int callStatusCancel = 2;

  static const int callStatusRefuse = 3;

  static const int callStatusTimeout = 4;

  static const int callStatusBusy = 5;

  //根据时间返回 hh:mm:ss 格式字符串
  static String getCallDuration(int duration) {
    if (duration < 3600) {
      // 不足一小时，显示分和秒
      int minute = duration ~/ 60;
      int second = duration % 60;
      return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    } else {
      // 超过一小时，显示时、分、秒
      int hour = duration ~/ 3600;
      int minute = (duration % 3600) ~/ 60;
      int second = duration % 60;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
    }
  }
}
