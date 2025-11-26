// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// 数字人相关错误码
///
/// @constructor Create empty AI error code
class AIErrorCode {
  // 请求大语言模型失败
  static const int errorCodeFailedToRequestLlm = 189308;

  // AI消息功能未开通
  static const int errorCodeAiMessagesFunctionDisabled = 107337;

  // 不是数字人账号
  static const int errorCodeIsNotAiAccount = 102304;

  // 不允许对数字人进行黑名单操作
  static const int errorCodeAiAccountBlocklistOperationNotAllowed = 106403;

  // 参数错误
  static const int errorCodeParameterError = 414;

  // AI消息格式不支持错误码
  static const int errorTipsCode = 107336;

  // 不存在
  static const int errorCodeAccountNotExist = 102404;
  static const int errorCodeFriendNotExist = 104404;

  // 账号被封禁
  static const int errorCodeAccountBanned = 102422;

  // 账号被禁言
  static const int errorCodeAccountChatBanned = 102421;

  // 命中反垃圾
  static const int errorCodeMessageHitAntispam = 107451;

  // 群成员不存在
  static const int errorCodeTeamMemberNotExist = 109404;

  // 群成员被禁言
  static const int errorCodeTeamNormalMemberChatBanned = 108306;

  // 群被禁言
  static const int errorCodeTeamMemberChatBanned = 109424;

  // 频控
  static const int errorCodeRateLimit = 416;

  // 成功
  static const int errorCodeSuccess = 200;
}
