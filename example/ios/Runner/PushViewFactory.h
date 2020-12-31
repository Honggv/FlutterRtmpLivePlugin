//
//  PushView.h
//  Runner
//
//  Created by MAC on 2020/12/25.
//

#import <UIKit/UIKit.h>
#import <Flutter/FlutterPlugin.h>

NS_ASSUME_NONNULL_BEGIN

@interface PushViewFactory :NSObject<FlutterPlatformViewFactory>
//flutter注册类
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager;

@end

@interface FlutterPushView : NSObject<FlutterPlatformView>

- (instancetype)initWithWithFrame:(CGRect)frame
                     viewIdentifier:(int64_t)viewId
                          arguments:(id _Nullable)args
                    binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

NS_ASSUME_NONNULL_END
