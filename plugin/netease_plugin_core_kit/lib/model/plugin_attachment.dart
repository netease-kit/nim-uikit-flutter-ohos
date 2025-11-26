// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_plugin_core_kit;

///插件Attachment
class PluginAttachment {
  ///自定义消息类型——插件
  static const String busTypeKey = 'type';

  static const int pluginMessageType = 301;

  ///插件的消息类型，固定的值
  final int type = pluginMessageType;

  ///插件数据
  PluginData? data;

  PluginAttachment({this.data});

  factory PluginAttachment.fromMap(Map<String, dynamic> map) {
    if (map['data'] is Map) {
      return PluginAttachment(
        data: PluginData.fromMap((map['data'] as Map).cast<String, dynamic>()),
      );
    } else {
      return PluginAttachment();
    }
  }

  ///获取插件的类型
  String? getPluginType() {
    return data?.plugin;
  }

  toMap() {
    return {'type': type, 'data': data?.toMap()};
  }
}

class PluginData {
  String? plugin;
  String? eventType;
  Map<String, dynamic>? event;

  PluginData({this.plugin, this.event, this.eventType});

  factory PluginData.fromMap(Map<String, dynamic> map) {
    return PluginData(
        plugin: map['plugin'],
        eventType: map['eventType'],
        event: (map['event'] as Map?)?.cast<String, dynamic>());
  }

  toMap() {
    return {'plugin': plugin, 'eventType': eventType, 'event': event};
  }
}
