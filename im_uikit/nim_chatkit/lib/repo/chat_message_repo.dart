// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:netease_common/netease_common.dart';
import 'package:nim_chatkit/im_kit_client.dart';
import 'package:nim_chatkit/model/contact_info.dart';
import 'package:nim_chatkit/repo/config_repo.dart';
import 'package:nim_chatkit/repo/contact_repo.dart';
import 'package:nim_chatkit/repo/team_repo.dart';
import 'package:nim_chatkit/service_locator.dart';
import 'package:nim_chatkit/services/contact/contact_provider.dart';
import 'package:nim_chatkit/services/message/chat_message.dart';
import 'package:nim_chatkit/services/message/nim_chat_cache.dart';
import 'package:nim_chatkit/extension.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:path_provider/path_provider.dart';

import '../chatkit_utils.dart';
import '../manager/ai_user_manager.dart';
import '../message/merge_message.dart';
import '../model/recent_forward.dart';
import '../utils/preference_utils.dart';
import 'conversation_repo.dart';

class ChatMessageRepo {
  ///黑名单错误码
  static const int errorInBlackList = 102426;

  ///PIN消息限制错误码
  static const int errorPINLimited = 107319;

  static const int errorRevokeTimeout = 107314;

  static const int errorDownloadHaveExit = 191007;

  static const String mergeFileName = 'multiForward';

  static const String recentForwardSPKey = "recent_forward";

  static const int maxRecentForward = 5;

  /// 设置当前聊天的账号
  static setChattingAccount(
      String? account, NIMConversationType sessionType, String conversationId) {
    NIMChatCache.instance.setCurrentChatSession(
        ChatSession(account, sessionType, conversationId));
    ConversationRepo.clearSessionUnreadCount(conversationId);
    ConversationRepo.setCurrentConversation(conversationId);
  }

  ///请求群组信息
  static Future<NIMResult<NIMTeam>> queryTeam(String teamId) {
    return NimCore.instance.teamService
        .getTeamInfo(teamId, NIMTeamType.typeNormal);
  }

  ///回复消息
  static Future<NIMResult<void>> replyMessage(
      {required NIMMessage msg,
      required NIMMessage replyMsg,
      NIMSendMessageParams? params}) {
    return NimCore.instance.messageService
        .replyMessage(message: msg, replyMessage: replyMsg, params: params);
  }

  //获取点对点消息的已读回执时间戳
  static Future<NIMResult<NIMP2PMessageReadReceipt>> getP2PMessageReceipt(
      String conversationId) {
    return NimCore.instance.messageService
        .getP2PMessageReceipt(conversationId: conversationId);
  }

  ///发送消息
  static Future<NIMResult<NIMSendMessageResult>> sendMessage(
      {required NIMMessage message,
      required String conversationId,
      NIMSendMessageParams? params}) {
    return NimCore.instance.messageService.sendMessage(
        message: message, conversationId: conversationId, params: params);
  }

  ///插入Tips消息
  ///支持设置extension
  static void insertLocalTipsMessageWithExt(
      String conversationId, String text, Map<String, dynamic> map,
      {int? time}) async {
    var res = await MessageCreator.createTipsMessage(text);
    if (res.isSuccess && res.data != null) {
      NIMMessage msg = res.data!;
      msg.serverExtension = jsonEncode(map);
      NimCore.instance.messageService.insertMessageToLocal(
          message: res.data!, conversationId: conversationId, createTime: time);
    }
  }

  ///插入文本消息
  static void insertLocalTextMessage(String conversationId, String text,
      {String? senderId, int? createTime}) async {
    var res = await MessageCreator.createTextMessage(text);
    if (res.isSuccess && res.data != null) {
      NIMMessage msg = res.data!;
      NimCore.instance.messageService.insertMessageToLocal(
          message: msg,
          conversationId: conversationId,
          senderId: senderId,
          createTime: createTime);
    }
  }

