// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

extension StringHash on String {
  String get md5 => crypto.md5.convert(utf8.encode(this)).toString();

  String get sha1 => crypto.sha1.convert(utf8.encode(this)).toString();
}

extension FileHash on File {
  Future<String> get md5 async {
    if (this.existsSync()) {
      final bytes = await readAsBytes();
      return crypto.md5.convert(bytes).toString();
    } else {
      return "";
    }
  }

  Future<String> get sha1 async {
    if (this.existsSync()) {
      final bytes = await readAsBytes();
      return crypto.sha1.convert(bytes).toString();
    } else {
      return "";
    }
  }
}
