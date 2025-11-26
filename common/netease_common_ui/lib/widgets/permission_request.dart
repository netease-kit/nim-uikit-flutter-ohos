// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fluttertoast/fluttertoast.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/S.dart';

class PermissionsHelper {
  static Future<bool> requestPermission(List<Permission> permissions,
      {String? deniedTip}) async {
    final status = await permissions.request();
    Alog.e(
        tag: 'Permission',
        moduleName: 'requestPermission',
        content: 'Permission status $status');

    bool isAllGranted = true;
    bool showTip = false;
    status.forEach((key, value) {
      if (value.isDenied || value.isPermanentlyDenied) {
        isAllGranted = false;
      }
      if (value.isPermanentlyDenied) {
        showTip = true;
      }
    });
    if (showTip) {
      Fluttertoast.showToast(
          msg: deniedTip?.isNotEmpty == true
              ? deniedTip!
              : S.of().permissionRequestTip);
    }
    return isAllGranted;
  }
}
