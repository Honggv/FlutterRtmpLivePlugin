#import "FlutterRtmpPlugin.h"
#import "PushViewFactory.h"
#import "PlayerViewFactory.h"

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<shared_preferences/SharedPreferencesPlugin.h>)
#import <shared_preferences/SharedPreferencesPlugin.h>
#else
@import shared_preferences;
#endif

@implementation FlutterRtmpPlugin

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
    [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
    [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
    [FlutterRtmpPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterRtmpLivePlugin"]];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [registrar registerViewFactory:[[PushViewFactory alloc] initWithMessenger:registrar.messenger] withId:@"plugins.com.honggv/RtmpPush"];
    [registrar registerViewFactory:[[PlayerViewFactory alloc] initWithMessenger:registrar.messenger] withId:@"plugins.com.honggv/RtmpPlay"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
