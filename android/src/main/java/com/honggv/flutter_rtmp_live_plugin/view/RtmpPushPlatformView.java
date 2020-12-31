package com.honggv.flutter_rtmp_live_plugin.view;


import android.Manifest;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.view.View;

import androidx.core.app.ActivityCompat;

import com.alibaba.fastjson.JSON;
import com.honggv.flutter_rtmp_live_plugin.entity.StreamingProfile;
import com.honggv.flutter_rtmp_live_plugin.util.CommonUtil;
import com.ksyun.media.streamer.capture.CameraCapture;
import com.ksyun.media.streamer.encoder.Encoder;
import com.ksyun.media.streamer.encoder.VideoEncodeFormat;
import com.ksyun.media.streamer.filter.imgtex.ImgTexFilterBase;
import com.ksyun.media.streamer.filter.imgtex.ImgTexFilterMgt;
import com.ksyun.media.streamer.framework.AVConst;
import com.ksyun.media.streamer.kit.KSYStreamer;
import com.ksyun.media.streamer.kit.StreamerConstants;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import com.honggv.flutter_rtmp_live_plugin.widget.CameraPreviewFrameView;
import com.ksyun.media.streamer.util.device.DeviceInfo;
import com.ksyun.media.streamer.util.device.DeviceInfoTools;

/**
 * 推流视图
 */
public class RtmpPushPlatformView extends PlatformViewFactory implements PlatformView, MethodChannel.MethodCallHandler {

    /**
     * 日志标签
     */
    private static final String TAG = RtmpPushPlatformView.class.getName();

    /**
     * 全局上下文
     */
    private Context context;

    /**
     * 消息器
     */
    private BinaryMessenger messenger;

    /**
     * 全局标识
     */
    public static final String SIGN = "plugins.com.honggv/RtmpPush";

    /**
     * 本地预览内容
     */
    private CameraPreviewFrameView view;

    /**
     * 流管理器
     */
    private KSYStreamer mStreamer;

    protected Handler mMainHandler;
    protected String mBgImagePath = "assets://bg.jpg";
    protected boolean mHWEncoderUnsupported;
    protected boolean mSWEncoderUnsupported;
    protected BaseStreamConfig mConfig;

    /**
     * 初始化视图工厂，注册视图时调用
     */
    public RtmpPushPlatformView(Context context, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.context = context;
        this.messenger = messenger;
    }

    /**
     * 初始化组件，同时也初始化rtmp云推流
     * 每个组件被实例化时调用
     */
    private RtmpPushPlatformView(Context context) {
        super(StandardMessageCodec.INSTANCE);
        this.context = context;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "resume":
                handleOnResume();
                Log.e(TAG, "resume 预览");
                break;
            case "pause":
                handleOnPause();
                Log.e(TAG, "pause 暂停");
                break;
            case "startStreaming":
                mStreamer.startStream();
                Log.e(TAG, "startStreaming 开始推流");
                break;
            case "stopStreaming":
                mStreamer.stopStream();
                Log.e(TAG, "stopStreaming 停止推流");
                break;
            case "destroy":
                mStreamer.stopRecord();
                mStreamer.stopCameraPreview();
                mStreamer.stopBgm();
                mStreamer.stopImageCapture();
                mStreamer.stopStream();
                Log.e(TAG, "destroy mStreamer销毁");
                // 清理相关资源
                if (mMainHandler != null) {
                    mMainHandler.removeCallbacksAndMessages(null);
                    mMainHandler = null;
                }
                mStreamer.release();
                break;
            case "switchCamera":
                mStreamer.switchCamera();
                Log.e(TAG, "switchCamera 切换摄像头");
                break;
            case "openBeauty":
                // 设置美颜滤镜，关于美颜滤镜的具体说明请参见专题说明以及完整版demo
                mStreamer.getImgTexFilterMgt().setFilter(mStreamer.getGLRender(),
                        ImgTexFilterMgt.KSY_FILTER_BEAUTY_PRO3);
                Log.e(TAG, "openBeauty 开启美颜");
                break;
            case "closeBeauty":
                // 设置美颜滤镜，关于美颜滤镜的具体说明请参见专题说明以及完整版demo
                mStreamer.getImgTexFilterMgt().setFilter(mStreamer.getGLRender(),
                        ImgTexFilterMgt.KSY_FILTER_BEAUTY_DISABLE);
                Log.e(TAG, "closeBeauty 关闭美颜");
                break;
//            case "mute":
//                this.mute(call, result);
//                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        RtmpPushPlatformView view = new RtmpPushPlatformView(context);
        // 绑定方法监听器
        MethodChannel methodChannel = new MethodChannel(messenger, SIGN + "_" + viewId);
        methodChannel.setMethodCallHandler(view);
        // 初始化
        view.init(params, methodChannel);
        return view;
    }

