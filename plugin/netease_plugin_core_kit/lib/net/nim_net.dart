// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_plugin_core_kit/net/nim_base_response.dart';
import 'package:nim_core_v2/nim_core.dart';

import 'nim_base_request.dart';

/// 网络请求
/// 通过IM透传实现
/// V2 没有透传消息，先注释
class NIMNet {
  /// 发送请求
  // static Future<BaseResponse<T>> sendRequest<T, R extends BaseRequest>(
  //     R request,
  //     {T? Function(Map<String, dynamic> json)? convertor}) async {
  //   final response = await NimCore.instance.passThroughService
  //       .httpProxy(request.toProxyData());
  //   final baseResponse = BaseResponse<T>(
  //       response.code, response.errorDetails, response.data,
  //       convertor: convertor);
  //   baseResponse.parse();
  //   return baseResponse;
  // }

  ///监听服务器下发的透传消息
  /// V2 没有透传消息，先注释
  // static Stream<NIMPassThroughNotifyData> observePassThroughNotify() {
  //   return NimCore.instance.passThroughService.onPassThroughNotifyData;
  // }
}
