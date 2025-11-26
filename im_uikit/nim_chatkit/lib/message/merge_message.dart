// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

///用于显示合并后的消息的发送方Nick的key
final String mergedMessageNickKey = 'mergedMessageNickKey';

///用于显示合并后的消息的发送方avatar的key
final String mergedMessageAvatarKey = 'mergedMessageAvatarKey';

///合并消息
class MergedMessage {
  static const int defaultMaxDepth = 3;

  ///会话id
  String sessionId;

  ///会话名称
  String sessionName;

  ///合并消息上传NOS后的url
  String url;

  ///合并消息文件的md5
  String? md5;

  ///合并消息的深度
  int? depth;

  ///合并消息的摘要，用于在消息列表展示，默认三条
  List<MergeMessageAbstract> abstracts;

  ///合并消息的id，用于标识合并消息
  ///通[NIMMessage.uuid]获取
  String? messageId;

  MergedMessage(
      {required this.sessionId,
      required this.sessionName,
      required this.url,
      required this.md5,
      required this.depth,
      required this.abstracts});

  factory MergedMessage.fromMap(Map<String, dynamic> map) {
    return MergedMessage(
      sessionId: map['sessionId'],
      sessionName: map['sessionName'],
      url: map['url'],
      md5: map['md5'],
      depth: map['depth'],
      abstracts: (map['abstracts'] as List)
          .map((e) =>
              MergeMessageAbstract.fromMap((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sessionId': this.sessionId,
      'sessionName': this.sessionName,
      'url': this.url,
      'md5': this.md5,
      'depth': this.depth,
      'abstracts': this.abstracts.map((e) => e.toMap()).toList(),
    };
  }
}

///合并转发消息的缩略
class MergeMessageAbstract {
  ///消息展示的nick，只取fromNick，没有就accId
  String senderNick;

  ///内容，不是Text的显示缩略
  String content;

  ///发送方的accId
  String userAccId;

  MergeMessageAbstract(
      {required this.senderNick,
      required this.content,
      required this.userAccId});

  factory MergeMessageAbstract.fromMap(Map<String, dynamic> map) {
    return MergeMessageAbstract(
      senderNick: map['senderNick'],
      content: (map['content'] as String?) ?? '',
      userAccId: map['userAccId'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderNick': this.senderNick,
      'content': this.content,
      'userAccId': this.userAccId,
    };
  }
}

///消息上传后的信息
class MessageUploadInfo {
  String url;
  String md5;

  MessageUploadInfo(this.url, this.md5);
}
