// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static SharedPreferences? prefs;

  static prepareSp() async {
    prefs ??= await SharedPreferences.getInstance();
  }

  static Future<bool> getBool(String key, bool value) async {
    await prepareSp();
    return prefs!.getBool(key) ?? value;
  }

  static Future<bool> saveBool(String key, bool value) async {
    await prepareSp();
    return prefs!.setBool(key, value);
  }

  static Future<int> getInt(String key, int value) async {
    await prepareSp();
    return prefs!.getInt(key) ?? value;
  }

  static Future<bool> saveInt(String key, int value) async {
    await prepareSp();
    return prefs!.setInt(key, value);
  }

  static Future<String> getString(String key, String value) async {
    await prepareSp();
    return prefs!.getString(key) ?? value;
  }

  static Future<bool> saveString(String key, String value) async {
    await prepareSp();
    return prefs!.setString(key, value);
  }

  static Future<String?> getStringEx(String key, String? value) async {
    await prepareSp();
    return prefs!.getString(key) ?? value;
  }
}
