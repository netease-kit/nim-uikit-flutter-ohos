// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:netease_common/netease_common.dart';
import 'package:nim_core_v2/nim_core.dart';

import '../im_kit_client.dart';
import '../repo/contact_repo.dart';

/// AI用户管理
/// AI用户全局缓存，每次登录成功数据同步完成之后重新拉取
class AIUserManager {
  AIUserManager._();

  static final AIUserManager instance = AIUserManager._();

  static const String logTag = "AIUserManager";

  final Map<String, NIMAIUser> aiUserCache = {};

  // 是否默认置顶,1置顶，0不置顶
  static const String KEY_PIN_DEFAULT = "pinDefault";

  // 是否ai聊,1是，0否
  static const String KEY_AI_CHAT = "aiChat";

  // 欢迎语
  static const String KEY_WELCOME_TEXT = "welcomeText";

  // 当前UserInfo中存放Unpin数字人列表的KEY
  static const String KEY_UNPIN_AI_USERS = "unpinAIUsers";

  //搜索AI用户
  AiSearchUserProvider? aiSearchUserProvider;

  //翻译
  AiTranslateUserProvider? aiTranslateUserProvider;

  //翻译语言
  AiTranslateLanguagesProvider? aiTranslateLanguagesProvider;

  StreamController<List<NIMAIUser>> _aiUserChangeController =
      StreamController<List<NIMAIUser>>.broadcast();

  /// 获取AI用户列表变更通知
  Stream<List<NIMAIUser>>? aiUserChanged;

  ///初始化数字人，登录之前调用
  void init() {
    if (IMKitClient.enableAi) {
      aiUserChanged = _aiUserChangeController.stream;
      getAIUserList();
      NimCore.instance.loginService.onLoginStatus.listen((event) {
        if (event == NIMLoginStatus.loginStatusLogined) {
          getAIUserList();
        }
      });
    }
  }

  /// 拉取AI用户信息，并缓存
  void getAIUserList() {
    NimCore.instance.aiService.getAIUserList().then((result) {
      if (result.isSuccess) {
        aiUserCache.clear();
        result.data?.forEach((user) {
          aiUserCache[user.accountId!] = user;
        });
        if (result.data != null) {
          _aiUserChangeController.add(result.data!);
        }
      }
    });
  }

  /// 获取AI聊功能的数字人
  ///
  /// @return
  List<NIMAIUser> getAIChatUserList() {
    return aiUserCache.values.where((user) => isAIChatUser(user)).toList();
  }

  /// 根据ID获取数字人
  NIMAIUser? getAIUserById(String accountId) {
    return aiUserCache[accountId];
  }

  /// 是否是AI聊用户
  ///
  /// @param aiUser
  /// @return
  static bool isAIChatUser(NIMAIUser aiUser) {
    if (aiUser.serverExtension?.isNotEmpty == true) {
      try {
        return jsonDecode(aiUser.serverExtension!)[KEY_AI_CHAT] == 1;
      } catch (e) {
        Alog.e(
            tag: logTag,
            content: 'parse ai user server extension failed, ${e.toString()}');
      }
    }
    return false;
  }

  // 获取已取消置顶的AI数字人列表
  ///
  /// @return
  List<String> getUnpinAIUserList(NIMUserInfo currentUserInfo) {
    var userExtStr = currentUserInfo.serverExtension;
    if (userExtStr != null) {
      try {
        // 检查是否存在对应键值且类型为 List
        var userExtJson = jsonDecode(userExtStr) as Map<String, dynamic>;
        // 检查是否存在对应键值且类型为 List
        var unpinData = userExtJson[KEY_UNPIN_AI_USERS] as List<dynamic>;
        return (unpinData.length > 0) ? unpinData.cast<String>() : [];
      } catch (e) {
        // 处理 JSON 解析异常
        return []; // 返回空列表
      }
    }
    return [];
  }

