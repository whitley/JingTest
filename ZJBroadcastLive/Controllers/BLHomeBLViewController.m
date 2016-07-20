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
#import "BLChatMessageInfo.h"
#import "BLChatTableViewCell.h"

@interface BLHomeBLViewController()<GSBroadcastDelegate, GSBroadcastVideoDelegate, GSBroadcastDesktopShareDelegate, GSBroadcastAudioDelegate, GSBroadcastDocumentDelegate, GSBroadcastChatDelegate, GSBroadcastQaDelegate, UITableViewDelegate, UITableViewDataSource>
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
//中间导航
@property (nonatomic, strong)UIButton *docBtn;
@property (nonatomic, strong)UIButton *chatBtn;
@property (nonatomic, strong)UIButton *questionBtn;
@property (nonatomic ,strong)UILabel *btnlineLabel;//按钮底部白线
//文档
@property (strong, nonatomic)GSDocView *docView;
//聊天
@property (nonatomic, strong)UIView *chatBackView;
@property (nonatomic, strong)UITableView *chatTableView;
@property (nonatomic, strong)NSMutableArray *chatMessage;
@property (nonatomic, assign)long long myUserID;
@property (nonatomic, strong)NSDictionary *key2fileDic;
@property (nonatomic, strong)NSDictionary *text2keyDic;

//问答
@property (nonatomic, strong)UIView * questionBackView;
@property (nonatomic, strong)UITableView *questionTableView;
@property (nonatomic, strong)NSMutableDictionary *questionsDic;
@property (nonatomic, strong)NSMutableArray *questionArray;
@end
@implementation BLHomeBLViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(200, 200, 200);
    self.chatMessage = [NSMutableArray array];
    self.questionsDic = [NSMutableDictionary dictionary];
    self.questionArray = [NSMutableArray array];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RtSDK" ofType:@"bundle"]];
    _key2fileDic = [NSDictionary dictionaryWithContentsOfFile:[resourceBundle pathForResource:@"key2file" ofType:@"plist"]];
    _text2keyDic = [NSDictionary dictionaryWithContentsOfFile:[resourceBundle pathForResource:@"text2key" ofType:@"plist"]];
    
    [self checkException];//检测异常
    [self setupUI];//设置UI
    [self initBroadCastManager];//初始化直播管理者
    [self enterBackground];//设置后台运行

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBarHidden = YES;

}


#pragma mark ---------------------------------
#pragma mark -- UI setting --

/*
 * 设置UI
 */
- (void)setupUI{
    //直播视图
    [self createVideoView];
    
    //中间导航区域
    [self createMiddleNaviView];
    
    //文档视图
    [self createDocView];

    //聊天视图
    [self createChatView];
    
    //问答视图
    [self createQuestionView];

}


/*
 * 初始化 中间导航区域
 */
