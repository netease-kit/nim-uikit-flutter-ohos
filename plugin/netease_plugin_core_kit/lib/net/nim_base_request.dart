// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:ui';

import 'package:nim_core_v2/nim_core.dart';

import 'net_key.dart';

abstract class BaseRequest {
  static const String baseUrlTest = '/im-plugin-test/';

  static const String baseUrl = '/im-plugin/';

  NIMPassThroughProxyData toProxyData() {
    return NIMPassThroughProxyData(
      zone: prepareForZone(),
      path: prepareForPath(),
      method: prepareForMethod(),
      header: prepareForHeader(),
      body: prepareForBody(),
    );
  }

  String? prepareForZone() {
    return null;
  }

  String? prepareForPath();

  int prepareForMethod() {
    return PassThroughMethod.POST;
  }

  String getBaseUrl(bool isDebug) {
    return isDebug ? baseUrlTest : baseUrl;
  }

  String prepareForHeader() {
    final headerMap = prepareForHeaderWithMap();
    return json.encode(headerMap);
  }

  Map<String, String?> prepareForHeaderWithMap() {
    final header = <String, String?>{};
    header[NetParamKey.keyHeaderClientType] = 'flutter';
    final languageCode = getLanguageCode();
    header[NetParamKey.keyHeaderAcceptLanguage] = languageCode;
    header[NetParamKey.keyHeaderContentType] = 'application/json;charset=utf-8';
    return header;
  }

  String? prepareForBody() {
    final bodyMap = prepareForBodyWithMap();
    if (bodyMap != null) {
      return json.encode(bodyMap);
    }
    return null;
  }

  Map<String, dynamic>? prepareForBodyWithMap();

  String getLanguageCode() {
    var locale = PlatformDispatcher.instance.locale;
    return '${locale.languageCode}_${locale.countryCode}';
  }
}