    @Override
    public void dispose() {

    }

    @Override
    public View getView() {
        return view;
    }

    /**
     * 初始化
     *
     * @param params        参数
     * @param methodChannel 方法通道
     */
    private void init(Map<String, Object> params, MethodChannel methodChannel) {
        // 相机参数
        String cameraSettingStr = (String) params.get("cameraStreamingSetting");
        Map<String, Object> cameraSettingMap = JSON.parseObject(cameraSettingStr);
        // 推流参数(仅主播)
        String streamingProfileStr = (String) params.get("streamingProfile");
        StreamingProfile streamingProfile = JSON.parseObject(streamingProfileStr, StreamingProfile.class);
        Log.e(TAG, "推流参数(仅主播): "+streamingProfile.getPublishUrl());
        // 初始化视图
        view = new CameraPreviewFrameView(context);
        view.setBackgroundColor(context.getResources().getColor(android.R.color.transparent));
        mStreamer = new KSYStreamer(context);

        mMainHandler = new Handler();

        mConfig = getConfig(streamingProfile.getPublishUrl());

        mStreamer.setUrl(streamingProfile.getPublishUrl());

        mStreamer.setVideoCodecId(AVConst.CODEC_ID_AVC);

        // 设置推流分辨率
        mStreamer.setPreviewResolution(mConfig.mTargetResolution);
        mStreamer.setTargetResolution(mConfig.mTargetResolution);

        mStreamer.setAudioChannels(2);
        // 设置编码方式（硬编、软编）
        mStreamer.setEncodeMethod(mConfig.mEncodeMethod);
        // 硬编模式下默认使用高性能模式(high profile)
        if (mConfig.mEncodeMethod == StreamerConstants.ENCODE_METHOD_HARDWARE) {
            mStreamer.setVideoEncodeProfile(VideoEncodeFormat.ENCODE_PROFILE_HIGH_PERFORMANCE);
        }

        // 设置推流帧率
        if (mConfig.mFrameRate > 0) {
            mStreamer.setPreviewFps(mConfig.mFrameRate);
            mStreamer.setTargetFps(mConfig.mFrameRate);
        }

        // 设置推流视频码率，三个参数分别为初始码率、最高码率、最低码率
        int videoBitrate = mConfig.mVideoKBitrate;
        if (videoBitrate > 0) {
            mStreamer.setVideoKBitrate(videoBitrate * 3 / 4, videoBitrate, videoBitrate / 4);
        }

        // 设置音频码率
        if (mConfig.mAudioKBitrate > 0) {
            mStreamer.setAudioKBitrate(mConfig.mAudioKBitrate);
        }

        // 设置视频方向（横屏、竖屏）
        mStreamer.setRotateDegrees(0);

        // 选择前后摄像头
        mStreamer.setCameraFacing(mConfig.mCameraFacing);

        // 设置预览View
        mStreamer.setDisplayPreview(view);

//        mStreamer.setPreviewResolution(720,1280);

        // 设置回调处理函数
        mStreamer.setOnInfoListener(mOnInfoListener);
        mStreamer.setOnErrorListener(mOnErrorListener);
        // 禁用后台推流时重复最后一帧的逻辑（这里我们选择切后台使用背景图推流的方式）
        mStreamer.setEnableRepeatLastFrame(false);
        mStreamer.enableDebugLog(true);

        // 设置美颜滤镜的错误回调，当前机型不支持该滤镜时禁用美颜
        mStreamer.getImgTexFilterMgt().setOnErrorListener(new ImgTexFilterBase.OnErrorListener() {
            @Override
            public void onError(ImgTexFilterBase filter, int errno) {
                Log.e(TAG, "init: 当前机型不支持该滤镜!");
                mStreamer.getImgTexFilterMgt().setFilter(mStreamer.getGLRender(),
                        ImgTexFilterMgt.KSY_FILTER_BEAUTY_DISABLE);
            }
        });
        // 设置美颜滤镜，关于美颜滤镜的具体说明请参见专题说明以及完整版demo
        mStreamer.getImgTexFilterMgt().setFilter(mStreamer.getGLRender(),
                ImgTexFilterMgt.KSY_FILTER_BEAUTY_PRO3);

    }

