import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rtmp_live_plugin/enums/rtmp_player_display_aspect_ratio_enum.dart';
import 'package:flutter_rtmp_live_plugin/enums/rtmp_player_listener_type_enum.dart';
import 'package:flutter_rtmp_live_plugin/view/rtmp_player_view.dart';

/// 视图控制器
class RtmpPlayerViewController {
  RtmpPlayerViewController(int id)
      : _channel = new MethodChannel('${RtmpPlayerViewState.type}_$id');

  final MethodChannel _channel;

  /// 监听器对象
  RtmpPlayerListener listener;

  /// 添加消息监听
  void addListener(RtmpPlayerListenerValue func) {
    if (listener == null) {
      listener = RtmpPlayerListener(_channel);
    }
    listener.addListener(func);
  }

  /// 移除消息监听
  void removeListener(RtmpPlayerListenerValue func) {
    if (listener == null) {
      listener = RtmpPlayerListener(_channel);
    }
    listener.removeListener(func);
  }

  /// 设置画面预览模式
  Future<void> setDisplayAspectRatio({
    @required RtmpPlayerDisplayAspectRatioEnum mode,
  }) async {
    return _channel.invokeMethod('setDisplayAspectRatio', {
      "mode": RtmpPlayerDisplayAspectRatioEnumTool.toInt(mode),
    });
  }

  /// 开始播放
  Future<void> start({
    String url, // URL，如果该属性不为null，则会执行切换操作
    bool
        sameSource : false, // 是否是同种格式播放，同格式切换打开更快 @waring 当sameSource 为 YES 时，视频格式与切换前视频格式不同时，会导致视频打开失败【该属性仅IOS有效】
  }) async {
    print('==================================='+url);
    return await _channel.invokeMethod('start', {
      "url": url,
      "sameSource": sameSource,
    });
  }

  /// 重连
  Future<void> reStart({
    String url, // URL，如果该属性不为null，则会执行切换操作
    bool
    sameSource : false, // 是否是同种格式播放，同格式切换打开更快 @waring 当sameSource 为 YES 时，视频格式与切换前视频格式不同时，会导致视频打开失败【该属性仅IOS有效】
  }) async {
    print('==================================='+url);
    return await _channel.invokeMethod('reStart', {
      "url": url,
      "sameSource": sameSource,
    });
  }

  /**
   * runInForeground
   */
  Future<void> runInForeground() async{
    return await _channel.invokeMethod('runInForeground');
  }

  /**
   * runInBackground
   */
  Future<void> runInBackground() async{
    return await _channel.invokeMethod('runInBackground');
  }


  /// 暂停
  Future<void> pause() async {
    return await _channel.invokeMethod('pause');
  }

  /// 停止
  Future<void> stopPlayback() async {
    return await _channel.invokeMethod('stopPlayback');
  }

  /// 获得视频时间戳
  Future<int> getRtmpVideoTimestamp() async {
    return await _channel.invokeMethod('getRtmpVideoTimestamp');
  }

  /// 获得音频时间戳
  Future<int> getRtmpAudioTimestamp() async {
    return await _channel.invokeMethod('getRtmpAudioTimestamp');
  }

  /// 暂停/恢复播放器的预缓冲
  Future<void> setBufferingEnabled({
    @required bool enabled,
  }) async {
    return await _channel
        .invokeMethod('setBufferingEnabled', {"enabled": enabled});
  }

  /// 获取已经缓冲的长度
  Future<int> getHttpBufferSize() async {
    return await _channel.invokeMethod('getHttpBufferSize');
  }
}

/// Rtmp播放监听器
class RtmpPlayerListener {
  /// 监听器列表
  static Set<RtmpPlayerListenerValue> listeners = Set();

  RtmpPlayerListener(MethodChannel channel) {
    // 绑定监听器
    channel.setMethodCallHandler((methodCall) async {
      // 解析参数
      Map<String, dynamic> arguments = jsonDecode(methodCall.arguments);

      switch (methodCall.method) {
        case 'onPlayerListener':
          // 获得原始类型和参数
          String typeStr = arguments['type'];
          var params = arguments['params'];

          // 封装回调类型和参数
          RtmpPlayerListenerTypeEnum type;

          // 初始化类型
          for (var item in RtmpPlayerListenerTypeEnum.values) {
            if (item
                    .toString()
                    .replaceFirst("RtmpPlayerListenerTypeEnum.", "") ==
                typeStr) {
              type = item;
              break;
            }
          }

          // 没有找到类型就返回
          if (type == null) {
            throw MissingPluginException();
          }

          // 回调触发
          for (var item in listeners) {
            item(type, params);
          }

          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  /// 添加消息监听
  void addListener(RtmpPlayerListenerValue func) {
    listeners.add(func);
  }

  /// 移除消息监听
  void removeListener(RtmpPlayerListenerValue func) {
    listeners.remove(func);
  }
}

/// 推流监听器值模型
typedef RtmpPlayerListenerValue<P> = void Function(
    RtmpPlayerListenerTypeEnum type, P params);