  ///发送文本消息
  ///自动设置是否需要已读回执
  static Future<NIMResult<NIMSendMessageResult>> sendTextMessageWithMessageAck(
      {required String conversationId, required String text}) async {
    //处理AI Config
    NIMMessageAIConfigParams? aiConfigParams;

    if ((await ConversationIdUtil().conversationType(conversationId)).data ==
        NIMConversationType.p2p) {
      NIMAIUser? aiAgent = AIUserManager.instance
          .getAIUserById(ChatKitUtils.getConversationTargetId(conversationId));
      if (aiAgent != null) {
        final aiStreamMode = await IMKitClient.enableAIStream;
        // AI 参数处理
        aiConfigParams = NIMMessageAIConfigParams(
            accountId: aiAgent.accountId, aiStream: aiStreamMode);
        NIMAIModelCallContent content =
            NIMAIModelCallContent(type: 0, msg: text);
        aiConfigParams.content = content;
      }
    }
    var msgBuilder = await MessageCreator.createTextMessage(text);
    if (msgBuilder.isSuccess && msgBuilder.data != null) {
      final readEnable = await ConfigRepo.getShowReadStatus();
      var params = NIMSendMessageParams(
          messageConfig: NIMMessageConfig(readReceiptEnabled: readEnable));
      params.aiConfig = aiConfigParams;
      return sendMessage(
          message: msgBuilder.data!,
          conversationId: conversationId,
          params: params);
    } else {
      return NIMResult.failure(message: msgBuilder.errorDetails);
    }
  }

  ///收藏消息
  static Future<NIMResult<NIMCollection>> collectMessage(NIMMessage message) {
    var data = message.text;
    if (message.attachment is NIMMessageFileAttachment) {
      data = (message.attachment as NIMMessageFileAttachment).url!;
    }
    var type = message.messageType?.getValue();
    var params = NIMAddCollectionParams(
        collectionType: type,
        collectionData: data,
        uniqueId: '${message.messageServerId}');
    return NimCore.instance.messageService.addCollection(params: params);
  }

  ///删除消息,远程删除
  static Future<NIMResult<void>> deleteMessage(NIMMessage anchor,
      {String? ext}) {
    return NimCore.instance.messageService.deleteMessage(
        message: anchor, serverExtension: ext, onlyDeleteLocal: false);
  }

  ///批量删除消息,远程删除
  static Future<NIMResult<void>> deleteMessageList(List<NIMMessage> messages,
      {String? ext}) {
    return NimCore.instance.messageService.deleteMessages(
        messages: messages, serverExtension: ext, onlyDeleteLocal: false);
  }

  ///删除消息,本地删除
  static Future<void> deleteLocalMessage(NIMMessage anchor, {String? ext}) {
    return NimCore.instance.messageService.deleteMessage(
        message: anchor, serverExtension: ext, onlyDeleteLocal: true);
  }

  ///批量删除消息,本地删除
  ///[messages] 消息列表
  static Future<void> deleteLocalMessageList(List<NIMMessage> messages,
      {String? ext}) {
    return NimCore.instance.messageService.deleteMessages(
        messages: messages, serverExtension: ext, onlyDeleteLocal: true);
  }

  ///撤回消息
  static Future<NIMResult<void>> revokeMessage(NIMMessage message,
      {NIMMessageRevokeParams? revokeParams}) {
    return NimCore.instance.messageService
        .revokeMessage(message: message, revokeParams: revokeParams);
  }

  ///设置群聊中消息为已读状态
  static Future<NIMResult<void>> markTeamMessageRead(
      List<NIMMessage> messages) {
    return NimCore.instance.messageService
        .sendTeamMessageReceipts(messages: messages);
  }

  ///下载消息附件
  static Future<NIMResult<String>> downloadAttachment(
      NIMDownloadMessageAttachmentParams params) {
    return NimCore.instance.storageService.downloadAttachment(params);
  }

