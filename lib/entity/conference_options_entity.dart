

import 'package:flutter_rtmp_live_plugin/enums/rtmp_encoding_orientation_enum.dart';

/// 连麦参数实体
class ConferenceOptionsEntity {
  /// 编码方向
  RtmpEncodingOrientationEnum videoEncodingOrientation;

  ConferenceOptionsEntity({
    this.videoEncodingOrientation,
  });

  ConferenceOptionsEntity.fromJson(Map<String, dynamic> json) {
    videoEncodingOrientation = json['videoEncodingOrientation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoEncodingOrientation'] = this.videoEncodingOrientation == null
        ? null
        : this
            .videoEncodingOrientation
            .toString()
            .replaceAll("RtmpEncodingOrientationEnum.", "");
    return data;
  }
}
