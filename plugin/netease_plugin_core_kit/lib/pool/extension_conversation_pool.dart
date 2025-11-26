// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_plugin_core_kit;

///会话列表消息解析器
typedef ConversationLastTextBuilder = String? Function(
    NIMConversation conversation);

class ExtensionConversationPool {
  static final ExtensionConversationPool _singleton =
      ExtensionConversationPool._();

  factory ExtensionConversationPool() {
    return _singleton;
  }

  ExtensionConversationPool._();

  ///会话列表消息文案
  final List<ConversationLastTextBuilder> _conversationLastTextBuilders = [];

  ///注册会话列表消息文案解析器
  void registerConversationLastTextBuilder(
      ConversationLastTextBuilder builder) {
    _conversationLastTextBuilders.add(builder);
  }

  ///解析会话列表消息文案
  String? buildConversationLastText(NIMConversation conversation) {
    for (var builder in _conversationLastTextBuilders) {
      var text = builder(conversation);
      if (text != null) {
        return text;
      }
    }

    return null;
  }
}
