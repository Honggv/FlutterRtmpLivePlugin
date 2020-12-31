import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rtmp_live_plugin/controller/rtmp_push_view_controller.dart';
import 'package:flutter_rtmp_live_plugin/entity/camera_streaming_setting_entity.dart';
import 'package:flutter_rtmp_live_plugin/entity/streaming_profile_entity.dart';

/// Rtmp连麦推流预览窗口
class RtmpPushView extends StatefulWidget {
  /// 系统参数
  final StreamingProfileEntity streamingProfile;

  /// 相机设置
  final CameraStreamingSettingEntity cameraStreamingSetting;

  /// 创建事件
  final ValueChanged<RtmpPushViewController> onViewCreated;

  const RtmpPushView({
    Key key,
    this.onViewCreated,
    this.cameraStreamingSetting,
    this.streamingProfile,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RtmpPushViewState();
}

class RtmpPushViewState extends State<RtmpPushView> {
  /// 唯一标识符，需要与PlatformView标识对应
  static const String type = "plugins.com.honggv/RtmpPush";

  @override
  Widget build(BuildContext context) {
    // 请求参数
    Map<String, dynamic> params = {
      "streamingProfile": widget.streamingProfile != null
          ? jsonEncode(widget.streamingProfile)
          : null,
      "cameraStreamingSetting": widget.cameraStreamingSetting != null
          ? jsonEncode(widget.cameraStreamingSetting)
          : null,
    };
    // 请求参数解码器
    var paramsCodec = StandardMessageCodec();

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: type,
        creationParams: params,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: paramsCodec,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: type,
        creationParams: params,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: paramsCodec,
      );
    } else {
      return Text("不支持的平台");
    }
  }

  /// 创建事件
  void _onPlatformViewCreated(int id) {
    if (widget.onViewCreated != null) {
      widget.onViewCreated(RtmpPushViewController(id));
    }
  }
}
