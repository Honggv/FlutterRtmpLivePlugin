/// Rtmp播放器监听类型枚举
enum RtmpPlayerListenerTypeEnum {
  /// 播放结束
  Completion,

  /// 错误事件
  Error,

  /// 状态消息
  Info,

  /// 已经准备好
  Prepared,

  /// 该回调用于监听当前播放的视频流的尺寸信息，在 SDK 解析出视频的尺寸信息后，会触发该回调，开发者可以在该回调中调整 UI 的视图尺寸。
  VideoSizeChanged
}
