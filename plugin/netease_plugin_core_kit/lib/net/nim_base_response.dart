// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:nim_core_v2/nim_core.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import 'net_key.dart';

class BaseResponse<T> {
  static const String tag = 'BaseResponse';

  final int code;
  final dynamic error;
  final NIMPassThroughProxyData? proxyData;
  int dataCode = -1;

  String? dataMsg;

  String? dataRequestId;

  /// 数据由 proxyData 中的 body 转换而来
  T? data;

  /// json转换器
  T? Function(Map<String, dynamic> json)? convertor;

  BaseResponse(this.code, this.error, this.proxyData, {this.convertor});

  void parse() {
    if (proxyData == null || proxyData?.body?.isNotEmpty != true) {
      return;
    }
    try {
      Map<String, dynamic> jsonMap = json.decode(proxyData!.body!);
      dataMsg = jsonMap[NetParamKey.keyResultMsg] as String?;
      dataCode = (jsonMap[NetParamKey.keyResultCode] as int?) ?? -1;
      dataRequestId = jsonMap[NetParamKey.keyResultRequestId] as String?;
      if (jsonMap[NetParamKey.keyResultData] is Map) {
        data = convertor?.call((jsonMap[NetParamKey.keyResultData] as Map)
            .cast<String, dynamic>());
      } else {
        data = jsonMap[NetParamKey.keyResultData] as T?;
      }
    } catch (e) {
      Alog.e(tag: tag, content: 'parse error:$e');
    }
  }

  bool isSuccessful() {
    return (code == 0 || code == 200) && (dataCode == 0 || dataCode == 200);
  }

  @override
  String toString() {
    return 'BaseResponse{code: $code, error: $error, proxyData: $proxyData, dataCode: $dataCode}';
  }

  String getDataContent(NIMPassThroughProxyData? data) {
    if (data == null) {
      return 'PassthroughProxyData{}';
    }
    return 'PassthroughProxyData{path: ${data.path}, header: ${data.header}, method: ${data.method}, body: ${data.body}}';
  }
}
