//
//  BLHomeBLViewController.m
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/18.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import "BLHomeBLViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface BLHomeBLViewController()<GSBroadcastDelegate, GSBroadcastVideoDelegate, GSBroadcastDesktopShareDelegate, GSBroadcastAudioDelegate>
{
    BOOL videoFullScreen; //视频全屏
    
}
@property (strong, nonatomic)GSBroadcastManager *broadcastManager;
@property (strong, nonatomic)GSVideoView *videoView;
@property (assign, nonatomic)long long userID; // 当前激活的视频ID
@property (assign, nonatomic)BOOL isCameraVideoDisplaying;
@property (assign, nonatomic)BOOL isLodVideoDisplaying;
@property (assign, nonatomic)BOOL isDesktopShareDisplaying;
@property (assign, nonatomic)CGRect originalVideoFrame;
@end
@implementation BLHomeBLViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self checkException];//检测异常
    [self setupUI];//设置UI
    [self initBroadCastManager];//初始化直播管理者
    [self enterBackground];//设置后台运行

}

//设置UI
- (void)setupUI{
    CGFloat y = self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height;
    
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
    if (version < 7.0) {
        y -= 64;
    }
    
    _originalVideoFrame = CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.width - 70);
    self.videoView = [[GSVideoView alloc]initWithFrame:_originalVideoFrame];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleVideoViewTap:)];
    tapGes.numberOfTapsRequired = 2;
    [self.videoView addGestureRecognizer:tapGes];
    self.videoView.videoViewContentMode = GSVideoViewContentModeRatioFill;
    
    [self.view addSubview:self.videoView];

    
    
    
    
    UIButton * videoBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 100, 100, 40)];
    [videoBtn setTitle:@"接收视频" forState:UIControlStateNormal];
    [videoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    videoBtn.backgroundColor = RGB(235, 145, 141);
    [videoBtn addTarget:self action:@selector(clickVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoBtn];
}

-(void)clickVideoBtn:(UIButton *)btn{
    [self.broadcastManager displayVideo:self.userID];//接收视频
//    [self.broadcastManager undisplayVideo:self.userID];//关闭视频
    
    //打开麦克风
//    [self.broadcastManager activateSpeaker];
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
//                                    error:nil];
//    [audioSession setActive:YES error:nil];
    
    //关闭麦克风
//    [self.broadcastManager inactivateSpeaker];
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setActive:NO error:nil];
}

//初始化直播manager
- (void)initBroadCastManager
{
    self.broadcastManager = [GSBroadcastManager sharedBroadcastManager];
    self.broadcastManager.broadcastDelegate = self;
    self.broadcastManager.videoDelegate = self;
    self.broadcastManager.desktopShareDelegate = self;
    self.broadcastManager.audioDelegate = self;
    
    
    if (![_broadcastManager connectBroadcastWithConnectInfo:self.connectInfo]) {
        
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"WrongConnectInfo", @"参数不正确") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"知道了") otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    
}

//设置后台运行
- (void)enterBackground
{
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
}

//关闭直播
- (void)closeBroadcast{
    [self.broadcastManager leaveAndShouldTerminateBroadcast:NO];
    [self.broadcastManager invalidate];
}


#pragma mark ----------------------------------------
#pragma mark -- GSBroadcastManagerDelegate --


// 直播初始化代理
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveBroadcastConnectResult:(GSBroadcastConnectResult)result
{
    switch (result) {
        case GSBroadcastConnectResultSuccess:
            
            // 直播初始化成功，加入直播
            if (![self.broadcastManager join]) {
                
//                [self.progressHUD hide:YES];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:  NSLocalizedString(@"BroadcastConnectionError",  @"直播连接失败提示") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",  @"确认") otherButtonTitles:nil, nil];
                [alertView show];
                
                
            }
            
            break;
            
        case GSBroadcastConnectResultInitFailed:
            break;
        case GSBroadcastConnectResultJoinCastPasswordError:
            break;
        case GSBroadcastConnectResultWebcastIDInvalid:
            break;
        case GSBroadcastConnectResultRoleOrDomainError:
            break;
        case GSBroadcastConnectResultLoginFailed:
            break;
        case GSBroadcastConnectResultNetworkError:
            break;
        case GSBroadcastConnectResultWebcastIDNotFound:
        {
//            [self.progressHUD hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:  NSLocalizedString(@"BroadcastConnectionError",  @"直播连接失败提示") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",  @"确认") otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
            
        case  GSBroadcastConnectResultThirdTokenError:
        {
//            [self.progressHUD hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:  NSLocalizedString(@"第三方K值验证错误",  @"直播连接失败提示") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",  @"确认") otherButtonTitles:nil, nil];
            [alertView show];
        }
            
        default:
//            [self.progressHUD hide:YES];
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:  NSLocalizedString(@"BroadcastConnectionError",  @"直播连接失败提示") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",  @"确认") otherButtonTitles:nil, nil];
            [alertView show];

        }
        break;
    }
}