  ///设置单聊中消息为已读状态
  static Future<NIMResult<void>> markP2PMessageRead(
      {required NIMMessage message}) {
    return NimCore.instance.messageService
        .sendP2PMessageReceipt(message: message);
  }

  ///获取好友信息
  static Future<NIMResult<List<NIMFriend>>> getFriendInfo(List<String> accIds) {
    return NimCore.instance.friendService.getFriendByIds(accIds);
  }

  /// 消息转发
  static Future<NIMResult<void>> forwardMessage(
      NIMMessage message, String conversationId,
      {NIMSendMessageParams? params}) async {
    var forwardMessage =
        (await MessageCreator.createForwardMessage(message)).data;
    if (forwardMessage == null) {
      return NIMResult.failure(message: 'createForwardMessage error');
    }

    Map<String, dynamic>? extensionMap = null;
    if (forwardMessage.serverExtension?.isNotEmpty == true) {
      extensionMap = jsonDecode(forwardMessage.serverExtension!);
    }
    //删除回复
    extensionMap?.remove(ChatMessage.keyReplyMsgKey);
    //删除@信息
    extensionMap?.remove(ChatMessage.keyAitMsg);

    if (extensionMap != null) {
      forwardMessage.serverExtension = jsonEncode(extensionMap);
    } else {
      forwardMessage.serverExtension = null;
    }

    return sendMessage(
        message: forwardMessage,
        conversationId: conversationId,
        params: params);
  }

  ///本地保存tip 消息
  ///不计入未读数
  static void saveTipsMessage(String conversationId, String content) {
    MessageCreator.createTipsMessage(content).then((result) {
      if (result.isSuccess && result.data != null) {
        var message = result.data!;
        message.messageConfig = NIMMessageConfig(unreadEnabled: false);
        NimCore.instance.messageService.insertMessageToLocal(
            message: message,
            conversationId: conversationId,
            createTime: message.createTime);
      }
    });
  }

  ///pin一条消息
  static Future<NIMResult<void>> addMessagePin(NIMMessage message,
      {String? ext}) {
    return NimCore.instance.messageService
        .pinMessage(message: message, serverExtension: ext);
  }

  ///停止流式输出
  static Future<NIMResult<void>> stopAIStreamMessage(
      NIMMessage message, NIMMessageAIStreamStopParams params) {
    return NimCore.instance.messageService.stopAIStreamMessage(message, params);
  }

  ///重新生成AI消息
  static Future<NIMResult<void>> regenAIMessage(
      NIMMessage message, NIMMessageAIRegenParams params) {
    return NimCore.instance.messageService.regenAIMessage(message, params);
  }

  ///移除pin消息
  static Future<NIMResult<void>> removeMessagePin(NIMMessage message,
      {String? ext}) {
    var messageRefer = NIMMessageRefer(
        senderId: message.senderId,
        conversationId: message.conversationId,
        receiverId: message.receiverId,
        messageClientId: message.messageClientId,
        messageServerId: message.messageServerId,
        conversationType: message.conversationType,
        createTime: message.createTime);
    return NimCore.instance.messageService
        .unpinMessage(messageRefer: messageRefer, serverExtension: ext);
  }

  /// 清除设置的当前聊天账号信息
  /// @param [sessionId] 聊天对象id
  /// @param [sessionType] 聊天对象类型
  static clearChattingAccountWithId(String? sessionId,
      NIMConversationType conversationType, String conversationId) {
    NIMChatCache.instance
        .clearCurrentChatSession(sessionId, conversationType, conversationId);
    ConversationRepo.clearSessionUnreadCount(conversationId);
    ConversationRepo.setCurrentConversation('');
  }

