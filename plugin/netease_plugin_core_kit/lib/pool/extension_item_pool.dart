// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_plugin_core_kit;

class ExtensionItemPool {
  static final ExtensionItemPool _singleton = ExtensionItemPool._();

  factory ExtensionItemPool() {
    return _singleton;
  }

  ExtensionItemPool._();

  ///输入更多操作预设
  final List<MessageInputAction> _inputMoreActions = List.empty(growable: true);

  void registerMoreAction<T extends MessageInputAction>(T item) {
    _inputMoreActions.add(item);
  }

  List<MessageInputAction> getMoreActions() {
    return _inputMoreActions;
  }

  ///弹框菜单操作预设
  final List<MessagePopupMenuAction> _popupMenuActions =
      List.empty(growable: true);

  void registerPopupMenuAction<T extends MessagePopupMenuAction>(T item) {
    _popupMenuActions.add(item);
  }

  List<MessagePopupMenuAction> getPopupMenuActions() {
    return _popupMenuActions;
  }
}
