package com.honggv.flutter_rtmp_live_plugin.view;


import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.alibaba.fastjson.JSON;
import com.honggv.flutter_rtmp_live_plugin.enums.PlayerCallBackNoticeEnum;
import com.honggv.flutter_rtmp_live_plugin.widget.CameraPreviewFrameView;
import com.ksyun.media.player.IMediaPlayer;
import com.ksyun.media.player.KSYMediaPlayer;
import com.ksyun.media.player.KSYTextureView;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * rtmp播放器视图
 */
public class RtmpPlayerPlatformView extends PlatformViewFactory implements PlatformView, MethodChannel.MethodCallHandler {

    /**
     * 日志标签
     */
    private static final String TAG = RtmpPlayerPlatformView.class.getName();

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
    public static final String SIGN = "plugins.com.honggv/RtmpPlay";

    /**
     * 播放器
     */
    private KSYTextureView view;

    private int mVideoWidth = 0;
    private int mVideoHeight = 0;

    /**
     * 通信管道
     */
    private MethodChannel channel;

    /**
     * 监听器回调的方法名
     */
    private final static String LISTENER_FUNC_NAME = "onPlayerListener";

    /**
     * 初始化视图工厂，注册视图时调用
     */
    public RtmpPlayerPlatformView(Context context, BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.context = context;
        this.messenger = messenger;
    }

    /**
     * 初始化组件，同时也初始化rtmp云推流
     * 每个组件被实例化时调用
     */
    private RtmpPlayerPlatformView(Context context) {
        super(StandardMessageCodec.INSTANCE);
        this.context = context;
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "setDisplayAspectRatio":
                this.setDisplayAspectRatio(call, result);
                break;
            case "start":
                this.start(call, result);
                break;
            case "reStart":
                this.reStart(call, result);
                break;
            case "pause":
                this.pause(call, result);
                break;
            case "stopPlayback":
                this.stopPlayback(call, result);
                break;
            case "getRtmpVideoTimestamp":
                this.getRtmpVideoTimestamp(call, result);
                break;
            case "getRtmpAudioTimestamp":
                this.getRtmpAudioTimestamp(call, result);
                break;
            case "setBufferingEnabled":
                this.setBufferingEnabled(call, result);
                break;
            case "getHttpBufferSize":
                this.getHttpBufferSize(call, result);
                break;
            case "runInForeground":
                this.runInForeground(call, result);
                break;
            case "runInBackground":
                this.runInBackground(call, result);
                break;
            default:
                result.notImplemented();
        }
    }



    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        RtmpPlayerPlatformView view = new RtmpPlayerPlatformView(context);
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
        // 初始化视图
        channel = methodChannel;

        view = new KSYTextureView(context);

        view.setBackgroundColor(context.getResources().getColor(android.R.color.transparent));

        view.setOnBufferingUpdateListener(mOnBufferingUpdateListener);
        view.setOnCompletionListener(mOnCompletionListener);
        view.setOnPreparedListener(mOnPreparedListener);
        view.setOnInfoListener(mOnInfoListener);
        view.setOnVideoSizeChangedListener(mOnVideoSizeChangeListener);
        view.setOnErrorListener(mOnErrorListener);
        view.setOnSeekCompleteListener(mOnSeekCompletedListener);
        view.setOnMessageListener(mOnMessageListener);
