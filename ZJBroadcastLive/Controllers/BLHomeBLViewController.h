//
//  BLHomeBLViewController.h
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/18.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import "BLBaseViewController.h"
#import <RtSDK/RtSDK.h>

@interface BLHomeBLViewController : BLBaseViewController

@property (strong, nonatomic)GSConnectInfo *connectInfo;
@property (nonatomic ,assign)BOOL isWatchBL;//是否是观看视频
@end
