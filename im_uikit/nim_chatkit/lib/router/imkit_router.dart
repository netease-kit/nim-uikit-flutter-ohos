// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
// import 'package:go_router/go_router.dart';
import 'package:nim_core_v2/nim_core.dart';

class IMKitRouter {
  late Map<String, WidgetBuilder> routes;

  IMKitRouter._() {
    routes = {};
  }

  static final IMKitRouter instance = IMKitRouter._();

  //全局的路由监听
  final RouteObserver<Route<dynamic>> routeObserver = RouteObserver();

  bool registerRouter(String name, WidgetBuilder builder,
      {Map<String, Object>? arguments, bool cover = false}) {
    if (routes[name] == null || cover) {
      routes[name] = builder;
      return true;
    }
    return false;
  }

  static T? getArgumentFormMap<T>(BuildContext context, String key) {
    // 传统 Navigator 的参数获取方式
    var argument = ModalRoute.of(context)!.settings.arguments;
    if (argument == null || argument is! Map) {
      return null;
    }
    Map<String, Object?> argMap = argument as Map<String, Object?>;
    return argMap[key] as T?;
  }
}
