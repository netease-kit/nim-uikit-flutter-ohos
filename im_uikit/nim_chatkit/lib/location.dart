// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

///位置消息信息
class LocationInfo {
  //纬度
  double latitude;
  //经度
  double longitude;

  String? address;

  String? name;

  LocationInfo(this.latitude, this.longitude, {this.address, this.name});
}