/*
 直播连接代理
 rebooted为YES，表示这次连接行为的产生是由于根服务器重启而导致的重连
 */
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveBroadcastJoinResult:(GSBroadcastJoinResult)joinResult selfUserID:(long long)userID rootSeverRebooted:(BOOL)rebooted;
{
//    [self.progressHUD hide:YES];
    
    // 服务器重启导致重连
    if (rebooted) {
        // 相应处理
        
    }
    
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.manager =  self.broadcastManager;
}


// 断线重连
- (void)broadcastManagerWillStartRoomReconnect:(GSBroadcastManager*)manager
{
//    [self.progressHUD show:YES];
//    self.progressHUD.labelText = NSLocalizedString(@"Reconnect", @"正在重连");
    
}

- (void)broadcastManager:(GSBroadcastManager *)manager didSetStatus:(GSBroadcastStatus)status
{
    
}

- (void)broadcastManager:(GSBroadcastManager*)manager didSelfLeaveBroadcastFor:(GSBroadcastLeaveReason)leaveReason
{
    [self.broadcastManager invalidate];
//    [self.progressHUD hide:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark ----------------------------------------
#pragma mark -- GSBroadcastVideoDelegate --

// 视频模块连接代理
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveVideoModuleInitResult:(BOOL)result
{
    
}

// 摄像头是否可用代理
- (void)broadcastManager:(GSBroadcastManager*)manager isCameraAvailable:(BOOL)isAvailable
{
    
}

// 摄像头打开代理
- (void)broadcastManagerDidActivateCamera:(GSBroadcastManager*)manager
{
    
}

// 摄像头关闭代理
- (void)broadcastManagerDidInactivateCamera:(GSBroadcastManager*)manager
{
    
}

// 收到一路视频
- (void)broadcastManager:(GSBroadcastManager*)manager didUserJoinVideo:(GSUserInfo *)userInfo
{
    // 收到插播视频
    if (userInfo.userID == LOD_USER_ID) {
        
        // 如果正在播放摄像头视频
        if (self.isCameraVideoDisplaying)
        {
            // 停止播放摄像头视频
            [self.broadcastManager undisplayVideo:self.userID ];
        }
        // 显示插播视频
        [self.broadcastManager displayVideo:userInfo.userID];
        
        self.userID = LOD_USER_ID;
    }
}

// 某个用户退出视频
- (void)broadcastManager:(GSBroadcastManager*)manager didUserQuitVideo:(long long)userID
{
    [self.broadcastManager undisplayVideo:userID];
}

// 某一路摄像头视频被激活
- (void)broadcastManager:(GSBroadcastManager*)manager didSetVideo:(GSUserInfo*)userInfo active:(BOOL)active
{
    if (active && !self.isDesktopShareDisplaying && !self.isLodVideoDisplaying) {
        // 将上一次激活的视频关闭
        [self.broadcastManager undisplayVideo:self.userID];
        
        [self.broadcastManager displayVideo:userInfo.userID];
        self.userID = userInfo.userID;
    }
    
}

// 某一路视频播放代理
- (void)broadcastManager:(GSBroadcastManager*)manager didDisplayVideo:(GSUserInfo*)userInfo
{
    if (self.isDesktopShareDisplaying)
    {
        [self.broadcastManager undisplayVideo:userInfo.userID];
    }
    
    
    if (userInfo.userID == LOD_USER_ID) {
        self.isLodVideoDisplaying = YES;
    }
    else
    {
        self.isCameraVideoDisplaying = YES;
    }
}

// 某一路视频关闭播放代理
- (void)broadcastManager:(GSBroadcastManager*)manager didUndisplayVideo:(long long)userID
{
    if (userID == LOD_USER_ID) {
        self.isLodVideoDisplaying = NO;
    }
    else
    {
        self.isCameraVideoDisplaying = NO;
    }
    
}


// 摄像头或插播视频每一帧的数据代理
- (void)broadcastManager:(GSBroadcastManager*)manager userID:(long long)userID renderVideoFrame:(GSVideoFrame*)videoFrame
{
    // 指定Videoview渲染每一帧数据
    [_videoView renderVideoFrame:videoFrame];
}

#pragma mark ---------------------------------------
#pragma mark -- GSBroadcastDesktopShareDelegate --
//桌面共享代理

// 桌面共享视频连接代理
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveDesktopShareModuleInitResult:(BOOL)result;
{
    
}

// 开启桌面共享代理
- (void)broadcastManager:(GSBroadcastManager*)manager didActivateDesktopShare:(long long)userID
{
    // 停止显示视频
    if (self.isCameraVideoDisplaying)
    {
        [self.broadcastManager undisplayVideo:self.userID];
    }
    
    self.isDesktopShareDisplaying = YES;
}


// 桌面共享视频每一帧的数据代理
- (void)broadcastManager:(GSBroadcastManager*)manager renderDesktopShareFrame:(UIImage*)videoFrame
{
    // 指定Videoview渲染每一帧数据
    //    [self.videoView renderVideoFrame:videoFrame];
    if (self.isDesktopShareDisplaying) {
        [self.videoView renderAsVideoByImage:videoFrame];
    }
    
    
}


// 桌面共享关闭代理
- (void)broadcastManagerDidInactivateDesktopShare:(GSBroadcastManager*)manager
{
    // 显示视频
    [self.broadcastManager displayVideo:self.userID];
    
    self.isDesktopShareDisplaying = NO;
}


#pragma mark ---------------------------------------
#pragma mark -- GSBroadcastAudioDelegate --

// 音频模块连接代理
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveAudioModuleInitResult:(BOOL)result
{
    if (!result) {
        NSLog(@"音频加载失败");
    }
}


#pragma mark ---------------------------------------
#pragma mark -- GSBroadcastDocDelegate --

// 文档模块连接代理
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveDocModuleInitResult:(BOOL)result
{
}

// 文档打开代理
- (void)broadcastManagerDidOpenDocument:(GSBroadcastManager *)manager
{
    
}

// 文档关闭代理
- (void)broadcastManagerDidCloseDocument:(GSBroadcastManager *)manager
{
    
}

// 文档切换代理
- (void)broadcastManagerDidSlideDocument:(GSBroadcastManager*)manager
{
    
}




#pragma mark ----------------------------------------
#pragma mark -- screenFrame method --
//全屏 方法
- (void)handleVideoViewTap:(UITapGestureRecognizer*)recognizer
{
    if (!videoFullScreen)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            self.videoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            
            videoFullScreen = YES;
            
            //            [_receiveAudioBtn setHidden:YES];
            //            [_receiveVideoBtn setHidden:YES];
            //            [_rejectAudioBtn setHidden:YES];
            //            [_rejectVideoBtn setHidden:YES];
            
            self.navigationController.navigationBarHidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(0));
            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
            self.videoView.frame = _originalVideoFrame;
            videoFullScreen = NO;
            //            [_receiveAudioBtn setHidden:NO];
            //            [_receiveVideoBtn setHidden:NO];
            //            [_rejectAudioBtn setHidden:NO];
            //            [_rejectVideoBtn setHidden:NO];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            self.navigationController.navigationBarHidden = NO;
        }];
    }
}
- (void)switchFullScreen:(UIGestureRecognizer*)tapGes
{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation =  !appDelegate.allowRotation;
    
    //强制旋转
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIDeviceOrientationPortrait] forKey:@"orientation"];
        
    } else {
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight ] forKey:@"orientation"];
        
    }
    
}


