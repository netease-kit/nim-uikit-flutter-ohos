// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:netease_common_ui/utils/string_utils.dart';

import '../utils/color_utils.dart';

class Avatar extends StatelessWidget {
  const Avatar(
      {Key? key,
      this.avatar,
      this.name,
      this.fontSize,
      this.nameColor = Colors.white,
      this.bgCode,
      this.width = 40,
      this.height = 40,
      this.fit = BoxFit.cover,
      this.radius})
      : super(key: key);

  final double width;
  final double height;
  final String? avatar;
  final String? name;
  final double? fontSize;
  final int? bgCode;
  final double? radius;
  final Color? nameColor;
  final BoxFit fit; // 新增fit参数

  String _getName() {
    if (name != null) {
      return name!.length > 2
          ? name!.subStringWithoutEmoji(name!.length - 2)
          : name!;
    }
    return "";
  }

  _avatarColors() {
    return {
      0: CommonColors.color_60cfa7,
      1: CommonColors.color_53c3f3,
      2: CommonColors.color_537ff4,
      3: CommonColors.color_854fe2,
      4: CommonColors.color_be65d9,
      5: CommonColors.color_e9749d,
      6: CommonColors.color_f9b751
    };
  }

  Color _getAvatarColor(int hashCode) {
    int pos = hashCode == 0 ? Random().nextInt(7) : hashCode.abs() % 7;
    return _avatarColors()[pos];
  }

  bool _isAvatarEmpty() {
    return avatar == null || avatar!.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    bool isCircle = radius == null ||
        (radius != null && (radius! * 2 >= width || radius! * 2 >= height));

    Widget text = Text(
      _getName(),
      textAlign: TextAlign.center,
      maxLines: 1,
      style:
          TextStyle(fontSize: fontSize ?? 12, color: nameColor ?? Colors.white),
    );
    Color? bg;
    var img;
    if (_isAvatarEmpty()) {
      bg = _getAvatarColor(bgCode ?? _getName().hashCode);
    } else {
      if (isCircle) {
        // 圆形头像使用Container包装来控制fit
        img = Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: CachedNetworkImageProvider(avatar!, cacheKey: avatar!),
              fit: fit, // 使用传入的fit参数
            ),
          ),
        );
      } else {
        img = CachedNetworkImage(
          imageUrl: avatar!,
          cacheKey: avatar!,
          fit: fit, // 使用传入的fit参数
          width: width,
          height: height,
        );
      }
    }
    return SizedBox(
      height: height,
      width: width,
      child: isCircle
          ? (_isAvatarEmpty()
              ? CircleAvatar(
                  child: text,
                  backgroundColor: bg,
                )
              : img)
          : Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  child: Container(
                    height: height,
                    width: width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius!),
                      child: _isAvatarEmpty() ? Container(color: bg) : img,
                    ),
                  ),
                ),
                if (_isAvatarEmpty()) text,
              ],
            ),
    );
  }
}

class AvatarColor {
  static int avatarColor({String? content, int? value}) {
    if (content?.isNotEmpty == true) {
      return content.hashCode;
    }
    if (value != null) {
      return value % 10;
    }
    return 0;
  }
}