- (void)createMiddleNaviView{
    //中间导航区域
    UIView * selectInfoView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight/2-40, kScreenWidth, 40)];
    selectInfoView.backgroundColor = RGB(80, 80, 80);
    [self.view addSubview:selectInfoView];
    //文档按钮
    self.docBtn = [[UIButton alloc]initWithFrame:CGRectMake(40, 0, 40, 38)];
    self.docBtn.backgroundColor = [UIColor clearColor];
    [self.docBtn setTitle:@"文档" forState:UIControlStateNormal];
    [self.docBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.docBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [self.docBtn addTarget:self action:@selector(clickDocBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //聊天按钮
    self.chatBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.docBtn.frame.size.width+self.docBtn.frame.origin.x+20, 0, 40, 38)];
    self.chatBtn.backgroundColor = [UIColor clearColor];
    [self.chatBtn setTitle:@"聊天" forState:UIControlStateNormal];
    [self.chatBtn setTitleColor:RGB(170, 170, 170) forState:UIControlStateNormal];
    self.chatBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.chatBtn addTarget:self action:@selector(clickChatBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //问答按钮
    self.questionBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.chatBtn.frame.size.width+self.chatBtn.frame.origin.x+20, 0, 40, 38)];
    self.questionBtn.backgroundColor = [UIColor clearColor];
    [self.questionBtn setTitle:@"问答" forState:UIControlStateNormal];
    [self.questionBtn setTitleColor:RGB(170, 170, 170) forState:UIControlStateNormal];
    self.questionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.questionBtn addTarget:self action:@selector(clickQuestionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [selectInfoView addSubview:self.docBtn];
    [selectInfoView addSubview:self.chatBtn];
    [selectInfoView addSubview:self.questionBtn];
    
    //白线
    self.btnlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(40+2, 38, 36, 2)];
    self.btnlineLabel.backgroundColor = [UIColor whiteColor];
    [selectInfoView addSubview:self.btnlineLabel];

    
    UIButton * videoBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-100, 5, 70, 30)];
    [videoBtn setTitle:@"接收视频" forState:UIControlStateNormal];
    [videoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    videoBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    videoBtn.backgroundColor = RGB(235, 145, 141);
    [videoBtn addTarget:self action:@selector(clickVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectInfoView addSubview:videoBtn];
    
}

/*
 * 初始化直播视图
 */
- (void)createVideoView{
    _originalVideoFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2 - 40);
    
    //直播视图
    self.videoView = [[GSVideoView alloc]initWithFrame:_originalVideoFrame];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleVideoViewTap:)];
    tapGes.numberOfTapsRequired = 2;
    [self.videoView addGestureRecognizer:tapGes];
    self.videoView.videoViewContentMode = GSVideoViewContentModeRatioFit;
    [self.view addSubview:self.videoView];
    
    
}

/*
 * 初始化文档视图
 */
- (void)createDocView{
    self.docView = [[GSDocView alloc]initWithFrame:CGRectMake(0, self.videoView.frame.origin.y+self.videoView.frame.size.height+40, self.view.frame.size.width, self.view.frame.size.height/2)];
    self.docView.zoomEnabled = YES;
    self.docView.fullMode = NO;
    self.docView.hidden = NO;
    [self.docView setGlkBackgroundColor:200 green:200 blue:200];
    self.docView.backgroundColor = RGB(150, 150, 150);
    [self.view addSubview:self.docView];
}

/*
 * 初始化聊天视图
 */
- (void)createChatView{
    self.chatBackView = [[UIView alloc]initWithFrame:CGRectMake(0, self.videoView.frame.origin.y+self.videoView.frame.size.height+40, self.view.frame.size.width, self.view.frame.size.height/2)];
    self.chatBackView.backgroundColor = RGB(200, 200, 200);
    self.chatBackView.hidden = YES;
    [self.view addSubview:self.chatBackView];
    
    self.chatTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.chatBackView.frame.size.height - 50)];
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    [self.chatBackView addSubview:self.chatTableView];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTableViewTap:)];
    ges.numberOfTouchesRequired = 1;
    [self.chatTableView addGestureRecognizer:ges];

}
/*
 * 初始化问答视图
 */
- (void)createQuestionView{
    self.questionBackView = [[UIView alloc]initWithFrame:CGRectMake(0, self.videoView.frame.origin.y+self.videoView.frame.size.height+40, self.view.frame.size.width, self.view.frame.size.height/2)];
    self.questionBackView.backgroundColor = RGB(200, 200, 200);
    self.questionBackView.hidden = YES;
    [self.view addSubview:self.questionBackView];
    
    self.questionTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 52)];
    self.questionTableView.dataSource = self;
    self.questionTableView.delegate = self;
    [self.questionBackView addSubview:self.questionTableView];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTableViewTap:)];
    ges.numberOfTouchesRequired = 1;
    [self.questionTableView addGestureRecognizer:ges];
}