    protected BaseStreamConfig getConfig(String url) {
        mConfig = new BaseStreamConfig();
        mConfig.mFrameRate = 15.0f;
        mConfig.mVideoKBitrate = 800;
        mConfig.mAudioKBitrate = 48;
        mConfig.mUrl = url;
        // video frame rate
        mConfig.mCameraFacing = CameraCapture.FACING_FRONT;
        mConfig.mTargetResolution = StreamerConstants.VIDEO_RESOLUTION_720P;
        mConfig.mOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
        // orientation

        // encode method ENCODE_METHOD_HARDWARE
//        if (isHw264EncoderSupported()) {
//            mConfig.mEncodeMethod = StreamerConstants.ENCODE_METHOD_HARDWARE;
//        } else {
            mConfig.mEncodeMethod = StreamerConstants.ENCODE_METHOD_SOFTWARE;
//        }
//        mConfig.mEncodeMethod = StreamerConstants.ENCODE_METHOD_SOFTWARE_COMPAT;

        mConfig.mAutoStart = true;
        mConfig.mShowDebugInfo = false;

        return mConfig;
    }

    protected boolean isHw264EncoderSupported() {
        DeviceInfo deviceInfo = DeviceInfoTools.getInstance().getDeviceInfo();
        if (deviceInfo != null) {
            Log.i(TAG, "deviceInfo:" + deviceInfo.printDeviceInfo());
            return deviceInfo.encode_h264 == DeviceInfo.ENCODE_HW_SUPPORT;
        }
        return false;
    }

    protected void handleOnResume() {
        // 调用KSYStreamer的onResume接口
        mStreamer.onResume();
        // 停止背景图采集
        mStreamer.stopImageCapture();
        mStreamer.setEnableAudioNS(true);
        // 开启摄像头采集
        startCameraPreviewWithPermCheck();
        // 如果onPause中切到了DummyAudio模块，可以在此恢复
        mStreamer.setUseDummyAudioCapture(false);
    }

    protected void handleOnPause() {
        // 调用KSYStreamer的onPause接口
        mStreamer.onPause();
        // 停止摄像头采集，然后开启背景图采集，以实现后台背景图推流功能
        mStreamer.stopCameraPreview();
        mStreamer.startImageCapture(mBgImagePath);
        // 如果希望App切后台后，停止录制主播端的声音，可以在此切换为DummyAudio采集，
        // 该模块会代替mic采集模块产生静音数据，同时释放占用的mic资源
        mStreamer.setUseDummyAudioCapture(true);
    }

