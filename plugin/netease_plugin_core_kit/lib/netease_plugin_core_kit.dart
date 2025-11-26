// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library netease_plugin_core_kit;

import 'package:flutter/cupertino.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

part 'model/clickable_item.dart';
part 'model/plugin_attachment.dart';
part 'pool/extension_conversation_pool.dart';
part 'pool/extension_item_pool.dart';
part 'pool/extension_message_builder_pool.dart';

class NimPluginCoreKit {
  ///插件入口注册池
  final ExtensionItemPool itemPool = ExtensionItemPool();

  ///插件Message 解析和构建方法注册池
  final ExtensionMessageBuilderPool messageBuilderPool =
      ExtensionMessageBuilderPool();

  ///会话列表消息构建池
  final ExtensionConversationPool conversationPool =
      ExtensionConversationPool();

  NimPluginCoreKit._();

  static final NimPluginCoreKit _instance = NimPluginCoreKit._();

  factory NimPluginCoreKit() => _instance;
}
