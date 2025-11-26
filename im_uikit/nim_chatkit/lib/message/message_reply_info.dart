// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class ReplyMessageInfo {
  String? idClient; //: 'uuid',
  int? scene; //: "sessionType",
  String? from; //: "352379369509120",
  String? to; //: "9244706284",
  String? idServer; //: "620401736732901378",
  int? time; //: 1679648742393
  String? receiverId;

  ReplyMessageInfo(
      {required this.idClient,
      this.from,
      this.scene,
      this.to,
      this.idServer,
      this.time,
      this.receiverId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idClient': this.idClient,
      'scene': this.scene,
      'from': this.from,
      'to': this.to,
      'idServer': this.idServer,
      'time': this.time,
      'receiverId': this.receiverId
    };
  }

  factory ReplyMessageInfo.fromMap(Map<String, dynamic> map) {
    var info = ReplyMessageInfo(
        idClient: map['idClient'] as String?,
        from: map['from'] as String?,
        to: map['to'] as String?,
        idServer: map['idServer']?.toString(),
        time: map['time'] as int?,
        receiverId: map['receiverId']?.toString());
    if (map['scene'] is int?) {
      info.scene = map['scene'] as int?;
    }
    return info;
  }
}