    protected void startCameraPreviewWithPermCheck() {
        int cameraPerm = ActivityCompat.checkSelfPermission(context, Manifest.permission.CAMERA);
        int audioPerm = ActivityCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO);
        if (cameraPerm != PackageManager.PERMISSION_GRANTED ||
                audioPerm != PackageManager.PERMISSION_GRANTED) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                Log.e(TAG, "No CAMERA or AudioRecord permission, please check");
            } else {
                String[] permissions = {Manifest.permission.CAMERA,
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.READ_PHONE_STATE};
                Log.e(TAG, "申请权限");
//                ActivityCompat.requestPermissions(this, permissions,
//                        PERMISSION_REQUEST_CAMERA_AUDIOREC);
            }
        } else {
            mStreamer.startCameraPreview();
        }
    }

    private KSYStreamer.OnInfoListener mOnInfoListener = new KSYStreamer.OnInfoListener() {
        @Override
        public void onInfo(int what, int msg1, int msg2) {
            onStreamerInfo(what, msg1, msg2);
        }
    };

    private KSYStreamer.OnErrorListener mOnErrorListener = new KSYStreamer.OnErrorListener() {
        @Override
        public void onError(int what, int msg1, int msg2) {
            onStreamerError(what, msg1, msg2);
        }
    };

    protected void onStreamerInfo(int what, int msg1, int msg2) {
        Log.d(TAG, "OnInfo: " + what + " msg1: " + msg1 + " msg2: " + msg2);
        switch (what) {
            case StreamerConstants.KSY_STREAMER_CAMERA_INIT_DONE:
                Log.d(TAG, "KSY_STREAMER_CAMERA_INIT_DONE");
                break;
            case StreamerConstants.KSY_STREAMER_CAMERA_FACING_CHANGED:
                Log.d(TAG, "KSY_STREAMER_CAMERA_FACING_CHANGED");
                // check is flash torch mode supported
                break;
            case StreamerConstants.KSY_STREAMER_OPEN_STREAM_SUCCESS:
                Log.d(TAG, "KSY_STREAMER_OPEN_STREAM_SUCCESS");
                break;
            case StreamerConstants.KSY_STREAMER_FRAME_SEND_SLOW:
                Log.d(TAG, "KSY_STREAMER_FRAME_SEND_SLOW " + msg1 + "ms");
                break;
            case StreamerConstants.KSY_STREAMER_EST_BW_RAISE:
                Log.d(TAG, "BW raise to " + msg1 / 1000 + "kbps");
                break;
            case StreamerConstants.KSY_STREAMER_EST_BW_DROP:
                Log.d(TAG, "BW drop to " + msg1 / 1000 + "kpbs");
                break;
            default:
                break;
        }
    }

    protected void onStreamerError(int what, int msg1, int msg2) {
        Log.e(TAG, "streaming error: what=" + what + " msg1=" + msg1 + " msg2=" + msg2);
        switch (what) {
            case StreamerConstants.KSY_STREAMER_AUDIO_RECORDER_ERROR_START_FAILED:
            case StreamerConstants.KSY_STREAMER_AUDIO_RECORDER_ERROR_UNKNOWN:
                break;
            case StreamerConstants.KSY_STREAMER_CAMERA_ERROR_UNKNOWN:
            case StreamerConstants.KSY_STREAMER_CAMERA_ERROR_START_FAILED:
            case StreamerConstants.KSY_STREAMER_CAMERA_ERROR_EVICTED:
            case StreamerConstants.KSY_STREAMER_CAMERA_ERROR_SERVER_DIED:
                mStreamer.stopCameraPreview();
                break;
            case StreamerConstants.KSY_STREAMER_VIDEO_ENCODER_ERROR_UNSUPPORTED:
            case StreamerConstants.KSY_STREAMER_VIDEO_ENCODER_ERROR_UNKNOWN:
                handleEncodeError();
            default:
                reStreaming(what);
                break;
        }
    }

    protected void reStreaming(int err) {
        mStreamer.stopStream();
        mMainHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                mStreamer.startStream();
                Log.e(TAG, "直播重连");
            }
        }, 1500);
    }

    protected void handleEncodeError() {
        int encodeMethod = mStreamer.getVideoEncodeMethod();
        if (encodeMethod == StreamerConstants.ENCODE_METHOD_HARDWARE) {
            mHWEncoderUnsupported = true;
            if (mSWEncoderUnsupported) {
                mStreamer.setEncodeMethod(
                        StreamerConstants.ENCODE_METHOD_SOFTWARE_COMPAT);
                Log.e(TAG, "Got HW encoder error, switch to SOFTWARE_COMPAT mode");
            } else {
                mStreamer.setEncodeMethod(StreamerConstants.ENCODE_METHOD_SOFTWARE);
                Log.e(TAG, "Got HW encoder error, switch to SOFTWARE mode");
            }
        } else if (encodeMethod == StreamerConstants.ENCODE_METHOD_SOFTWARE) {
            mSWEncoderUnsupported = true;
            mStreamer.setEncodeMethod(StreamerConstants.ENCODE_METHOD_SOFTWARE_COMPAT);
            Log.e(TAG, "Got SW encoder error, switch to SOFTWARE_COMPAT mode");
        }
    }

