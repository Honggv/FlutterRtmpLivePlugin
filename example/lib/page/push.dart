import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rtmp_live_plugin/view/rtmp_push_view.dart';
import 'package:flutter_rtmp_live_plugin/controller/rtmp_push_view_controller.dart';
import 'package:flutter_rtmp_live_plugin/enums/rtmp_push_listener_type_enum.dart';
import 'package:flutter_rtmp_live_plugin/entity/face_beauty_setting_entity.dart';
import 'package:flutter_rtmp_live_plugin/entity/camera_streaming_setting_entity.dart';
import 'package:flutter_rtmp_live_plugin/entity/streaming_profile_entity.dart';
import 'package:flutter_rtmp_live_plugin/enums/rtmp_audio_source_type_enum.dart';

/// 推流界面
class PushPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PushPageState();
}

class PushPageState extends State<PushPage> {
  /// 推流控制器
  RtmpPushViewController controller;

  /// 当前状态
  String status;

  /// 描述信息
  String info;

  /// 连接状态
  String connectedStatus;

  /// 美颜对象
  FaceBeautySettingEntity faceBeautySettingEntity =
      FaceBeautySettingEntity(beautyLevel: 0, redden: 0, whiten: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.pause();
    controller.destroy();
    if (controller != null) {
      controller.removeListener(onListener);
    }
  }

  /// 控制器初始化
  onViewCreated(RtmpPushViewController controller) async {
    this.controller = controller;
    controller.addListener(onListener);
//    bool result = await controller.resume();
//    this.setState(() => info = "预览执行结果: $result");
  }

  /// 监听器
  onListener(type, params) {
    // 状态改变监听
    if (type == RtmpPushListenerTypeEnum.StateChanged) {
      stateChanged(params.toString());
    }

    // 连麦状态改变监听
    if (type == RtmpPushListenerTypeEnum.ConferenceStateChanged) {
      connectedStateChanged(params);
    }
  }

  /// 状态改变事件
  stateChanged(status) async {
    this.setState(() => this.status = status);
  }

  /// 设置连麦状态
  connectedStateChanged(status) async {
    this.setState(() => this.connectedStatus = status);
  }

  /// 获得状态文本描述
  getStatusText(status) {
    if (status == null) {
      return "等待预览";
    }

    switch (status) {
      case "PREPARING":
        return "PREPARING";
      case "READY":
        return "准备就绪";
      case "CONNECTING":
        return "连接中";
      case "STREAMING":
        return "推流中";
      case "SHUTDOWN":
        return "直播中断";
      case "IOERROR":
        return "网络连接失败";
      case "OPEN_CAMERA_FAIL":
        return "摄像头打开失败";
      case "AUDIO_RECORDING_FAIL":
        return "麦克风打开失败";
      case "DISCONNECTED":
        return "已经断开连接";
      case "TORCH_INFO":
        return "可开启闪光灯";
      default:
        return "未绑定事件:$status";
    }
  }

  /// 开始预览事件
  onResume() async {
    bool result = await controller.resume();
    this.setState(() => info = "预览执行结果: $result");
  }

  /// 开始推流事件
  onPush() async {
    bool result = await controller.startStreaming();
    this.setState(() => info = "推流执行结果: $result");
  }

  /// 停止推流事件
  onStopPush() async {
    bool result = await controller.stopStreaming();
    this.setState(() => info = "停止推流执行结果: $result");
  }

  /// 检测是否支持缩放
  onCheckZoomSupported() async {
    bool result = await controller.isZoomSupported();
    if (result) {
      int current = await controller.getZoom();
      int max = await controller.getMaxZoom();
      this.setState(() => info = "缩放检测结果: 支持，当前缩放比例:$current，最大缩放比例:$max");
    } else {
      this.setState(() => info = "缩放检测结果: 不支持");
    }
  }

  /// 设置最大缩放比例
  onSetMaxZoom() async {
    int max = await controller.getMaxZoom();
    await controller.setZoomValue(value: max);
    this.setState(() => info = "缩放比例设置成功:$max");
  }

  /// 重置缩放比例
  onResetZoom() async {
    await controller.setZoomValue(value: 0);
    this.setState(() => info = "缩放比例设置成功:0");
  }

  /// 开启闪光灯
  onTurnLightOn() async {
    bool result = await controller.turnLightOn();
    this.setState(() => info = "开启闪光灯结果: $result");
  }

  /// 关闭闪光灯
  onTurnLightOff() async {
    bool result = await controller.turnLightOff();
    this.setState(() => info = "关闭闪光灯结果: $result");
  }

  /// 切换摄像头
  onSwitchCamera() async {
    bool result = await controller.switchCamera();
    this.setState(() => info = "切换摄像头: $result");
  }

  /// 静音
  onMute(mute) async {
    await controller.mute(
      mute: mute,
      audioSource: RtmpAudioSourceTypeEnum.MIC,
    );
    this.setState(() => info = "已成功执行静音/恢复静音步骤");
  }

  /// 暂停
  onPause() async {
    await controller.pause();
    this.setState(() {
      info = "已成功执行暂停";
      status = null;
    });
  }

  /// 开启美颜
  openBeauty() async {
    await controller.openBeauty();
    this.setState(() => info = "开启美颜");
  }

  /// 关闭美颜
  closeBeauty() async {
    await controller.closeBeauty();
    this.setState(() => info = "关闭美颜");
  }

  /// 销毁
  onDestroy() async {
    await controller.destroy();
    this.setState(() => info = "已成功执行销毁");
  }

