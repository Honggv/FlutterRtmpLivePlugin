//
//  PlayerView.h
//  Runner
//
//  Created by MAC on 2020/12/25.
//

#import <UIKit/UIKit.h>
#import <libksygpulive/KSYMoviePlayerController.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerView : UIView
@property (strong, nonatomic) KSYMoviePlayerController *player;


-(void)InitWithUrl:(NSString *)aURL;

-(void)Unint;

-(void)reStart:(NSString *)aURL;

-(void)stop;

-(void)setRectWithCGRect:(CGRect)re;

@end

NS_ASSUME_NONNULL_END