  static Future<NIMResult<List<ChatMessage>>> getMessageList(
      NIMMessageListOption option,
      {bool enablePin = true,
      bool addUserInfo = true}) async {
    var msgRes =
        await NimCore.instance.messageService.getMessageList(option: option);
    if (msgRes.isSuccess && msgRes.data != null) {
      List<ChatMessage> result;
      if (addUserInfo) {
        result = await fillUserInfo(msgRes.data!);
      } else {
        result = msgRes.data!.map((e) => ChatMessage(e)).toList();
      }

      if (enablePin) {
        result = _fillPin(result);
      }
      return NIMResult(msgRes.code, result, msgRes.errorDetails);
    } else {
      return NIMResult(msgRes.code, null, msgRes.errorDetails);
    }
  }

  /// 查询历史消息，从远端查询
  static Future<NIMResult<List<ChatMessage>>> fetchHistoryMessage(
      NIMMessageSearchParams params) async {
    var res = await NimCore.instance.messageService
        .searchCloudMessages(params: params);
    if (res.isSuccess && res.data != null) {
      var result = await fillUserInfo(res.data!);
      result = _fillPin(result);
      return NIMResult(res.code, result, res.errorDetails);
    }
    return NIMResult(res.code, null, res.errorDetails);
  }

  ///为每条消息添加用户信息
  static Future<List<ChatMessage>> fillUserInfo(List<NIMMessage> list) async {
    List<ChatMessage> result = [];
    for (var element in list) {
      ChatMessage message = ChatMessage(element);
      var contact = await getIt<ContactProvider>()
          .getContact(element.senderId!, needFriend: false);
      message.fromUser = contact?.user;
      result.add(message);
    }
    return result;
  }

  static List<ChatMessage> _fillPin(List<ChatMessage> list) {
    List<NIMMessagePin> pinRes = NIMChatCache.instance.pinnedMessages;
    if (pinRes.isNotEmpty) {
      var pinList = pinRes;
      for (var msg in list) {
        msg.pinOption = pinList
            .firstWhereOrNull((pin) => _isSameMessage(msg.nimMessage, pin));
      }
    }
    return list;
  }

  static bool _isSameMessage(NIMMessage nimMessage, NIMMessagePin messagePin) {
    if (nimMessage.messageServerId != null &&
        nimMessage.messageServerId != '-1' &&
        messagePin.messageRefer?.messageServerId != null &&
        messagePin.messageRefer?.messageServerId != '-1') {
      return nimMessage.messageServerId ==
          messagePin.messageRefer?.messageServerId;
    } else {
      return nimMessage.messageClientId ==
          messagePin.messageRefer?.messageClientId;
    }
  }

  ///是否打开消息提醒
  static Future<bool> isNeedNotify(String accId) async {
    final muteMode =
        await NimCore.instance.settingsService.getP2PMessageMuteMode(accId);
    return muteMode.data == NIMP2PMessageMuteMode.p2pMessageMuteModeOff;
  }

  ///设置账号的消息提醒状态
  static Future<NIMResult<void>> setNotify(String accId, bool notify) {
    return NimCore.instance.settingsService.setP2PMessageMuteMode(
        accId,
        notify
            ? NIMP2PMessageMuteMode.p2pMessageMuteModeOff
            : NIMP2PMessageMuteMode.p2pMessageMuteModeOn);
  }

  ///根据关键字搜索消息
  static Future<List<ChatMessage>?> searchMessage(String keyWord,
      String sessionId, NIMConversationType conversationType) async {
    NIMMessageSearchParams params = NIMMessageSearchParams(
        keyword: keyWord, sortOrder: NIMSortOrder.sortOrderDesc);

    if (conversationType == NIMConversationType.team) {
      params.teamIds = [sessionId];
    } else if (conversationType == NIMConversationType.p2p) {
      params.p2pAccountIds = [sessionId];
    }
    var res = await NimCore.instance.messageService
        .searchCloudMessages(params: params);
    if (res.isSuccess && res.data != null) {
      List<ChatMessage> tmp = await fillUserInfo(res.data!);
      return tmp.toList();
    }
    return null;
  }

