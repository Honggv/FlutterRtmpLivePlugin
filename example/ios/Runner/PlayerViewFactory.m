//
//  PlayerViewFactory.m
//  Runner
//
//  Created by MAC on 2020/12/28.
//

#import "PlayerViewFactory.h"
#import "PlayerView.h"

@implementation PlayerViewFactory{
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
   FlutterPlayerView* view = [[FlutterPlayerView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
   return view;
}

@end

@implementation FlutterPlayerView{
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    PlayerView * _indicator;
}

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        _indicator = [[PlayerView alloc] initWithFrame:frame];
        [_indicator setRectWithCGRect:frame];
        
        _viewId = viewId;
        NSString* channelName = [NSString stringWithFormat:@"plugins.com.honggv/RtmpPlay_%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall *  call, FlutterResult  result) {
            [weakSelf onMethodCall:call result:result];
        }];
    }
    
    return self;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    if ([[call method] isEqualToString:@"start"]) {
        [_indicator InitWithUrl:call.arguments[@"url"]];
    }else if ([[call method] isEqualToString:@"reStart"]){
        [_indicator reStart:call.arguments[@"url"]];
    }else if ([[call method] isEqualToString:@"stopPlayback"]){
        [_indicator Unint];
    }else if ([[call method] isEqualToString:@"pause"]){
        [_indicator stop];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (UIView *)view {
    return _indicator;
}

@end


