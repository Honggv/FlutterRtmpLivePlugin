//
//  PushViewFactory.m
//  Runner
//
//  Created by MAC on 2020/12/25.
//

#import "PushViewFactory.h"
#import "PushView.h"

@implementation PushViewFactory{
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *) messager{
    self = [super init];
    if (self) {
        _messenger = messager;
    }
    return self;
}

-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
   FlutterPushView* view = [[FlutterPushView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
   return view;
}

@end

@implementation FlutterPushView{
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    PushView * _indicator;
}

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        if (frame.size.width==0) {
            frame=CGRectMake(frame.origin.x, frame.origin.y, [UIScreen mainScreen].bounds.size.width, 100);
        }
        
        NSDictionary *dic = args;
        _indicator = [[PushView alloc] initWithFrame:frame];

        NSData *jsonData = [dic[@"streamingProfile"] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *profile = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
         if(err) {
               NSLog(@"json解析失败：%@",err);
               return nil;
        }
        [_indicator initPushWithUrl:profile[@"publishUrl"]];
        
        _viewId = viewId;
        NSString* channelName = [NSString stringWithFormat:@"plugins.com.honggv/RtmpPush_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
    }
    
    return self;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    if ([[call method] isEqualToString:@"resume"]) {
        [_indicator startCapture];
        result(@(YES));
    }else if ([[call method] isEqualToString:@"pause"]) {
        [_indicator stopCapture];
    }else if ([[call method] isEqualToString:@"startStreaming"]) {
        NSString *publishUrl = call.arguments[@"publishUrl"];
        if(publishUrl.class == NSNull.class){
            [_indicator startStream];
        }else{
            [_indicator startStreamWithUrl:publishUrl];
        }
        result(@(YES));
    }else if ([[call method] isEqualToString:@"stopStreaming"]) {
        [_indicator stopStream];
    }else if ([[call method] isEqualToString:@"switchCamera"]) {
        [_indicator onCamera];
    }else if ([[call method] isEqualToString:@"mute"]) {
        [_indicator audioMute:call.arguments[@"mute"]];
    }else if ([[call method] isEqualToString:@"destroy"]) {
        [_indicator UninitPush];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (UIView *)view {
    return _indicator;
}

@end