#pragma mark --------------------------------------
#pragma mark -- UITableViewDelegate --

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatMessage.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    BLChatTableViewCell *chatCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!chatCell) {
        chatCell = [[BLChatTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        chatCell.key2fileDic = _key2fileDic;
        
    }
    
    BLChatMessageInfo *messageInfo = self.chatMessage[indexPath.row];
    [chatCell setContent:messageInfo];
    
    return chatCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = ((BLChatMessageInfo*)_chatMessage[indexPath.row]).message.richText;
    int height = [self heightOfText:[self transfromString2:text] width:self.view.frame.size.width - 20 fontSize:12.f];
    return height + 40 + 25;
}


#pragma mark --------------------------------------
#pragma mark -- click method --

//点击文档按钮
- (void)clickDocBtn:(UIButton *)btn{
    [self.docBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.docBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.btnlineLabel.frame = CGRectMake(self.docBtn.frame.origin.x+2, 38, 36, 2);
    
    
    [self.chatBtn setTitleColor:RGB(170, 170, 170) forState:UIControlStateNormal];
    self.chatBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.questionBtn setTitleColor:RGB(170, 170, 170) forState:UIControlStateNormal];
    self.questionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    self.docView.hidden = NO;
    self.chatBackView.hidden = YES;
    self.questionBackView.hidden = YES;
    
}

//点击聊天按钮
- (void)clickChatBtn:(UIButton *)btn{
    [self.chatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.chatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.btnlineLabel.frame = CGRectMake(self.chatBtn.frame.origin.x+2, 38, 36, 2);
    
    [self.docBtn setTitleColor:RGB(170, 170, 170) forState:UIControlStateNormal];
    self.docBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.questionBtn setTitleColor:RGB(170, 170, 170) forState:UIControlStateNormal];
    self.questionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    self.docView.hidden = YES;
    self.chatBackView.hidden = NO;
    self.questionBackView.hidden = YES;
}

//点击问答按钮
- (void)clickQuestionBtn:(UIButton *)btn{
    [self.questionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.questionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.btnlineLabel.frame = CGRectMake(self.questionBtn.frame.origin.x+2, 38, 36, 2);
    
    [self.docBtn setTitleColor:RGB(170, 170, 170) forState:UIControlStateNormal];
    self.docBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.chatBtn setTitleColor:RGB(170, 170, 170) forState:UIControlStateNormal];
    self.chatBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    self.docView.hidden = YES;
    self.chatBackView.hidden = YES;
    self.questionBackView.hidden = NO;
    
}
//点击手势
- (void)handleTableViewTap:(UITapGestureRecognizer*)ges{
//    [_inputToolView endEditting];
}

//点击接收视频
- (void)clickVideoBtn:(UIButton *)btn{
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

#pragma mark --------------------------------------
#pragma mark -- broadcast setting --


//初始化直播manager
- (void)initBroadCastManager
{
    self.broadcastManager = [GSBroadcastManager sharedBroadcastManager];
    
    self.broadcastManager.documentView = self.docView;
    self.broadcastManager.broadcastDelegate = self;
    self.broadcastManager.videoDelegate = self;
    self.broadcastManager.desktopShareDelegate = self;
    self.broadcastManager.audioDelegate = self;
    self.broadcastManager.documentDelegate = self;
    self.broadcastManager.chatDelegate = self;
    self.broadcastManager.qaDelegate = self;
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
            
        case GSBroadcastConnectResultJoinCastPasswordError:
            
        case GSBroadcastConnectResultWebcastIDInvalid:
            
        case GSBroadcastConnectResultRoleOrDomainError:
            
        case GSBroadcastConnectResultLoginFailed:
            
        case GSBroadcastConnectResultNetworkError:
            
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
        {
//            [self.progressHUD hide:YES];
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
#pragma mark -- GSBroadcastChatDelegate --
// 聊天模块连接代理
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceiveChatModuleInitResult:(BOOL)result
{
    
}

// 收到私人聊天代理, 只有自己能看到。
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceivePrivateMessage:(GSChatMessage*)msg fromUser:(GSUserInfo*)user
{
    [self receiveChatMessage:msg from:user messageType:ChatMessageTypePrivate];
}

// 收到公共聊天代理，所有人都能看到
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceivePublicMessage:(GSChatMessage*)msg fromUser:(GSUserInfo*)user
{
    [self receiveChatMessage:msg from:user messageType:ChatMessageTypePublic];
}

// 收到嘉宾聊天代理
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceivePanelistMessage:(GSChatMessage*)msg fromUser:(GSUserInfo*)user
{
    [self receiveChatMessage:msg from:user messageType:ChatMessageTypePanelist];
}

// 针对个人禁止或允许聊天/问答 状态改变代理，如果想设置整个房间禁止聊天，请用其他的代理
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didSetChattingEnabled:(BOOL)enabled
{
    
}

#pragma mark ----------------------------------------
#pragma mark -- GSBroadcastQaDelegate --

// 问答模块连接代理
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didReceiveQaModuleInitResult:(BOOL)result
{
    
}

// 问答设置状态改变代理
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager didSetQaEnabled:(BOOL)enabled QuestionAutoDispatch:(BOOL)autoDispatch QuestionAutoPublish:(BOOL)autoPublish
{
    
}

// 问题的状态改变代理，包括收到一个新问题，问题被发布，取消发布等
- (void)broadcastManager:(GSBroadcastManager*)broadcastManager question:(GSQuestion*)question updatesOnStatus:(GSQaStatus)status
{
    switch (status) {
        case GSQaStatusNewAnswer:
        {
            if ([self.questionArray containsObject:question.questionID]) {
                
                [self.questionsDic setObject:question forKey:question.questionID];
                NSUInteger index = [_questionArray indexOfObject:question.questionID];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:question.answers.count - 1 inSection:index];
                NSMutableArray *indexPaths = [NSMutableArray array];
                [indexPaths addObject:indexPath];
                [self.questionTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                
            }
            
        }
            
            break;
            
        case GSQaStatusQuestionPublish:
        {
            [self.questionsDic setObject:question forKey:question.questionID];
            
            if (![_questionArray containsObject:question.questionID]) {
                
                [_questionArray addObject:question.questionID];
                
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:self.questionArray.count - 1];
//                NSLog(@"iOSDemo: insertSection: %d", self.questionArray.count - 1);
                [self.questionTableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                
            }
            
        }
            break;
            
            
        case GSQaStatusQuestionCancelPublish:
        {
            
            [self.questionsDic removeObjectForKey:question.questionID];
            
            if ([self.questionArray containsObject:question.questionID]) {
                
                NSUInteger index = [self.questionArray indexOfObject:question.questionID];
                
                [self.questionArray removeObjectAtIndex:index];
                
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
                
                [self.questionTableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                
            }
        }
            
            break;
            
        case GSQaStatusNewQuestion:
        {
            // 如果是自己提的问题，可以看到，如果是别人提的问题，要发布了才能看到
            if (question.ownerID == _myUserID) {
                
                [self.questionsDic setObject:question forKey:question.questionID];
                
                if (![_questionArray containsObject:question.questionID]) {
                    
                    [_questionArray addObject:question.questionID];
                    
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:self.questionArray.count - 1];
//                    NSLog(@"iOSDemo: insertSection: %d", self.questionArray.count - 1);
                    [self.questionTableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                    
                }
            }
        }
            break;
            
            
            
            
        default:
            break;
    }
}

#pragma mark ----------------------------------------
#pragma mark -- Utilities --

- (CGFloat)heightOfText:(NSString*)content width:(CGFloat)width fontSize:(CGFloat)fontSize
{
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize  size = [content sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    return MAX(size.height, 20);
}

- (NSString*)transfromString2:(NSString*)originalString
{
    //匹配表情，将表情转化为html格式
    NSString *text = originalString;
    //【伤心】
    //NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    
    NSRegularExpression* preRegex = [[NSRegularExpression alloc]
                                     initWithPattern:@"<IMG.+?src=\"(.*?)\".*?>"
                                     options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                     error:nil]; //2
    NSArray* matches = [preRegex matchesInString:text options:0
                                           range:NSMakeRange(0, [text length])];
    int offset = 0;
    
    for (NSTextCheckingResult *match in matches) {
        //NSRange srcMatchRange = [match range];
        NSRange imgMatchRange = [match rangeAtIndex:0];
        imgMatchRange.location += offset;
        
        NSString *imgMatchString = [text substringWithRange:imgMatchRange];
        
        
        NSRange srcMatchRange = [match rangeAtIndex:1];
        srcMatchRange.location += offset;
        
        NSString *srcMatchString = [text substringWithRange:srcMatchRange];
        
        NSString *i_transCharacter = [self.key2fileDic objectForKey:srcMatchString];
        if (i_transCharacter) {
            NSString *imageHtml =@"表情表情表情";//表情占位，用于计算文本长度
            text = [text stringByReplacingCharactersInRange:NSMakeRange(imgMatchRange.location, [imgMatchString length]) withString:imageHtml];
            offset += (imageHtml.length - imgMatchString.length);
        }
        
    }
    
    //返回转义后的字符串
    return text;
    
}


- (void)receiveChatMessage:(GSChatMessage*)msg from:(GSUserInfo*)user messageType:(ChatMessageType)messageType
{
    
    BLChatMessageInfo *messageInfo = [BLChatMessageInfo new];
    
    if (messageType == ChatMessageTypeFromMe) {
        messageInfo.senderName = NSLocalizedString(@"Me", @"我");
        messageInfo.senderID = _myUserID;
    }
    else if (messageType == ChatMessageTypeSystem)
    {
        messageInfo.senderName = NSLocalizedString(@"System", @"系统消息");
    }
    else
    {
        messageInfo.senderID = user.userID;
        messageInfo.senderName = user.userName;
    }
    
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    NSDate *curDate = [NSDate date];//获取当前日期
    [formater setDateFormat:@"HH:mm:ss"];//这里去掉 具体时间 保留日期
    NSString *curTime = [formater stringFromDate:curDate];
    messageInfo.receiveTime = curTime;
    
    messageInfo.messageType = messageType;
    
    messageInfo.message = msg;
    
    [self.chatMessage addObject:messageInfo];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatMessage.count - 1 inSection:0];
    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexPaths addObject:indexPath];
    [self.chatTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}


- (NSString*)chatString:(NSString*)originalStr
{
    
    NSArray *textTailArray =  [[NSArray alloc]initWithObjects: @"【太快了】", @"【太慢了】", @"【赞同】", @"【反对】", @"【鼓掌】", @"【值得思考】",nil];
    
    NSRegularExpression* preRegex = [[NSRegularExpression alloc]
                                     initWithPattern:@"【([\u4E00-\u9FFF]*?)】"
                                     options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                     error:nil]; //2
    NSArray* matches = [preRegex matchesInString:originalStr options:0
                                           range:NSMakeRange(0, [originalStr length])];
    
    int offset = 0;
    
    for (NSTextCheckingResult *match in matches) {
        //NSRange srcMatchRange = [match range];
        NSRange emotionRange = [match rangeAtIndex:0];
        emotionRange.location += offset;
        
        NSString *emotionString = [originalStr substringWithRange:emotionRange];
        
        NSString *i_transCharacter = [_text2keyDic objectForKey:emotionString];
        if (i_transCharacter) {
            NSString *imageHtml = nil;
            if([textTailArray containsObject:emotionString])
            {
                imageHtml = [NSString stringWithFormat:@"<IMG src=\"%@\" custom=\"false\">%@", i_transCharacter, emotionString];
            }
            else
            {
                imageHtml = [NSString stringWithFormat:@"<IMG src=\"%@\" custom=\"false\">", i_transCharacter];
            }
            originalStr = [originalStr stringByReplacingCharactersInRange:NSMakeRange(emotionRange.location, [emotionString length]) withString:imageHtml];
            offset += (imageHtml.length - emotionString.length);
            
        }
        
    }
    
    
    NSMutableString *richStr = [[NSMutableString alloc]init];
    [richStr appendString:@"<SPAN style=\"FONT-SIZE: 10pt; FONT-WEIGHT: normal; COLOR: #000000; FONT-STYLE: normal\">"];
    [richStr appendString:originalStr];
    [richStr appendString:@"</SPAN>"];
    
    return richStr;
    
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
          
            self.navigationController.navigationBarHidden = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.transform = CGAffineTransformInvert(CGAffineTransformMakeRotation(0));
            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
            self.videoView.frame = _originalVideoFrame;
            videoFullScreen = NO;
            
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
        
    }else {
        
        CGFloat y = self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height;
        
        double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
        if (version < 7.0) {
            y = 0;
        }
        
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

//判定导航栏高度
- (CGFloat)judgeNaviHeight{
    CGFloat y = self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height;
    
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
    
    if (version < 7.0) {
        y -= 64;
        
    }else{
        if (version >= 8.0){
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return y;
}


@end