  ///(群消息发送方)查询单条群组消息已读、未读账号列表
  static Future<NIMTeamMessageReadReceiptDetail?> fetchTeamMessageReceiptDetail(
      NIMMessage message) {
    return NimCore.instance.messageService
        .getTeamMessageReceiptDetail(message: message)
        .then((value) => value.data);
  }

  ///发送自定义通知
  static Future<NIMResult<void>> sendCustomNotification(String conversationId,
      String content, NIMSendCustomNotificationParams params) {
    return NimCore.instance.notificationService
        .sendCustomNotification(conversationId, content, params);
  }

  ///获取Pin 的消息列表
  static Future<NIMResult<List<ChatMessage>>> fetchPinMessage(
      String conversationId) {
    return NimCore.instance.messageService
        .getPinnedMessageList(conversationId: conversationId)
        .then((value) async {
      if (value.isSuccess && value.data != null) {
        var pinList = value.data!;
        var messageRefers = pinList.map((e) => e.messageRefer!).toList();
        var msgRes = await NimCore.instance.messageService
            .getMessageListByRefers(messageRefers: messageRefers);
        if (msgRes.isSuccess && msgRes.data != null) {
          List<ChatMessage> msgList =
              msgRes.data!.map((e) => ChatMessage(e)).toList();
          for (var msg in msgList) {
            msg.pinOption = pinList
                .firstWhereOrNull((pin) => _isSameMessage(msg.nimMessage, pin));
          }
          return NIMResult(msgRes.code, msgList, msgRes.errorDetails);
        } else {
          return NIMResult(msgRes.code, null, msgRes.errorDetails);
        }
      }
      return NIMResult(value.code, null, value.errorDetails);
    });
  }

