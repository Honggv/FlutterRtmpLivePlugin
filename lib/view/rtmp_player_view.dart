import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rtmp_live_plugin/controller/rtmp_player_view_controller.dart';

/// Rtmp播放器窗口
class RtmpPlayerView extends StatefulWidget {
  /// 创建事件
  final ValueChanged<RtmpPlayerViewController> onViewCreated;

  /// 播放地址
  final String url;

  const RtmpPlayerView({
    Key key,
    this.onViewCreated,
    this.url,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => RtmpPlayerViewState();
}

class RtmpPlayerViewState extends State<RtmpPlayerView> {
  /// 唯一标识符，需要与PlatformView标识对应
  static const String type = "plugins.com.honggv/RtmpPlay";

  @override
  Widget build(BuildContext context) {
    // 请求参数
    Map<String, dynamic> params = {
      "url": widget.url,
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
      widget.onViewCreated(RtmpPlayerViewController(id));
    }
  }
}
