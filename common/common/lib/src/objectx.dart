// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

extension ObjectX<T> on T? {
  R? guard<R>(R Function(T value) cb) {
    if (this is T) return cb(this as T);
    return null;
  }

  R? safeCast<R>() {
    if (this is R) return this as R;
    return null;
  }
}

extension IterableX<E> on Iterable<E> {
  Iterable<E> copy() {
    return List<E>.from(this, growable: false);
  }

  int firstIndexOf(bool Function(E element) test) {
    var index = 0;
    for (final element in this) {
      if (test(element)) {
        return index;
      }
      index++;
    }
    return -1;
  }

  E? maxByOrNull<R extends Comparable<R>>(R Function(E element) selector) {
    if (isEmpty) return null;
    var maxElement = first;
    var maxValue = selector(maxElement!);
    for (final element in this) {
      final value = selector(element);
      if (value.compareTo(maxValue) > 0) {
        maxElement = element;
        maxValue = value;
      }
    }
    return maxElement;
  }
}

extension ListX<E> on List<E> {
  E? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

extension MapX<K, V> on Map<K, V>? {
  T? getOrDefault<T>(K key, T defaultValue) {
    final thiz = this;
    if (thiz == null) return defaultValue;
    final value = thiz[key];
    if (value is T) {
      return value;
    }
    return defaultValue;
  }

  T? getOrCompute<T>(K key, T Function() computation) {
    final thiz = this;
    if (thiz == null) return computation();
    final value = thiz[key];
    if (value is T) {
      return value;
    }
    return computation();
  }

  void withValue<T>(Object? key, ValueSetter<T> onValue) {
    final thiz = this;
    if (thiz != null && thiz.containsKey(key)) {
      final value = thiz[key];
      if (value is T) {
        onValue(thiz[key] as T);
      }
    }
  }

  void withValueOrDefault<T>(Object? key, ValueSetter<T> onValue, T def) {
    final thiz = this;
    if (thiz != null && thiz.containsKey(key)) {
      final value = thiz[key];
      if (value is T) {
        onValue(thiz[key] as T);
        return;
      }
    }
    onValue(def);
  }
}

extension ValueNotifierEx on ValueNotifier<bool> {
  void toggle() {
    value = !value;
  }
}