  /// 更新美颜信息
  onUpdateFaceBeautySetting() async {
    await controller.updateFaceBeautySetting(faceBeautySettingEntity);
    this.setState(() => info =
        "更新美颜信息成功:${faceBeautySettingEntity.beautyLevel},${faceBeautySettingEntity.redden},${faceBeautySettingEntity.whiten}");
  }

  /// 设置预览镜像
  onSetPreviewMirror(mirror) async {
    bool res = await controller.setPreviewMirror(mirror: mirror);
    this.setState(
        () => info = "预览镜像${mirror ? "打开" : "关闭"}${res ? "成功" : "失败"}");
  }

  /// 设置推流镜像
  onSetEncodingMirror(mirror) async {
    bool res = await controller.setEncodingMirror(mirror: mirror);
    this.setState(
        () => info = "推流镜像${mirror ? "打开" : "关闭"}${res ? "成功" : "失败"}");
  }

  /// 开启耳返
  onStartPlayback() async {
    bool res = await controller.startPlayback();
    this.setState(() => info = "开启耳返${res ? "成功" : "失败"}");
  }

  /// 关闭耳返
  onStopPlayback() async {
    await controller.stopPlayback();
    this.setState(() => info = "关闭执行成功");
  }

  /// 开始连麦
  onStartConference() async {
    try {
      await controller.startConference(
        roomName: "194f98358c934071a20c33431fd71423",
        userId: "af182f7402d74c7d82ea38f5482621b4",
        roomToken:
            "v740N_w0pHblR7KZMSPHhfdqjxrHEv5e_yBaiq0e:rSIkdWuf_h6vUbY46C59XbKkzdo=:eyJyb29tX25hbWUiOiIxOTRmOTgzNThjOTM0MDcxYTIwYzMzNDMxZmQ3MTQyMyIsImV4cGlyZV9hdCI6MTU4MTIwNzQ2NSwicGVybSI6ImFkbWluIiwidmVyc2lvbiI6IjIuMCIsInVzZXJfaWQiOiJhZjE4MmY3NDAyZDc0YzdkODJlYTM4ZjU0ODI2MjFiNCJ9",
      );
      this.setState(() => info = "连麦执行成功");
    } catch (e) {
      this.setState(() => info = "连麦执行失败:$e");
    }
  }

  /// 关闭连麦
  onStopConference() async {
    await controller.stopConference();
    this.setState(() => info = "关闭连麦执行成功");
  }

  /// 获取编码器输出的画面的高宽
  getVideoEncodingSize() async {
    Map<String, dynamic> data = await controller.getVideoEncodingSize();
    this.setState(() => info = "编码器高宽为:${data['height']},${data['width']}");
  }

  /// 连麦视图创建事件
//  onPlayerViewCreated(viewId, playerController) {
//    // 添加到远程视图
//    this.playerController = playerController;
//    controller.addRemoteWindow(id: viewId);
//  }

  /// 设置合流参数
//  onSetAbsoluteMixOverlayRect() {
//    playerController.setAbsoluteMixOverlayRect(
//      x: 0,
//      y: 0,
//      w: 100,
//      h: 100,
//    );
//  }

  /// 自定义推流窗口地址(连麦下有效)
  onSetLocalWindowPosition() {
    controller.setLocalWindowPosition(
      x: 0,
      y: 10,
      w: 50,
      h: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                // RtmpPushView(
                //   cameraStreamingSetting: CameraStreamingSettingEntity(
                //       faceBeauty: faceBeautySettingEntity),
                //   streamingProfile: StreamingProfileEntity(
                //     publishUrl:
                //         "rtmp://live.server.honggv.cn:19130/10000008/1314442321101590529",
                //   ),
                //   onViewCreated: onViewCreated,
                // ),
               Container(
                 width: 130,
                 height: 130,
                 color: Colors.red,
                 child: RtmpPushView(
                  cameraStreamingSetting: CameraStreamingSettingEntity(
                      faceBeauty: faceBeautySettingEntity),
                  streamingProfile: StreamingProfileEntity(
                    publishUrl:
                        "rtmp://chengdu.jianyang.rtmp.xl02.cn:1935/10000008/1314442321101590528",
                  ),
                  onViewCreated: onViewCreated,
                ),
               ),
                Container(
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                      ),
                      Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Text("当前状态:${getStatusText(this.status)}"),
                            Text(info ?? ""),
                            Wrap(
                              children: <Widget>[

                                RaisedButton(
                                  onPressed: this.status == null ? onResume : null,
                                  child: Text("开始预览"),
                                ),
                                RaisedButton(
                                  onPressed: this.status != null ? onPause : null,
                                  child: Text("暂停预览"),
                                ),
                                RaisedButton(
                                  onPressed: this.status == null ? onDestroy : null,
                                  child: Text("销毁资源"),
                                ),
                                RaisedButton(
                                  onPressed: onPush,
                                  child: Text("开始推流"),
                                ),
                                RaisedButton(
                                  onPressed:
                                  this.status == "STREAMING" ? onStopPush : null,
                                  child: Text("停止推流"),
                                ),
                                RaisedButton(
                                  onPressed: onSwitchCamera,
                                  child: Text("切换摄像头"),
                                ),
                                RaisedButton(
                                  onPressed: () => onMute(true),
                                  child: Text("开启静音"),
                                ),
                                RaisedButton(
                                  onPressed: () => onMute(false),
                                  child: Text("恢复声音"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
