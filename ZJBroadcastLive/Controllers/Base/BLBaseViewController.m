//
//  BLBaseViewController.m
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/15.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import "BLBaseViewController.h"
#import "UtilsMacro.h"
@interface BLBaseViewController ()

@end

@implementation BLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}



@end
