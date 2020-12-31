package com.honggv.flutter_rtmp_live_plugin.widget;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;

public class CameraPreviewFrameView extends GLSurfaceView {
    private static final String TAG = "CameraPreviewFrameView";

//    private CameraPreviewRenderer renderer;

    public interface Listener {
        boolean onSingleTapUp(MotionEvent e);
        boolean onZoomValueChanged(float factor);
    }

    private Listener mListener;
    private ScaleGestureDetector mScaleDetector;
    private GestureDetector mGestureDetector;

    public CameraPreviewFrameView(Context context) {
        super(context);

//        renderer = new CameraPreviewRenderer();
//        this.setRenderer(renderer);
        initialize(context);
    }

    public CameraPreviewFrameView(Context context, AttributeSet attrs) {
        super(context, attrs);
//        renderer = new CameraPreviewRenderer();
//        this.setRenderer(renderer);
        initialize(context);
    }

    public void setListener(Listener listener) {
        mListener = listener;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        //由于CameraPreviewRenderer对象运行在另一个线程中，这里采用跨线程的机制进行处理。使用queueEvent方法
        //当然也可以使用其他像Synchronized来进行UI线程和渲染线程进行通信。
        this.queueEvent(new Runnable() {

            @Override
            public void run() {

            }
        });
//        if (!mGestureDetector.onTouchEvent(event)) {
//            return mScaleDetector.onTouchEvent(event);
//        }
        return true;
    }

    private GestureDetector.SimpleOnGestureListener mGestureListener = new GestureDetector.SimpleOnGestureListener() {
        @Override
        public boolean onSingleTapUp(MotionEvent e) {
            if (mListener != null) {
                mListener.onSingleTapUp(e);
            }
            return false;
        }
    };

    private ScaleGestureDetector.SimpleOnScaleGestureListener mScaleListener = new ScaleGestureDetector.SimpleOnScaleGestureListener() {

        private float mScaleFactor = 1.0f;

        @Override
        public boolean onScaleBegin(ScaleGestureDetector detector) {
            return true;
        }

        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            // factor > 1, zoom
            // factor < 1, pinch
            mScaleFactor *= detector.getScaleFactor();

            // Don't let the object get too small or too large.
            mScaleFactor = Math.max(0.01f, Math.min(mScaleFactor, 1.0f));

            return mListener != null && mListener.onZoomValueChanged(mScaleFactor);
        }
    };

    private void initialize(Context context) {
        mScaleDetector = new ScaleGestureDetector(context, mScaleListener);
        mGestureDetector = new GestureDetector(context, mGestureListener);
    }
}
