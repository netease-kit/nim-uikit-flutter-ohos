// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:device_info_plus/device_info_plus.dart';

class PlatformUtils {
  ///获取Android的deviceInfo
  static Future<AndroidDeviceInfo> getAndroidDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    return await deviceInfo.androidInfo;
  }

  ///Android 版本是否高于 33/Android T
  static Future<bool> isAboveAndroidT() async {
    final deviceInfo = await getAndroidDeviceInfo();
    return deviceInfo.version.sdkInt >= 33;
  }
}
