import 'dart:async';

import 'package:flutter/services.dart';

class FlutterRtmpLivePlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_Rtmp_live_plugin');

  static Future<String> get platformVersion async {
    return await _channel.invokeMethod('init');
  }
}