  // AI数字人置顶操作
  /// @param addPin true 置顶，false取消置顶
  /// @return
  Future<NIMResult<void>> unpinAIUser(String accountId, bool addPin) async {
    var currentId = IMKitClient.account();
    if (currentId == null) {
      return NIMResult.failure(
          message: 'current user is null, please '
              'login '
              'first');
    }
    var value = await ContactRepo.getUserList([currentId]);
    if (value.isSuccess && value.data != null && value.data!.length > 0) {
      try {
        var userExtStr = value.data![0].serverExtension;
        List<dynamic> userUnpinArray = [];
        Map<String, dynamic> userExtJson = {};
        if (userExtStr != null && userExtStr.isNotEmpty) {
          try {
            userExtJson = jsonDecode(userExtStr) as Map<String, dynamic>;
          } catch (e) {
            Alog.e(
                content:
                    'unpinAIUser error parse ai user server extension failed, ${e.toString()}');
          }

          if (userExtJson.isNotEmpty) {
            // 检查是否存在对应键值且类型为 List
            var unpinData = userExtJson[KEY_UNPIN_AI_USERS];
            userUnpinArray = (unpinData is List<dynamic>) ? unpinData : [];
          }
        }
        if (addPin) {
          // 正向遍历时要注意移除元素后的索引变化
          for (int index = userUnpinArray.length - 1; index >= 0; index--) {
            if (accountId == userUnpinArray[index]) {
              userUnpinArray.removeAt(index);
            }
          }
        } else {
          userUnpinArray.add(accountId);
        }
        // 更新 JSON 对象
        userExtJson[KEY_UNPIN_AI_USERS] = userUnpinArray;
        var param =
            NIMUserUpdateParam(serverExtension: jsonEncode(userExtJson));
        return ContactRepo.updateSelfUserProfile(param);
      } catch (e) {
        return NIMResult.failure(
            message: 'current user serverExtension is '
                'not json format');
      }
    } else {
      return NIMResult.failure(message: 'AIUser not found');
    }
  }

  /// 根据accId判断是否是AI聊用户
  ///
  /// @param account
  /// @return
  bool isAIChatUserByAccount(String account) {
    final aiUser = aiUserCache[account];
    if (aiUser != null) {
      return isAIChatUser(aiUser);
    }
    return false;
  }

  /// 是否是AI数字人
  ///
  /// @param account
  /// @return
  bool isAIUser(String? account) {
    return aiUserCache.containsKey(account);
  }

  /// 获取默认置顶的AI用户
  ///
  /// @return
  List<NIMAIUser> getPinDefaultUserList() {
    return aiUserCache.values.where((user) => isPinDefault(user)).toList();
  }

  /// 是否默认置顶
  ///
  /// @param aiUser
  /// @return
  bool isPinDefault(NIMAIUser aiUser) {
    if (aiUser.serverExtension?.isNotEmpty == true) {
      try {
        return jsonDecode(aiUser.serverExtension!)[KEY_PIN_DEFAULT] == 1;
      } catch (e) {
        Alog.e(
            tag: logTag,
            content: 'parse ai user server extension failed, ${e.toString()}');
      }
    }
    return false;
  }

  /// 获取欢迎语
  ///
  /// @param userId
  /// @return
  String? getWelcomeText(String userId) {
    final aiUser = aiUserCache[userId];
    if (aiUser != null) {
      if (aiUser.serverExtension?.isNotEmpty == true) {
        try {
          return jsonDecode(aiUser.serverExtension!)[KEY_WELCOME_TEXT];
        } catch (e) {
          Alog.e(
              tag: logTag,
              content:
                  'parse ai user server extension failed, ${e.toString()}');
        }
      }
    }
    return null;
  }

  ///获取所有AI用户
  List<NIMAIUser> getAllAIUsers() {
    return aiUserCache.values.toList();
  }

  /// 获取翻译目标语言
  List<String> getAITranslateLanguages() {
    return aiTranslateLanguagesProvider?.call(getAllAIUsers()) ?? [];
  }

  /// 获取翻译AI用户
  NIMAIUser? getAITranslateUser() {
    return aiTranslateUserProvider?.call(getAllAIUsers()) ?? null;
  }

  /// 获取AI搜索的AI用户
  NIMAIUser? getAISearchUser() {
    return aiSearchUserProvider?.call(getAllAIUsers()) ?? null;
  }
}

/// 注册AI划词的AI 数字人
/// (客户配置)
typedef AiSearchUserProvider = NIMAIUser? Function(List<NIMAIUser> users);

/// 注册翻译的AI数字人
/// (客户配置)
typedef AiTranslateUserProvider = NIMAIUser? Function(List<NIMAIUser> users);

/// 注册AI翻译的目标语言
/// (客户配置)
typedef AiTranslateLanguagesProvider = List<String> Function(
    List<NIMAIUser> users);
