// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_common_ui/utils/color_utils.dart';
import 'package:netease_common_ui/widgets/transparent_scaffold.dart';

typedef ContentBuilder = Widget Function(BuildContext context, String keyword);

class SearchPage extends StatefulWidget {
  SearchPage(
      {Key? key,
      this.title,
      this.searchHint,
      this.keyword,
      this.buildOnComplete = false,
      this.appbarLeadingIcon,
      this.leading,
      this.builder})
      : super(key: key);

  final String? title;
  final String? searchHint;
  final String? keyword;
  final bool buildOnComplete;
  final ContentBuilder? builder;

  ///返回图标
  final Widget? appbarLeadingIcon;

  ///appbar 返回按钮完全接管
  final Widget? leading;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController inputController = TextEditingController();
  late String keyword;

  @override
  void initState() {
    super.initState();
    keyword = widget.keyword ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return TransparentScaffold(
      elevation: 0,
      appBarBackgroundColor: Colors.transparent,
      centerTitle: true,
      title: widget.title ?? '',
      leading: widget.leading,
      appbarLeadingIcon: widget.appbarLeadingIcon,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: TextField(
              controller: inputController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                fillColor: Color(0xfff2f4f5),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none),
                isDense: true,
                hintText: widget.searchHint,
                hintStyle: const TextStyle(
                    color: CommonColors.color_a8adb6, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: CommonColors.color_a8adb6,
                ),
                suffixIcon: IconButton(
                  icon: SvgPicture.asset(
                    'images/ic_clear.svg',
                    package: 'netease_common_ui',
                  ),
                  onPressed: () {
                    inputController.clear();
                    setState(() {
                      keyword = '';
                    });
                  },
                ),
              ),
              maxLines: 1,
              style: const TextStyle(
                  color: CommonColors.color_333333, fontSize: 14),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                keyword = value;
                if (!widget.buildOnComplete) {
                  setState(() {});
                }
              },
              onEditingComplete: () {
                hideKeyboard();
                if (widget.buildOnComplete) {
                  setState(() {});
                }
              },
            ),
          ),
          if (widget.builder != null)
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: widget.builder!(context, keyword),
            )
        ],
      ),
    );
  }
}
