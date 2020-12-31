//
//  PushView.m
//  Runner
//
//  Created by MAC on 2020/12/28.
//

#import "PushView.h"

@implementation PushView


#pragma mark -------推流 -------

- (void)initPushWithUrl:(NSString *)url{
    if (!_kit){
        _kit = [[KSYGPUStreamerKit alloc] init];
    }
    //摄像头位置
    _kit.cameraPosition = AVCaptureDevicePositionFront;
    //视频输出格式
    _kit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    //采集格式
    _kit.capturePixelFormat   = kCVPixelFormatType_32BGRA;
    //设置背景颜色
    [self setBackgroundColor:[UIColor blackColor]];

    _curFilter = [[KSYGPUBeautifyExtFilter alloc] init];

    //增加回掉
    [self addObserver];
    
    _pushUrl = url;
}

- (void)UninitPush{
    [self removeObserver];
    [_kit stopPreview];
    _kit = nil;
}

//切换前后摄像头
- (void)onCamera{
    [_kit switchCamera];
}

- (void)startCapture{
    if (!_kit.vCapDev.isRunning){
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit setupFilter:_curFilter];
        [_kit startPreview:self]; //启动预览
    }
}

- (void)stopCapture{
    if (_kit.vCapDev.isRunning){
        [_kit stopPreview];
    }
}

- (void)audioMute:(BOOL)mute{
    if(mute){
        _kit.audioCaptureType = KSYAudioCap_AVCaptureDevice;
    }else{
        _kit.audioCaptureType = KSYAudioCap_AudioUnit;
    }
}

- (void)startStream{
    [self startStreamWithUrl:_pushUrl];
}

- (void)startStreamWithUrl:(NSString *)url {
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError){
        //启动推流
        [_kit.streamerBase startStream: [NSURL URLWithString:url]];
    }
}

- (void)stopStream{
    [_kit.streamerBase stopStream];
}

- (void)addObserver{ //监听推流状态改变的通知
    NSNotificationCenter * dc = [NSNotificationCenter defaultCenter] ;
    [dc addObserver:self
           selector:@selector(streamStateChanged)
               name:KSYStreamStateDidChangeNotification
             object:nil];
}
- (void)removeObserver{//移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)streamStateChanged{
    switch (_kit.streamerBase.streamState) {
        case KSYStreamStateIdle:
//        _streamState.text = @"空闲状态";
        break;
        case KSYStreamStateConnecting:
//        _streamState.text = @"连接中";
        break;
        case KSYStreamStateConnected:
//        _streamState.text = @"已连接";
        break;
        case KSYStreamStateDisconnecting:
//        _streamState.text = @"失去连接";
        break;
        case KSYStreamStateError:
//        _streamState.text = @"连接错误";
        break;
        default:
        break;
    }
}

@end
