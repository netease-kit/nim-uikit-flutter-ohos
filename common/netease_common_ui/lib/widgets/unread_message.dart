// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class UnreadMessage extends StatelessWidget {
  const UnreadMessage(
      {Key? key, required this.count, this.width = 18, this.height = 18})
      : super(key: key);

  final int count;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String sCount = count > 99 ? '99+' : count.toString();
    double _w = width + (sCount.length - 1) * 4;
    return count > 0
        ? Container(
            width: _w,
            height: height,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: Color(0xfff24957),
                borderRadius: BorderRadius.all(Radius.circular(9))),
            child: Text(
              sCount,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          )
        : Container();
  }
}