  ///获取合并转发消息中的消息列表
  static Future<NIMResult<List<NIMMessage>>> getMessagesFromMergedMessage(
      MergedMessage mergedMsg) async {
    var directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getTemporaryDirectory();
    }
    if (directory == null) {
      return NIMResult.failure(message: 'directory is null');
    }
    final fileName = '$mergeFileName${mergedMsg.messageId}';
    final filePath = '${directory.path}/$fileName';
    //先下载文件
    final downloadRes = await NimCore.instance.storageService
        .downloadFile(mergedMsg.url, filePath);
    if (downloadRes.isSuccess || downloadRes.code == errorDownloadHaveExit) {
      //读取文件
      final file = File(filePath);
      if (file.existsSync()) {
        //校验md5
        var fileMd5 = await file.md5;
        if (fileMd5 != mergedMsg.md5) {
          return NIMResult.failure(message: 'file md5 not match');
        }
        //读取文件内容
        final List<int> fileStream = file.readAsBytesSync();
        final fileContent = utf8.decode(fileStream);
        final lines = fileContent.split('\n');
        List<NIMMessage> messages = List.empty(growable: true);
        if (lines.length > 1) {
          for (int i = 1; i < lines.length; i++) {
            // 反序列化
            final msg = await NimCore.instance.messageService
                .messageDeserialization(lines[i]);
            if (msg.isSuccess && msg.data != null) {
              messages.add(msg.data!);
            }
          }
          return NIMResult.success(data: messages);
        } else {
          return NIMResult.failure(message: 'file is empty');
        }
      } else {
        return NIMResult.failure(message: 'file not exist');
      }
    } else {
      return NIMResult.failure(message: downloadRes.errorDetails);
    }
  }

  ///合并并上传消息，返回上传后的url和md5
  static Future<NIMResult<MessageUploadInfo>> uploadMergedMessageFile(
      List<NIMMessage> messages) async {
    final mergeMsg = await createForwardMessageListFileDetail(messages);
    if (mergeMsg.isSuccess && mergeMsg.data != null) {
      final List<int> fileBytes = utf8.encode(mergeMsg.data!);
      String fileName =
          "$mergeFileName${DateTime.now().millisecondsSinceEpoch}";
      var directory;
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getExternalStorageDirectory();
      }
      if (directory == null) {
        return NIMResult.failure(message: 'directory is null');
      }
      File file;
      try {
        file = File('${directory.path}/$fileName');
        file.writeAsBytesSync(fileBytes);
      } catch (e) {
        return NIMResult.failure(message: 'create file error ${e.toString()}');
      }
      final uploadTask = await NimCore.instance.storageService
          .createUploadFileTask(NIMUploadFileParams(filePath: file.path));
      if (uploadTask.data == null) {
        return NIMResult.failure(message: 'create task failed');
      }
      final uploadRes =
          await NimCore.instance.storageService.uploadFile(uploadTask.data!);
      if (uploadRes.isSuccess && uploadRes.data != null) {
        try {
          final md5 = await file.md5;
          file.delete();
          return NIMResult.success(
              data: MessageUploadInfo(uploadRes.data!, md5));
        } catch (exception) {
          return NIMResult.failure(
              message: 'get md5 error ${exception.toString()}');
        }
      } else {
        return NIMResult.failure(message: uploadRes.errorDetails);
      }
    } else {
      return NIMResult.failure(message: mergeMsg.errorDetails);
    }
  }

  static Future<NIMResult<String>> createForwardMessageListFileDetail(
      List<NIMMessage> messages) async {
    if (messages.isEmpty) {
      return NIMResult.failure(message: 'message is empty');
    }
    var sessionId = messages.first.conversationId;
    if (sessionId == null) {
      return NIMResult.failure(message: 'sessionId is null');
    }
    var forwardMsgList = messages.where((msg) {
      //不是来自同一会话，不添加
      //不是可以转发的类型，不添加,通知，语音，话单，机器人等不可转发
      return msg.conversationId == sessionId &&
          (msg.messageType != NIMMessageType.notification &&
              msg.messageType != NIMMessageType.avChat &&
              msg.messageType != NIMMessageType.robot);
    }).toList();
    String header = _buildHeader(0, forwardMsgList.length);
    var bodyResult = await _buildBody(forwardMsgList);
    if (bodyResult.isSuccess) {
      return NIMResult.success(data: '$header\n${bodyResult.data}');
    } else {
      return NIMResult.failure(message: bodyResult.errorDetails);
    }
  }

  ///创建文件头部，里面的数据都是可以自己选择添加的
  ///占一行
  ///[version]代表功能版本
  ///[messageCount] 转发消息数量，可用于展示
  static String _buildHeader(int version, int messageCount) {
    return json.encode(<String, dynamic>{
      'version': 0,
      'terminal': 3,
      'message_count': messageCount
    });
  }

  ///把需要进行上传的数据 按照约定的“数据字段字典”转换后的json格式字符串，每条记录一行，存储在文本文件中，
  ///并从第二行开始存储(因为第一行存的是head信息)
  static Future<NIMResult<String>> _buildBody(List<NIMMessage> messages) async {
    String enter = '\n';
    if (messages.isEmpty) {
      return NIMResult.failure(message: 'messages is empty');
    }
    final stringBuilder = StringBuffer();
    for (final msg in messages) {
      //保存扩展信息
      var extension = msg.serverExtension;

      //由于消息中的fromNick 不可靠，此处需要设置消息显示的昵称
      String userAccId = msg.senderId!;
      ContactInfo? contactInfo =
          await getIt<ContactProvider>().getContact(userAccId);
      String senderNick = contactInfo?.getName(needAlias: false) ?? userAccId;
      String? senderAvatar = contactInfo?.user.avatar;
      msg.serverExtension = jsonEncode({
        mergedMessageNickKey: senderNick,
        mergedMessageAvatarKey: senderAvatar
      });

      //  转换成json
      var encodeResult =
          await await NimCore.instance.messageService.messageSerialization(msg);
      if (encodeResult.isSuccess && encodeResult.data != null) {
        stringBuilder.write('$enter${encodeResult.data}');
      }
      msg.serverExtension = extension;
    }
    var resultString = stringBuilder.toString();
    return NIMResult.success(data: resultString.substring(enter.length));
  }

  ///保存最近转发的会话
  ///最多保存五条
  static void saveRecentForward(List<RecentForward> recentList) async {
    final recentForwardKey = '$recentForwardSPKey${IMKitClient.account()}';
    final recentForwardStr =
        await PreferenceUtils.getString(recentForwardKey, '');
    var saveList = <RecentForward>[];
    if (recentList.length > maxRecentForward) {
      saveList = recentList.sublist(0, maxRecentForward);
    } else if (recentForwardStr.isNotEmpty) {
      saveList.addAll(recentList);
      final recentForwardList =
          RecentForward.fromJsonArray(jsonDecode(recentForwardStr));
      var cacheList =
          recentForwardList.where((e) => !recentList.contains(e)).toList();
      cacheList.sort((a, b) => a.time.compareTo(b.time));
      if (saveList.length + cacheList.length > maxRecentForward) {
        saveList
            .addAll(cacheList.sublist(0, maxRecentForward - recentList.length));
      } else {
        saveList.addAll(cacheList);
      }
    } else {
      saveList.addAll(recentList);
    }
    final jsonArray = RecentForward.toJsonList(saveList);
    await PreferenceUtils.saveString(recentForwardKey, jsonEncode(jsonArray));
  }

  ///获取最近转发的会话
  static Future<List<RecentForward>> getRecentForward() async {
    final recentForwardKey = '$recentForwardSPKey${IMKitClient.account()}';
    final recentForwardStr =
        await PreferenceUtils.getString(recentForwardKey, '');

    var resultList = <RecentForward>[];

    if (recentForwardStr.isNotEmpty) {
      try {
        final jsonArray = jsonDecode(recentForwardStr) as List<dynamic>;
        final recentList = RecentForward.fromJsonArray(jsonArray);
        //处理好友信息
        final friendList = recentList
            .where((e) => e.sessionType == NIMConversationType.p2p)
            .toList(growable: false);

        final contactList = (await getIt<ContactProvider>()
            .fetchUserList(friendList.map((e) => e.sessionId).toList()));

        for (RecentForward e in friendList) {
          final friend = contactList.firstWhereOrNull(
              (contact) => contact.user.accountId == e.sessionId);
          e.friend = friend;
        }

        //处理群组
        final teamList = recentList
            .where((e) => e.sessionType == NIMConversationType.team)
            .toList(growable: false);

        final teamIds = teamList.map((team) => team.sessionId).toList();

        final teamInfoList =
            await TeamRepo.getTeamInfoByIds(teamIds, NIMTeamType.typeNormal);

        for (RecentForward e in teamList) {
          final team = teamInfoList
              ?.firstWhereOrNull((team) => team.teamId == e.sessionId);
          e.team = team;
        }

        final conversationIds = recentList
            .map((recent) => ChatKitUtils.conversationId(
                recent.sessionId, recent.sessionType))
            .where((c) => c != null)
            .map((id) => id!)
            .toList();

        final conversations =
            (await ConversationRepo.getConversationListByIds(conversationIds))
                .data;

        final orgListSize = recentList.length;
        //如果会话不存在，删除
        recentList.removeWhere((recent) =>
            conversations?.firstWhereOrNull((c) =>
                c.conversationId ==
                ChatKitUtils.conversationId(
                    recent.sessionId, recent.sessionType)) ==
            null);
        //如果群组是无效群则删除
        recentList.removeWhere((recent) =>
            recent.sessionType == NIMConversationType.team &&
            recent.team?.isValidTeam != true);
        if (orgListSize > recentList.length) {
          saveRecentForward(recentList);
        }

        resultList = recentList;
      } catch (e) {}
    }
    return resultList;
  }
}
