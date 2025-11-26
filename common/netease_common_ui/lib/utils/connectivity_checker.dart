// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../l10n/S.dart';

Future<bool> haveConnectivity(
    {bool showToast = true, ToastGravity? gravity}) async {
  var connection = await Connectivity().checkConnectivity();

  if (connection == ConnectivityResult.none && showToast) {
    Fluttertoast.showToast(msg: S.of().networkErrorTip, gravity: gravity);
  }
  return connection != ConnectivityResult.none;
}
