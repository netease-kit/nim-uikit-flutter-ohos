// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_common_ui/widgets/transparent_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommonBrowser extends StatefulWidget {
  const CommonBrowser({
    Key? key,
    this.title,
    required this.url,
    this.backgroundColor,
    this.onWebResourceError,
  }) : super(key: key);

  final String? title;
  final String url;
  final Color? backgroundColor;

  final void Function(WebResourceError error)? onWebResourceError;

  @override
  State<StatefulWidget> createState() => _CommonBrowserState();
}

class _CommonBrowserState extends State<CommonBrowser> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            widget.onWebResourceError?.call(error);
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return TransparentScaffold(
      title: widget.title ?? '',
      centerTitle: true,
      backgroundColor: widget.backgroundColor ?? Colors.white,
      body: WebViewWidget(controller: controller),
    );
  }
}