//    /**
//     * 打开摄像头和麦克风采集
//     */
//    private void resume(MethodCall call, final MethodChannel.Result result) {
//        result.success(manager.startCapture());
//    }
//
//
//    /**
//     * 关闭摄像头和麦克风采集
//     */
//    private void pause(MethodCall call, final MethodChannel.Result result) {
//        manager.stopCapture();
//        result.success(null);
//    }
//
//    /**
//     * 开始推流
//     */
//    private void startStreaming(MethodCall call, final MethodChannel.Result result) {
//        String publishUrl = call.argument("publishUrl");
//        if (publishUrl != null) {
//            try {
//                streamingProfile.setPublishUrl(publishUrl);
//            } catch (URISyntaxException e) {
//                Log.e(TAG, "setStreamingProfile: setPublishUrl Error", e);
//                result.error("0", e.toString(), e.getMessage());
//                return;
//            }
//            manager.setStreamingProfile(streamingProfile);
//        }
//        result.success(manager.startStreaming());
//    }
//
//    /**
//     * 停止推流
//     */
//    private void stopStreaming(MethodCall call, final MethodChannel.Result result) {
//        result.success(manager.stopStreaming());
//    }
//
//    /**
//     * 销毁
//     */
//    private void destroy(MethodCall call, final MethodChannel.Result result) {
//        manager.destroy();
//        result.success(null);
//    }
//
//    /**
//     * 查询是否支持缩放
//     */
//    private void isZoomSupported(MethodCall call, final MethodChannel.Result result) {
//        result.success(manager.isZoomSupported());
//    }
//
//    /**
//     * 设置缩放比例
//     */
//    private void setZoomValue(MethodCall call, final MethodChannel.Result result) {
//        int value = CommonUtil.getParam(call, result, "value");
//        manager.setZoomValue(value);
//        result.success(null);
//    }
//
//    /**
//     * 获得最大缩放比例
//     */
//    private void getMaxZoom(MethodCall call, final MethodChannel.Result result) {
//        result.success(manager.getMaxZoom());
//    }
//
//    /**
//     * 获得缩放比例
//     */
//    private void getZoom(MethodCall call, final MethodChannel.Result result) {
//        result.success(manager.getZoom());
//    }
//
//    /**
//     * 开启闪光灯
//     */
//    private void turnLightOn(MethodCall call, final MethodChannel.Result result) {
//        result.success(manager.turnLightOn());
//    }
//
//    /**
//     * 关闭闪光灯
//     */
//    private void turnLightOff(MethodCall call, final MethodChannel.Result result) {
//        result.success(manager.turnLightOff());
//    }
//
//    /**
//     * 切换摄像头
//     */
//    private void switchCamera(MethodCall call, final MethodChannel.Result result) {
//        CameraStreamingSetting.CAMERA_FACING_ID id;
//        if(cameraStreamingSetting.getCameraFacingId() == CameraStreamingSetting.CAMERA_FACING_ID.CAMERA_FACING_FRONT){
//            id = CameraStreamingSetting.CAMERA_FACING_ID.CAMERA_FACING_BACK;
//        }else{
//            id = CameraStreamingSetting.CAMERA_FACING_ID.CAMERA_FACING_FRONT;
//        }
//        cameraStreamingSetting.setCameraFacingId(id);
//        result.success(manager.switchCamera(id));
//    }
//
//    /**
//     * 切换静音
//     */
//    private void mute(MethodCall call, final MethodChannel.Result result) {
//        boolean mute = CommonUtil.getParam(call, result, "mute");
//        String audioSource = CommonUtil.getParam(call, result, "audioSource");
//        if (mute) {
//            manager.mute(RTCAudioSource.valueOf(audioSource));
//        } else {
//            manager.unMute(RTCAudioSource.valueOf(audioSource));
//
//        }
//        result.success(null);
//    }
//
//    /**
//     * 更新推流参数
//     */
//    private void setStreamingProfile(MethodCall call, final MethodChannel.Result result) {
//        this.streamingProfile = JSON.parseObject(CommonUtil.getParam(call, result, "streamingProfile").toString(), StreamingProfile.class);
//        manager.setStreamingProfile(streamingProfile);
//        result.success(null);
//    }
//
//    /**
//     * 设置预览镜像
//     */
//    private void setPreviewMirror(MethodCall call, final MethodChannel.Result result) {
//        boolean mirror = CommonUtil.getParam(call, result, "mirror");
//        result.success(manager.setPreviewMirror(mirror));
//    }
//
//    /**
//     * 设置推流镜像
//     */
//    private void setEncodingMirror(MethodCall call, final MethodChannel.Result result) {
//        boolean mirror = CommonUtil.getParam(call, result, "mirror");
//        result.success(manager.setEncodingMirror(mirror));
//    }
//
//    /**
//     * 更新美颜设置
//     */
//    private void updateFaceBeautySetting(MethodCall call, final MethodChannel.Result result) {
//        double beautyLevel = CommonUtil.getParam(call, result, "beautyLevel");
//        double redden = CommonUtil.getParam(call, result, "redden");
//        double whiten = CommonUtil.getParam(call, result, "whiten");
//        manager.setVideoFilterType(CameraStreamingSetting.VIDEO_FILTER_TYPE.VIDEO_FILTER_BEAUTY);
//
//        CameraStreamingSetting.FaceBeautySetting faceBeautySetting = new CameraStreamingSetting.FaceBeautySetting((float) beautyLevel, (float) whiten, (float) redden);
//        cameraStreamingSetting.setFaceBeautySetting(faceBeautySetting);
//        manager.updateFaceBeautySetting(faceBeautySetting);
//        result.success(null);
//    }

    public static class BaseStreamConfig {
        public String mUrl;
        public int mCameraFacing;
        public float mFrameRate;
        public int mVideoKBitrate;
        public int mAudioKBitrate;
        public int mTargetResolution;
        public int mOrientation;
        public int mEncodeMethod;
        public boolean mAutoStart;
        public boolean mShowDebugInfo;

    }
}
