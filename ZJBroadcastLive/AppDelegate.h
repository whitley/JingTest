//
//  AppDelegate.h
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/14.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RtSDK/RtSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic ,strong)GSBroadcastManager *manager;
@property (nonatomic ,assign)BOOL allowRotation;
@end

