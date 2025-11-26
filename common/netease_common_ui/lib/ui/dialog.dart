// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/S.dart';
import '../utils/color_utils.dart';

Future<bool?> showCommonDialog(
    {required BuildContext context,
    String? title,
    String? content,
    String? positiveContent,
    String? navigateContent,
    bool showNavigate = true}) async {
  assert(title != null || content != null);
  return showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: title != null
              ? Text(
                  title,
                  style: const TextStyle(fontSize: 17),
                )
              : null,
          content: content != null
              ? Text(
                  content,
                  style: const TextStyle(
                      fontSize: 13, color: CommonColors.color_333333),
                )
              : null,
          actions: [
            if (showNavigate)
              CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    navigateContent ?? S.of(context).cancel,
                    style: const TextStyle(
                        fontSize: 17, color: CommonColors.color_666666),
                  )),
            CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  positiveContent ?? S.of(context).sure,
                  style: const TextStyle(
                      fontSize: 17, color: CommonColors.color_007aff),
                ))
          ],
        );
      });
}

//弹出顶部提示框
Future<void> showTopWarningDialog({
  required BuildContext context,
  String? title,
  required String content,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 32, left: 40, right: 40),
            child: Material(
              color: CupertinoColors.systemGrey6.resolveFrom(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    Text(
                      content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      );
    },
  );
}

Future<T?> showBottomChoose<T>(
    {required BuildContext context,
    required List<CupertinoActionSheetAction> actions,
    Widget? title,
    Widget? message,
    bool showCancel = true,
    Function(BuildContext buildContext)? contextCb}) async {
  return showCupertinoModalPopup<T>(
      context: context,
      barrierColor: Color(0x66000000),
      builder: (BuildContext context) {
        contextCb?.call(context);
        return CupertinoActionSheet(
          title: title,
          message: message,
          cancelButton: showCancel
              ? CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    S.of(context).cancel,
                    style: TextStyle(
                        fontSize: 16, color: CommonColors.color_333333),
                  ),
                )
              : null,
          actions: actions
              .map((e) => Container(
                    color: Colors.white,
                    child: e,
                  ))
              .toList(),
        );
      });
}

void showDateTimePicker(
    BuildContext context, String? initTime, ValueChanged<String> onSelect) {
  DateFormat inputFormat = DateFormat("y-M-d");
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String pickTime = initTime?.isNotEmpty == true
      ? initTime!
      : outputFormat.format(DateTime.now());
  showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).cancel)),
                    const Expanded(child: SizedBox()),
                    TextButton(
                        onPressed: () {
                          onSelect(pickTime);
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).sure)),
                  ],
                ),
                const Divider(
                  height: 1,
                  color: CommonColors.color_666666,
                ),
                SizedBox(
                  height: 229,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    minimumDate: DateTime(1900, 1, 1, 0, 0),
                    maximumDate: DateTime.now(),
                    initialDateTime:
                        DateTime.tryParse(pickTime) ?? DateTime.now(),
                    onDateTimeChanged: (dateTime) {
                      pickTime = outputFormat.format(dateTime);
                    },
                  ),
                )
              ],
            ),
          ));
}
