//
//  BLStartViewController.m
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/15.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import "BLStartViewController.h"
#import "UtilsMacro.h"

@interface BLStartViewController ()
@property (nonatomic,strong)UIImageView * startImageView;//启动视图
@end

@implementation BLStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.startImageView];
    
}

- (UIImageView *)startImageView{
    if (!_startImageView) {
        _startImageView = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        if (kScreenHeight == 960) {
            _startImageView.image = UIImageName(@"LaunchImage-700");
        }else if(kScreenHeight == 1136){
            _startImageView.image = UIImageName(@"LaunchImage-700-568h");
        }else if(kScreenHeight == 1334){
            _startImageView.image = UIImageName(@"LaunchImage-800-667h");
        }else{
            _startImageView.image = UIImageName(@"LaunchImage-800-Portrait-736h");
        }

    }
    return _startImageView;
}


@end