//        view.setTimeout(5, 30);
        view.setBufferTimeMax(2);
        view.setBufferSize(15);
        Log.e("=============","初始化");
    }


    private IMediaPlayer.OnPreparedListener mOnPreparedListener = new IMediaPlayer.OnPreparedListener() {
        @Override
        public void onPrepared(IMediaPlayer mp) {
            Log.d("VideoPlayer", "OnPrepared");
            mVideoWidth = view.getVideoWidth();
            mVideoHeight = view.getVideoHeight();

            // Set Video Scaling Mode
            view.setVideoScalingMode(KSYMediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING);

            //start player
            view.start();

        }
    };

    private IMediaPlayer.OnBufferingUpdateListener mOnBufferingUpdateListener = new IMediaPlayer.OnBufferingUpdateListener() {
        @Override
        public void onBufferingUpdate(IMediaPlayer mp, int percent) {
            long duration = view.getDuration();
            long progress = duration * percent / 100;
        }
    };

    private IMediaPlayer.OnVideoSizeChangedListener mOnVideoSizeChangeListener = new IMediaPlayer.OnVideoSizeChangedListener() {
        @Override
        public void onVideoSizeChanged(IMediaPlayer mp, int width, int height, int sarNum, int sarDen) {
            if (mVideoWidth > 0 && mVideoHeight > 0) {
                if (width != mVideoWidth || height != mVideoHeight) {
                    mVideoWidth = mp.getVideoWidth();
                    mVideoHeight = mp.getVideoHeight();

                    if (view != null)
                        view.setVideoScalingMode(KSYMediaPlayer.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING);
                }
            }
        }
    };

    private IMediaPlayer.OnSeekCompleteListener mOnSeekCompletedListener = new IMediaPlayer.OnSeekCompleteListener() {
        @Override
        public void onSeekComplete(IMediaPlayer mp) {
            Log.e(TAG, "onSeekComplete...............");
        }
    };

    private IMediaPlayer.OnCompletionListener mOnCompletionListener = new IMediaPlayer.OnCompletionListener() {
        @Override
        public void onCompletion(IMediaPlayer mp) {

//            videoPlayEnd();
        }
    };

    private IMediaPlayer.OnErrorListener mOnErrorListener = new IMediaPlayer.OnErrorListener() {
        @Override
        public boolean onError(IMediaPlayer mp, int what, int extra) {
            switch (what) {
                //case KSYVideoView.MEDIA_ERROR_UNKNOWN:
                // Log.e(TAG, "OnErrorListener, Error Unknown:" + what + ",extra:" + extra);
                //  break;
                default:
                    Log.e(TAG, "OnErrorListener, Error:" + what + ",extra:" + extra);
            }

//            videoPlayEnd();

            invokeListener(PlayerCallBackNoticeEnum.Error, what);

            return false;
        }
    };

    /**
     * 调用监听器
     *
     * @param type   类型
     * @param params 参数
     */
    private void invokeListener(final PlayerCallBackNoticeEnum type, final Object params) {
        Map<String, Object> resultParams = new HashMap<>(2, 1);
        resultParams.put("type", type);
        resultParams.put("params", params == null ? null : JSON.toJSONString(params));
        channel.invokeMethod(LISTENER_FUNC_NAME, JSON.toJSONString(resultParams));
    }

    public IMediaPlayer.OnInfoListener mOnInfoListener = new IMediaPlayer.OnInfoListener() {
        @Override
        public boolean onInfo(IMediaPlayer iMediaPlayer, int i, int i1) {
            switch (i) {
                case KSYMediaPlayer.MEDIA_INFO_BUFFERING_START:
                    Log.d(TAG, "Buffering Start.");
                    break;
                case KSYMediaPlayer.MEDIA_INFO_BUFFERING_END:
                    Log.d(TAG, "Buffering End.");
                    break;
                case KSYMediaPlayer.MEDIA_INFO_AUDIO_RENDERING_START:
//                    Toast.makeText(mContext, "Audio Rendering Start", Toast.LENGTH_SHORT).show();
                    break;
                case KSYMediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START:
//                    Toast.makeText(mContext, "Video Rendering Start", Toast.LENGTH_SHORT).show();
                    break;
                case KSYMediaPlayer.MEDIA_INFO_RELOADED:
//                    Toast.makeText(mContext, "Succeed to reload video.", Toast.LENGTH_SHORT).show();
                    Log.d(TAG, "Succeed to mPlayerReload video.");
                    return false;
            }
            invokeListener(PlayerCallBackNoticeEnum.Info, i);
            return false;
        }
    };

    private IMediaPlayer.OnMessageListener mOnMessageListener = new IMediaPlayer.OnMessageListener() {
        @Override
        public void onMessage(IMediaPlayer iMediaPlayer, Bundle bundle) {
            Log.e(TAG, "name:" + bundle.toString());
        }
    };

    private void videoPlayEnd() {
        if (view != null) {
            view.release();
            view = null;
        }
    }
















    /**
     * 设置画面预览模式
     */
    private void setDisplayAspectRatio(MethodCall call, MethodChannel.Result result) {
//        int mode = CommonUtil.getParam(call, result, "mode");
//        view.setDisplayAspectRatio(mode);
//        result.success(null);
    }

    /**
     * 播放
     */
    private void start(MethodCall call, MethodChannel.Result result) {
        String url = call.argument("url");
        Log.e("=============","调用开始"+url);

        if (url != null) {
            try {
                Log.e("======111111=======","");
                view.setDataSource(url);
            } catch (IOException e) {
                Log.e("======222222=======","");
                e.printStackTrace();
            }
            Log.e("======3333333=======","");
            view.prepareAsync();
        }

        view.start();
        result.success(null);
    }

    //重连
    private void reStart(MethodCall call, MethodChannel.Result result) {
        String url = call.argument("url");
        Log.e("=============","调用开始"+url);

        if (url != null) {
//            try {
//                Log.e("======111111=======","");
//                view.setDataSource(url);
//            } catch (IOException e) {
//                Log.e("======222222=======","");
//                e.printStackTrace();
//            }
//            Log.e("======3333333=======","");
//            view.prepareAsync();


            view.reload(url,true);
        }
        result.success(null);
    }


    /**
     * 暂停
     */
    private void pause(MethodCall call, MethodChannel.Result result) {
        view.pause();
        result.success(null);
    }

    /**
     * runInForeground
     */
    private void runInForeground(MethodCall call, MethodChannel.Result result) {
        view.runInForeground();

        result.success(null);
    }

    /**
     * runInBackground
     */
    private void runInBackground(MethodCall call, MethodChannel.Result result) {
        view.setComeBackFromShare(true);
        view.runInBackground(true);
        result.success(null);
    }

    /**
     * 停止播放
     */
    private void stopPlayback(MethodCall call, MethodChannel.Result result) {
        if (view != null) {
            view.stop();
            view.release();
            view = null;
        }
        result.success(null);
    }

    /**
     * 在RTMP消息中获取视频时间戳
     */
    private void getRtmpVideoTimestamp(MethodCall call, MethodChannel.Result result) {
//        result.success(view.getRtmpVideoTimestamp());
    }

    /**
     * 在RTMP消息中获取音频时间戳
     */
    private void getRtmpAudioTimestamp(MethodCall call, MethodChannel.Result result) {
//        result.success(view.getRtmpAudioTimestamp());
    }

    /**
     * 暂停/恢复播放器的预缓冲
     */
    private void setBufferingEnabled(MethodCall call, MethodChannel.Result result) {
//        boolean enabled = CommonUtil.getParam(call, result, "enabled");
//        view.setBufferingEnabled(enabled);
//        result.success(null);
    }

    /**
     * 获取已经缓冲的长度
     */
    private void getHttpBufferSize(MethodCall call, MethodChannel.Result result) {
//        result.success(view.getHttpBufferSize().longValue());
    }
}
