// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../l10n/S.dart';

class NoNetWorkTip extends StatelessWidget {
  const NoNetWorkTip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 36,
        alignment: Alignment.center,
        color: Color(0xfffee3e6),
        child: Text(
          S.of(context).networkErrorTip,
          style: TextStyle(fontSize: 14, color: Color(0xfffc596a)),
        ));
  }
}
