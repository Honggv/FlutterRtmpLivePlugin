//
//  PushView.h
//  Runner
//
//  Created by MAC on 2020/12/28.
//

#import <UIKit/UIKit.h>
#import <libksygpulive/KSYGPUStreamerKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PushView : UIView

@property KSYGPUStreamerKit *kit;
@property GPUImageOutput<GPUImageInput>* curFilter;
@property NSString *pushUrl;

//初始化
- (void)initPushWithUrl:(NSString *)url;
- (void)UninitPush;
//切换摄像机
- (void)onCamera;
//打开预览
- (void)startCapture;
//关闭预览
- (void)stopCapture;
//开启静音
- (void)audioMute:(BOOL)mute;
//打开推流
- (void)startStream;
- (void)startStreamWithUrl:(NSString *)url;
//关闭推流
- (void)stopStream;
@end

NS_ASSUME_NONNULL_END
