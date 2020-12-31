//
//  PlayerView.m
//  Runner
//
//  Created by MAC on 2020/12/25.
//

#import "PlayerView.h"

@implementation PlayerView{
    BOOL reloading;
}

-(void)setRectWithCGRect:(CGRect) re{
    if(_player){
        self.frame = re;
        [_player.view setFrame: re];
    }
}

-(void)reStart:(NSString *)aURL{
    [_player stop];
    [_player setUrl:[NSURL URLWithString:aURL]];
    [_player prepareToPlay];
}

-(void)stop{
    [_player stop];
}

-(void)Unint{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player stop];
    _player = nil;
}

-(void)InitWithUrl:(NSString *)aURL{
    //初始化播放器并设置播放地址
   self.player = [[KSYMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:aURL]];
   [self addSubview:self.player.view];
   [self setupObservers:_player];
   _player.controlStyle = MPMovieControlStyleNone;
   _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    //视频解码模式
    self.player.videoDecoderMode = MPMovieVideoDecoderMode_AUTO;
    //
    self.player.scalingMode = MPMovieScalingModeFill;
    //是否自动播放
    self.player.shouldAutoplay = true;
    //
    self.player.deinterlaceMode = MPMovieVideoDeinterlaceMode_Auto;
    self.player.shouldLoop = false;
    self.player.bInterruptOtherAudio = false;
    
    [self.player setTimeout:30 readTimeout:3];


//   NSKeyValueObservingOptions opts = NSKeyValueObservingOptionNew;
//   [_player addObserver:self forKeyPath:@"currentPlaybackTime" options:opts context:nil];
//   [_player addObserver:self forKeyPath:@"clientIP" options:opts context:nil];
//   [_player addObserver:self forKeyPath:@"localDNSIP" options:opts context:nil];
   [_player prepareToPlay];
}


- (void)registerObserver:(NSString *)notification player:(KSYMoviePlayerController*)player {
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(notification)
                                              object:player];
}

- (void)setupObservers:(KSYMoviePlayerController*)player {
    [self registerObserver:MPMediaPlaybackIsPreparedToPlayDidChangeNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackStateDidChangeNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackDidFinishNotification player:player];
    [self registerObserver:MPMoviePlayerLoadStateDidChangeNotification player:player];
    [self registerObserver:MPMovieNaturalSizeAvailableNotification player:player];
    [self registerObserver:MPMoviePlayerFirstVideoFrameRenderedNotification player:player];
    [self registerObserver:MPMoviePlayerFirstAudioFrameRenderedNotification player:player];
    [self registerObserver:MPMoviePlayerSuggestReloadNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackStatusNotification player:player];
    [self registerObserver:MPMoviePlayerNetworkStatusChangeNotification player:player];
    [self registerObserver:MPMoviePlayerSeekCompleteNotification player:player];
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        if(_player.shouldAutoplay == NO)
            [_player play];
        NSString* serverIp = [_player serverAddress];
        NSLog(@"KSYPlayerVC: %@ -- ip:%@", [[_player contentURL] absoluteString], serverIp);
        reloading = NO;
    }else if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        NSLog(@"------------------------");
        NSLog(@"player playback state: %ld", (long)_player.playbackState);
        NSLog(@"------------------------");
    }else if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
        NSLog(@"player load state: %ld", (long)_player.loadState);
        if (MPMovieLoadStateStalled & _player.loadState) {
            NSLog(@"player start caching");
        }
        if (_player.bufferEmptyCount &&
            (MPMovieLoadStatePlayable & _player.loadState ||
             MPMovieLoadStatePlaythroughOK & _player.loadState)){
                NSLog(@"player finish caching");
                NSString *message = [[NSString alloc]initWithFormat:@"loading occurs, %d - %0.3fs",
                                     (int)_player.bufferEmptyCount,
                                     _player.bufferEmptyDuration];
                NSLog(message);
            }
    }else if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        NSLog(@"player finish state: %ld", (long)_player.playbackState);
        NSLog(@"player download flow size: %f MB", _player.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_player.bufferEmptyCount,
              _player.bufferEmptyDuration);
    }else if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        NSLog(@"video size %.0f-%.0f, rotate:%ld\n", _player.naturalSize.width, _player.naturalSize.height, (long)_player.naturalRotate);
        if(((_player.naturalRotate / 90) % 2  == 0 && _player.naturalSize.width > _player.naturalSize.height) ||
           ((_player.naturalRotate / 90) % 2 != 0 && _player.naturalSize.width < _player.naturalSize.height))
        {
            //如果想要在宽大于高的时候横屏播放，你可以在这里旋转
        }
    }else if (MPMoviePlayerFirstVideoFrameRenderedNotification == notify.name) {
       
    }else if (MPMoviePlayerFirstAudioFrameRenderedNotification == notify.name)    {
        
    }else if (MPMoviePlayerSuggestReloadNotification == notify.name){
        NSLog(@"suggest using reload function!\n");
        if(!reloading)
        {
            reloading = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
                if (_player) {
                    NSLog(@"reload stream");
//                    [_player reload:_reloadUrl flush:YES mode:MPMovieReloadMode_Accurate];
                }
            });
        }
    }else if(MPMoviePlayerPlaybackStatusNotification == notify.name){
        int status = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackStatusUserInfoKey] intValue];
        if(MPMovieStatusVideoDecodeWrong == status)
            NSLog(@"Video Decode Wrong!\n");
        else if(MPMovieStatusAudioDecodeWrong == status)
            NSLog(@"Audio Decode Wrong!\n");
        else if (MPMovieStatusHWCodecUsed == status )
            NSLog(@"Hardware Codec used\n");
        else if (MPMovieStatusSWCodecUsed == status )
            NSLog(@"Software Codec used\n");
        else if(MPMovieStatusDLCodecUsed == status)
            NSLog(@"AVSampleBufferDisplayLayer  Codec used");
    }else if(MPMoviePlayerNetworkStatusChangeNotification == notify.name){
        int currStatus = [[[notify userInfo] valueForKey:MPMoviePlayerCurrNetworkStatusUserInfoKey] intValue];
        int lastStatus = [[[notify userInfo] valueForKey:MPMoviePlayerLastNetworkStatusUserInfoKey] intValue];
    }else if(MPMoviePlayerSeekCompleteNotification == notify.name) {
        NSLog(@"Seek complete");
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
