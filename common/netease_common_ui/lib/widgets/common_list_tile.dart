// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum TrailingType { arrow, onOff, custom }

class CommonListTile extends StatelessWidget {
  const CommonListTile(
      {Key? key,
      required this.title,
      this.trailingType = TrailingType.arrow,
      this.switchValue,
      this.onSwitchChanged,
      this.customTrailing,
      this.onTap})
      : assert(trailingType == TrailingType.arrow ||
            trailingType == TrailingType.custom ||
            (trailingType == TrailingType.onOff && switchValue != null)),
        super(key: key);

  final String title;
  final TrailingType trailingType;
  final bool? switchValue;
  final Function(bool value)? onSwitchChanged;
  final Widget? customTrailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget? _trailing;
    if (trailingType == TrailingType.arrow) {
      _trailing = const Icon(Icons.keyboard_arrow_right_outlined);
    } else if (trailingType == TrailingType.onOff) {
      _trailing = CupertinoSwitch(
        activeColor: CommonColors.color_337eff,
        onChanged: onSwitchChanged,
        value: switchValue ?? false,
      );
    } else {
      _trailing = customTrailing;
    }
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: CommonColors.color_333333, fontSize: 16),
      ),
      trailing: _trailing,
      onTap: onTap,
    );
  }
}
