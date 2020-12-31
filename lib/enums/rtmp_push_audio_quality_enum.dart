/// Rtmp推流音频质量
enum RtmpPushAudioQualityEnum {
  AUDIO_QUALITY_96,
  AUDIO_QUALITY_128,
}

/// 枚举工具类
class RtmpPushAudioQualityTool {
  // 将枚举转换为int类型
  static int toInt(RtmpPushAudioQualityEnum type) {
    switch (type) {
      case RtmpPushAudioQualityEnum.AUDIO_QUALITY_96:
        return 20;
      case RtmpPushAudioQualityEnum.AUDIO_QUALITY_128:
        return 21;
      default:
        return null;
    }
  }
}
