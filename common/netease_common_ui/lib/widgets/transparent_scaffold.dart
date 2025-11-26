// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class TransparentScaffold extends StatelessWidget {
  //统一配置返回按钮，只有图标
  static Widget? defaultLeadingIcon;

  const TransparentScaffold(
      {Key? key,
      required this.title,
      this.centerTitle = true,
      this.leading,
      this.actions,
      this.leadingWidth,
      this.body,
      this.appBarBackgroundColor,
      this.elevation,
      this.bottom,
      this.iconTheme,
      this.appbarLeadingIcon,
      this.backgroundColor,
      this.subTitle,
      this.subTitleWidget})
      : super(key: key);

  final String title;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? body;
  final double? leadingWidth;
  final Color? backgroundColor;
  final double? elevation;
  final Color? appBarBackgroundColor;
  final PreferredSizeWidget? bottom;
  final IconThemeData? iconTheme;
  final Widget? appbarLeadingIcon;
  final String? subTitle;
  final Widget? subTitleWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xffeff1f4),
      appBar: AppBar(
          elevation: elevation ?? 0,
          backgroundColor: appBarBackgroundColor ?? Colors.transparent,
          leading: leading ??
              IconButton(
                icon: appbarLeadingIcon ??
                    defaultLeadingIcon ??
                    const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 26,
                    ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
          leadingWidth: leadingWidth,
          centerTitle: centerTitle,
          title: (subTitle == null && subTitleWidget == null)
              ? Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                    if (subTitle != null)
                      Text(
                        subTitle!,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    if (subTitleWidget != null) subTitleWidget!,
                  ],
                ),
          actions: actions,
          bottom: bottom,
          iconTheme: iconTheme),
      body: body,
    );
  }
}
