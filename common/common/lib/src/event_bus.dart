// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

//订阅者回调签名
typedef void EventCallback(arg);

class EventBus {
  //私有构造函数
  EventBus._internal();

  //保存单例
  static final EventBus _singleton = EventBus._internal();

  //工厂构造函数
  factory EventBus() => _singleton;

  //保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  final _emap = <Object, List<EventCallback>>{};

  //添加订阅者
  void subscribe(Object eventName, EventCallback f) {
    _emap.putIfAbsent(eventName, () => <EventCallback>[]).add(f);
  }

  //移除订阅者
  void unsubscribe(Object eventName, [EventCallback? f]) {
    var callbackList = _emap[eventName];
    if (callbackList == null) return;
    if (f == null) {
      callbackList.clear();
    } else {
      callbackList.remove(f);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  void emit(eventName, [arg]) {
    final callbackList = _emap[eventName];
    if (callbackList == null) return;
    for (var callback in [...callbackList]) {
      callback(arg);
    }
  }
}
