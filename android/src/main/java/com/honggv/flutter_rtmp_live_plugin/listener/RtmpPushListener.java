package com.honggv.flutter_rtmp_live_plugin.listener;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import com.alibaba.fastjson.JSON;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import com.honggv.flutter_rtmp_live_plugin.enums.PushCallBackNoticeEnum;

/**
 * rtmp推流监听器
 *
 */
public class RtmpPushListener {

    /**
     * 日志标签
     */
    private static final String TAG = RtmpPushListener.class.getName();

    /**
     * 监听器回调的方法名
     */
    private final static String LISTENER_FUNC_NAME = "onPushListener";

    /**
     * 全局上下文
     */
    private Context context;

    /**
     * 通信管道
     */
    private MethodChannel channel;

    public RtmpPushListener(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;
    }

    /**
     * 调用监听器
     *
     * @param type   类型
     * @param params 参数
     */
    private void invokeListener(final PushCallBackNoticeEnum type, final Object params) {
        // 切换到主线程
        Handler mainHandler = new Handler(Looper.getMainLooper());
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                Map<String, Object> resultParams = new HashMap<>(2, 1);
                resultParams.put("type", type);
                resultParams.put("params", params == null ? null : JSON.toJSONString(params));
                channel.invokeMethod(LISTENER_FUNC_NAME, JSON.toJSONString(resultParams));
            }
        });
    }

//    @Override
//    public void onConferenceStateChanged(RTCConferenceState rtcConferenceState, int i) {
//        Map<String, Object> params = new HashMap<>(2, 1);
//        params.put("status", rtcConferenceState);
//        params.put("extra", i);
//        invokeListener(PushCallBackNoticeEnum.ConferenceStateChanged, params);
//    }


}