//自动旋转
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)
interfaceOrientation duration:(NSTimeInterval)duration {
    
    if (!UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        self.videoView.frame = _originalVideoFrame;
        
        //        [_receiveAudioBtn setHidden:NO];
        //        [_receiveVideoBtn setHidden:NO];
        //        [_rejectAudioBtn setHidden:NO];
        //        [_rejectVideoBtn setHidden:NO];
        
    }else {
        
        //        [_receiveAudioBtn setHidden:YES];
        //        [_receiveVideoBtn setHidden:YES];
        //        [_rejectAudioBtn setHidden:YES];
        //        [_rejectVideoBtn setHidden:YES];
        
        CGFloat y = self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height;
        
        double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
        if (version < 7.0) {
            y = 0;
        }
        
        //        int widthP=self.view.frame.size.width;
        //        int heigthP=self.view.frame.size.height;
        //        NSLog(@"%d-%d--%f",widthP,heigthP,y);
        //        y=600
        self.videoView.frame = CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - y);
        
        
    }
    
}



#pragma mark ----------------------------------------
#pragma mark -- AlertView method --
//检测异常
- (void)checkException{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSString *isException= [defaults objectForKey:IsException];
    if ([isException isEqualToString:@"YES"]) {
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:NSLocalizedString(@"错误报告", nil)
         message:@"检测到程序意外终止，是否发送错误报告"
         delegate:self
         cancelButtonTitle:NSLocalizedString(@"忽略", nil)
         otherButtonTitles:NSLocalizedString(@"发送", nil), nil];
        alert.tag=1004;
        [alert show];
    }
    [defaults setObject:@"NO" forKey:IsException];
}
//alert代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==1004){
        
        if (buttonIndex==1) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(){
                
                GSDiagnosisInfo *DiagnosisInfo =[[GSDiagnosisInfo alloc] init];
                [DiagnosisInfo ReportDiagonse];
            });
            
        }else if (buttonIndex==0){
            
        }
    }
}



@end
