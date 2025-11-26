// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netease_common_ui/extension.dart';
import 'package:netease_common_ui/ui/background.dart';
import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:netease_common_ui/utils/connectivity_checker.dart';
import 'package:netease_common_ui/widgets/transparent_scaffold.dart';

class UpdateTextInfoPage extends StatefulWidget {
  const UpdateTextInfoPage(
      {Key? key,
      required this.title,
      required this.content,
      required this.maxLength,
      required this.privilege,
      required this.sureStr,
      this.leading,
      this.onSave,
      this.maxLines})
      : super(key: key);

  final String title;
  final String? content;
  final int maxLength;
  final int? maxLines;
  final bool privilege;
  final Future<bool> Function(String value)? onSave;

  final String sureStr;

  final Widget? leading;

  @override
  State<StatefulWidget> createState() => _UpdateTextInfoPageState();
}

class _UpdateTextInfoPageState extends State<UpdateTextInfoPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  Widget build(BuildContext context) {
    return TransparentScaffold(
      title: widget.title,
      centerTitle: true,
      appbarLeadingIcon: widget.leading,
      actions: widget.privilege
          ? [
              InkWell(
                onTap: () async {
                  if (!(await haveConnectivity())) {
                    return;
                  }
                  if (widget.onSave != null) {
                    widget.onSave!(_controller.text).then((value) {
                      FocusScope.of(context).unfocus();
                      if (value) {
                        Navigator.pop(context);
                      }
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.sureStr,
                    style: const TextStyle(
                        fontSize: 16, color: CommonColors.color_337eff),
                  ),
                ),
              )
            ]
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 6),
        child: CardBackground(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              style: const TextStyle(
                  fontSize: 14, color: CommonColors.color_333333),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: widget.privilege
                    ? IconButton(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        onPressed: () {
                          _controller.clear();
                        },
                        icon: SvgPicture.asset(
                          'images/ic_clear.svg',
                          package: 'netease_common_ui',
                        ),
                      )
                    : null,
              ),
              controller: _controller,
              maxLength: widget.maxLength,
              readOnly: !widget.privilege,
              minLines: 1,
              maxLines: widget.maxLines ?? (widget.maxLength / 10).ceil(),
            ),
          ),
        ),
      ),
    );
  }
}
