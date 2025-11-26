// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:netease_common_ui/widgets/permission_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import '../l10n/S.dart';
import '../utils/color_utils.dart';
import '../widgets/platform_utils.dart';
import 'dialog.dart';

Future<String?> showPhotoSelector(BuildContext context) async {
  var style = const TextStyle(fontSize: 16, color: CommonColors.color_333333);
  var select = await showBottomChoose<int>(
      context: context,
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context, 1);
          },
          child: Text(
            S.of(context).takePhoto,
            style: style,
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context, 2);
          },
          child: Text(
            S.of(context).choosePhoto,
            style: style,
          ),
        ),
      ],
      showCancel: true);
  if (select == 1) {
    return pickPhoto(context, true);
  } else if (select == 2) {
    return pickPhoto(context, false);
  }
  return null;
}

Future<String?> pickPhoto(BuildContext context, bool isCam) async {
  ImagePicker _picker = ImagePicker();
  final permissionList;
  if (Platform.isAndroid || Platform.isIOS) {
    // 显示顶部说明弹框
    showTopWarningDialog(
        context: context,
        title: isCam
            ? S.of(context).permissionCameraTitle
            : S.of(context).permissionStorageTitle,
        content: isCam
            ? S.of(context).permissionCameraContent
            : S.of(context).permissionStorageContent);
    if (Platform.isIOS) {
      permissionList = [Permission.photos];
    } else if (Platform.isAndroid) {
      if (await PlatformUtils.isAboveAndroidT()) {
        permissionList = [Permission.photos, Permission.videos];
      } else {
        permissionList = [Permission.storage];
      }
    } else {
      permissionList = [];
    }
    if (!isCam) {
      final granted = await PermissionsHelper.requestPermission(permissionList);
      // 关闭说明弹框
      Navigator.of(context).pop();
      if (!granted) {
        Fluttertoast.showToast(msg: S.of(context).permissionSystemCheck);
        return null;
      }
    } else {
      final granted =
          await PermissionsHelper.requestPermission([Permission.camera]);
      // 关闭说明弹框
      Navigator.of(context).pop();
      if (!granted) {
        Fluttertoast.showToast(msg: S.of(context).permissionSystemCheck);
        return null;
      }
    }
  }
  final XFile? photo = await _picker.pickImage(
      source: isCam ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80);
  if (photo != null) {
    return photo.path;
  }
  return null;
}
