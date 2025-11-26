// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../l10n/S.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  bool hasNetWork = true;

  StreamSubscription? _netSub;

  Duration retryTime = Duration(seconds: 3);

  Timer? _netTimer;

  String tag = '';

  void _updateConnectivity() {
    Connectivity().checkConnectivity().then((value) {
      setState(() {
        hasNetWork = _isNetWorkAvailable(value);
        _retryNetworkIfNeed();
      });
    });
  }

  bool _isNetWorkAvailable(ConnectivityResult connects) {
    return connects == ConnectivityResult.mobile ||
        connects == ConnectivityResult.wifi ||
        connects == ConnectivityResult.ethernet ||
        connects == ConnectivityResult.bluetooth ||
        connects == ConnectivityResult.vpn;
  }

  void _retryNetworkIfNeed() {
    _netTimer?.cancel();
    if (hasNetWork == false) {
      _netTimer = Timer(retryTime, () {
        _updateConnectivity();
      });
    } else {
      _netTimer = null;
    }
  }

  @override
  @mustCallSuper
  void initState() {
    tag = "$runtimeType@$hashCode";
    Alog.i(tag: tag, content: "$tag init state");
    WidgetsBinding.instance.addObserver(this);
    _netSub = Connectivity().onConnectivityChanged.listen((event) {
      setState(() {
        hasNetWork = _isNetWorkAvailable(event);
      });
    });
    _updateConnectivity();
    super.initState();
  }

  @override
  @mustCallSuper
  void dispose() {
    Alog.i(tag: tag, content: "$tag dispose");
    WidgetsBinding.instance.removeObserver(this);
    _netSub?.cancel();
    _netTimer?.cancel();
    super.dispose();
  }

  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateConnectivity();
    }
    super.didChangeAppLifecycleState(state);
    Alog.i(tag: tag, content: "$tag ${state.toString()}");
    onAppLifecycleState(state);
  }

  void onAppLifecycleState(AppLifecycleState state) {}

  bool checkNetwork({bool showToast = true}) {
    if (hasNetWork == false && showToast) {
      Fluttertoast.showToast(msg: S.of().networkErrorTip);
      return false;
    }
    return true;
  }
}
