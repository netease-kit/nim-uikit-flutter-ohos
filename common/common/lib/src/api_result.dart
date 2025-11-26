// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

typedef VoidResult = NEResult<void>;

class NEResult<T> {
  final int code;

  final String? msg;

  final T? data;

  final String? requestId;

  final int cost;

  const NEResult(
      {required this.code, this.msg, this.data, this.requestId, this.cost = 0});

  const NEResult.success() : this(code: 0);

  NEResult.successWith(T? data) : this(code: 0, data: data);

  bool isSuccess() => code == 0 || code == 200;

  T get nonNullData => data!;

  @override
  String toString() {
    final buffer = StringBuffer();
    final parts = <dynamic>[];

    if (isSuccess()) {
      buffer.write('Success(');
      if (data != null) {
        parts.add(data);
      }
    } else {
      buffer.write('Failure(');
      parts.add(code);
    }

    if (msg != null) parts.add(msg);
    if (requestId != null) parts.add(requestId);

    buffer.write(parts.join(', '));
    buffer.write(')');
    return buffer.toString();
  }
}

extension CommonResultExtension<T> on NEResult<T> {
  NEResult<T> onFailure(void Function(int, String?) action) {
    if (!isSuccess()) {
      action(code, msg);
    }
    return this;
  }
}

extension ObjectResultExtension<T extends Object> on NEResult<T> {
  NEResult<U> map<U>(U Function(T) mapper) => isSuccess()
      ? NEResult<U>(
          code: code,
          msg: msg,
          data: mapper(nonNullData),
        )
      : NEResult<U>(code: code, msg: msg, requestId: requestId, cost: cost);

  NEResult<T> onSuccess(void Function(T) action) {
    if (isSuccess()) {
      action(nonNullData);
    }
    return this;
  }
}

extension VoidResultExtension on NEResult<void> {
  NEResult<U> map<U>(U Function() mapper) => isSuccess()
      ? NEResult<U>(
          code: code,
          msg: msg,
          data: mapper(),
        )
      : NEResult<U>(code: code, msg: msg, requestId: requestId, cost: cost);

  NEResult<U> cast<U>() => NEResult<U>(
      code: code, msg: msg, data: null, requestId: requestId, cost: cost);

  NEResult<void> onSuccess(void Function() action) {
    if (isSuccess()) {
      action();
    }
    return this;
  }
}

extension CommonFutureResultExtension<T> on Future<NEResult<T>> {
  Future<NEResult<T>> onFailure(FutureOr Function(int, String?) action) async {
    return then<NEResult<T>>((value) async {
      if (!value.isSuccess()) {
        try {
          await action(value.code, value.msg);
        } catch (e, _) {
          assert(() {
            throw e;
          }());
        }
      }
      return value;
    });
  }
}

extension ObjectFutureResultExtension<T extends Object> on Future<NEResult<T>> {
  Future<NEResult<T>> onSuccess(FutureOr Function(T) action) {
    return then<NEResult<T>>((value) async {
      if (value.isSuccess()) {
        try {
          await action(value.nonNullData);
        } catch (e, _) {
          assert(() {
            throw e;
          }());
        }
      }
      return value;
    });
  }

  Future<NEResult<U>> map<U>(FutureOr Function(T) mapper) {
    return then<NEResult<U>>((value) async {
      if (value.isSuccess()) {
        try {
          final next = await mapper(value.nonNullData);
          if (next is NEResult) {
            return next as NEResult<U>;
          } else {
            return NEResult<U>.successWith(next as U);
          }
        } catch (e, _) {
          assert(() {
            throw e;
          }());
          return NEResult<U>(code: -1, msg: e.toString());
        }
      } else {
        return NEResult<U>(
            code: value.code,
            msg: value.msg,
            requestId: value.requestId,
            cost: value.cost);
      }
    });
  }
}

extension VoidFutureResultExtension on Future<NEResult<void>> {
  Future<NEResult<void>> onSuccess(FutureOr Function() action) {
    return then<NEResult<void>>((value) async {
      if (value.isSuccess()) {
        try {
          await action();
        } catch (e, _) {
          assert(() {
            throw e;
          }());
        }
      }
      return value;
    });
  }

  Future<NEResult<U>> map<U>(FutureOr Function() mapper) {
    return then<NEResult<U>>((value) async {
      if (value.isSuccess()) {
        try {
          final next = await mapper();
          if (next is NEResult) {
            return next as NEResult<U>;
          } else {
            return NEResult<U>.successWith(next as U);
          }
        } catch (e, _) {
          assert(() {
            throw e;
          }());
          return NEResult<U>(code: -1, msg: e.toString());
        }
      } else {
        return NEResult<U>(
            code: value.code,
            msg: value.msg,
            requestId: value.requestId,
            cost: value.cost);
      }
    });
  }
}
