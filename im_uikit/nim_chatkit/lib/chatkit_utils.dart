// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common/netease_common.dart';
import 'package:nim_chatkit/extension.dart';
import 'package:nim_chatkit/im_kit_client.dart';
import 'package:nim_core_v2/nim_core.dart';

class ChatKitUtils {
  static const String CONVERSATION_ID_SPLIT = '|';
  static String getConversationTargetId(String conversationId) {
    if (conversationId.isEmpty) {
      return conversationId;
    }
    final components = conversationId.split(CONVERSATION_ID_SPLIT);
    if (components.length != 3) {
      return conversationId;
    }
    if (components[0].isEmpty || components[2].isEmpty) {
      return conversationId;
    }
    return components[2];
  }

  static String? conversationId(String targetId, NIMConversationType type) {
    // 检查输入参数有效性
    if (targetId.isEmpty) {
      return null;
    }

    // 获取当前用户账号
    String? account = IMKitClient.account();

    // 检查账号有效性
    if (account == null || account.isEmpty) {
      return null;
    }

    // 生成格式化的会话ID
    return '${account}${CONVERSATION_ID_SPLIT}${type.getValue()}${CONVERSATION_ID_SPLIT}${targetId}';
  }
}
