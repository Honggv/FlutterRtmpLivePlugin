//
//  PlayerViewFactory.h
//  Runner
//
//  Created by MAC on 2020/12/28.
//

#import <UIKit/UIKit.h>
#import <Flutter/FlutterPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerViewFactory : NSObject<FlutterPlatformViewFactory>
//flutter注册类
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager;

@end

@interface FlutterPlayerView : NSObject<FlutterPlatformView>

- (instancetype)initWithWithFrame:(CGRect)frame
                     viewIdentifier:(int64_t)viewId
                          arguments:(id _Nullable)args
                    binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end


NS_ASSUME_NONNULL_END
