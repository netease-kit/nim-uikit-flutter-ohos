// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CheckBoxButton extends StatelessWidget {
  final bool isChecked;
  final Function(bool isChecked)? onChanged;

  final bool clickable;

  const CheckBoxButton(
      {Key? key,
      required this.isChecked,
      this.onChanged,
      this.clickable = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: clickable
          ? InkWell(
              onTap: () {
                if (onChanged != null) {
                  onChanged!(!isChecked);
                }
              },
              child: _buildButton())
          : _buildButton(),
    );
  }

  Widget _buildButton() {
    return !isChecked
        ? Container(
            height: 18,
            width: 18,
            decoration: BoxDecoration(
              border: Border.all(color: '#969AA0'.toColor()),
              shape: BoxShape.circle,
            ),
          )
        : SvgPicture.asset(
            'images/ic_selected.svg',
            package: 'netease_common_ui',
            width: 18,
            height: 18,
          );
  }
}
