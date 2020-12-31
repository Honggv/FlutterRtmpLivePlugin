/// Rtmp播放 画面预览模式
enum RtmpPlayerDisplayAspectRatioEnum {
  ASPECT_RATIO_ORIGIN,
  ASPECT_RATIO_PAVED_PARENT,
  ASPECT_RATIO_16_9,
  ASPECT_RATIO_4_3,
}

/// 枚举工具类
class RtmpPlayerDisplayAspectRatioEnumTool {
  // 将枚举转换为int类型
  static int toInt(RtmpPlayerDisplayAspectRatioEnum type) {
    switch (type) {
      case RtmpPlayerDisplayAspectRatioEnum.ASPECT_RATIO_ORIGIN:
        return 0;
      case RtmpPlayerDisplayAspectRatioEnum.ASPECT_RATIO_PAVED_PARENT:
        return 2;
      case RtmpPlayerDisplayAspectRatioEnum.ASPECT_RATIO_16_9:
        return 3;
      case RtmpPlayerDisplayAspectRatioEnum.ASPECT_RATIO_4_3:
        return 4;
      default:
        return null;
    }
  }
}
