//
//  BLLoginViewController.m
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/15.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import "BLLoginViewController.h"

@implementation BLLoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.title = @"填写直播信息";
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    self.navigationItem.hidesBackButton = YES;
}
@end
