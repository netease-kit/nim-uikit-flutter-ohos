// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_plugin_core_kit;

///消息构建器
typedef MessageBuilder = Widget? Function(
    BuildContext context, NIMMessage message);

///消息类型解析器
typedef MessageTypeDecoder = String? Function(NIMMessage message);

class ExtensionMessageBuilderPool {
  static final ExtensionMessageBuilderPool _singleton =
      ExtensionMessageBuilderPool._();

  factory ExtensionMessageBuilderPool() {
    return _singleton;
  }

  ExtensionMessageBuilderPool._();

  ///预设消息类型解析
  ///没中类型可有多个解析器，按注册顺序依次解析，返回第一个不为空的解析结果
  final Map<NIMMessageType, List<MessageTypeDecoder>> _messageTypeDecoders = {};

  ///注册消息类型解析器
  ///如果该类型的解析器已存在，则添加到解析器列表中
  void registerMessageTypeDecoder(
      NIMMessageType type, MessageTypeDecoder decoder) {
    var decoders = _messageTypeDecoders[type];
    if (decoders == null) {
      decoders = [];
      _messageTypeDecoders[type] = decoders;
    }
    decoders.add(decoder);
  }

  ///解析消息类型
  ///解析得到一个String类型的字段表示类型
  String? decodeMessageType(NIMMessage message) {
    var decoders = _messageTypeDecoders[message.messageType];
    if (decoders?.isNotEmpty == true) {
      for (var decoder in decoders!) {
        var type = decoder(message);
        if (type != null) {
          return type;
        }
      }
    }
    return null;
  }

  ///消息内容构建
  final Map<String, MessageBuilder> _messageContentBuilders = {};

  ///注册消息类容构建扩展
  void registerMessageContentBuilder(String type, MessageBuilder builder) {
    _messageContentBuilders[type] = builder;
  }

  ///构建消息内容，不含头像等信息
  Widget? buildMessageContent(BuildContext context, NIMMessage message) {
    var type = decodeMessageType(message);
    if (type != null) {
      var builder = _messageContentBuilders[type];
      if (builder != null) {
        return builder(context, message);
      }
    }
    return null;
  }

  ///消息完整构建,包含头像等信息
  final Map<String, MessageBuilder> _messageBuilders = {};

  ///注册消息构建方法，包含头像，昵称等信息
  void registerMessageBuilder(String type, MessageBuilder builder) {
    _messageBuilders[type] = builder;
  }

  ///构建完整消息，包含头像，昵称等信息
  Widget? buildMessage(BuildContext context, NIMMessage message) {
    var type = decodeMessageType(message);
    if (type != null) {
      var builder = _messageBuilders[type];
      if (builder != null) {
        return builder(context, message);
      }
    }
    return null;
  }
}
