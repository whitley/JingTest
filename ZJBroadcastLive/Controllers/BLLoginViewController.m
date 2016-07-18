//
//  BLLoginViewController.m
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/15.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import "BLLoginViewController.h"
#import "BLUserDefaults.h"
#import "BLHomeBLViewController.h"

@interface BLLoginViewController()<UITextFieldDelegate>
@property (nonatomic ,copy)NSString *domain;

@property (nonatomic ,copy)NSString *serviceType;

@property (nonatomic ,copy)NSString *loginName;

@property (nonatomic ,copy)NSString *loginPassword;

@property (nonatomic ,copy)NSString *webcastID;

@property (nonatomic ,copy)NSString *roomNumber;

@property (nonatomic ,copy)NSString *nickName;

@property (nonatomic ,copy)NSString *watchPassword;

@property (nonatomic ,copy)NSString *token;


@property (nonatomic ,strong)UITextField *roomNumberTF;
@property (nonatomic ,strong)UITextField *nickNameTF;
@property (nonatomic ,strong)UITextField *watchPwdTF;

@property (nonatomic ,strong)UIButton *watchBLBtn;//观看直播 按钮
@property (nonatomic ,strong)UIButton *createBLBtn;//发直播 按钮

@end
@implementation BLLoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.title = @"填写直播信息";
    [BLUserDefaults setDomain:@"cytx.gensee.com"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeInputChar:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [BLUserDefaults save];
    
    [self.roomNumberTF resignFirstResponder];
    [self.nickNameTF resignFirstResponder];
    [self.watchPwdTF resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];

}

- (void)setupUI{
    self.roomNumberTF = [[UITextField alloc]initWithFrame:CGRectMake(50, 40+kNavbarHeight, kScreenWidth-50*2, 40)];
    self.roomNumberTF.delegate = self;
    self.roomNumberTF.placeholder = @"8位数字的直播编号";
    self.roomNumberTF.textColor = RGB(80, 80, 80);
    self.roomNumberTF.font = [UIFont systemFontOfSize:16];
    self.roomNumberTF.textAlignment = NSTextAlignmentLeft;
    self.roomNumberTF.keyboardType = UIKeyboardTypeNumberPad;
    self.roomNumberTF.clearButtonMode = UITextFieldViewModeAlways;
    self.roomNumberTF.layer.borderWidth = 1;
    self.roomNumberTF.layer.borderColor = [RGB(200, 200, 200) CGColor];
//    self.roomNumberTF.layer.cornerRadius = 20;
//    self.roomNumberTF.layer.masksToBounds = YES;
    
    
    self.nickNameTF = [[UITextField alloc]initWithFrame:CGRectMake(self.roomNumberTF.frame.origin.x, self.roomNumberTF.frame.origin.y+self.roomNumberTF.frame.size.height+15, kScreenWidth-50*2, 40)];
    self.nickNameTF.placeholder = @"昵称";
    self.nickNameTF.delegate = self;
    self.nickNameTF.textColor = RGB(80, 80, 80);
    self.nickNameTF.font = [UIFont systemFontOfSize:16];
    self.nickNameTF.textAlignment = NSTextAlignmentLeft;
    self.nickNameTF.keyboardType = UIKeyboardTypeDefault;
    self.nickNameTF.clearButtonMode = UITextFieldViewModeAlways;
    self.nickNameTF.layer.borderWidth = 1;
    self.nickNameTF.layer.borderColor = [RGB(200, 200, 200) CGColor];
    
    
    self.watchPwdTF = [[UITextField alloc]initWithFrame:CGRectMake(self.roomNumberTF.frame.origin.x, self.nickNameTF.frame.origin.y+self.nickNameTF.frame.size.height+15, kScreenWidth-50*2, 40)];
    self.watchPwdTF.placeholder = @"口令";
    self.watchPwdTF.delegate = self;
    self.watchPwdTF.textColor = RGB(80, 80, 80);
    self.watchPwdTF.font = [UIFont systemFontOfSize:16];
    self.watchPwdTF.textAlignment = NSTextAlignmentLeft;
    self.watchPwdTF.keyboardType = UIKeyboardTypeDefault;
    self.watchPwdTF.clearButtonMode = UITextFieldViewModeAlways;
    self.watchPwdTF.layer.borderWidth = 1;
    self.watchPwdTF.layer.borderColor = [RGB(200, 200, 200) CGColor];
    
    
    self.roomNumberTF.text = [BLUserDefaults roomNumber];
    self.nickNameTF.text = [BLUserDefaults nickname];
    self.watchPwdTF.text = [BLUserDefaults watchPassword];
    
    
    [self.view addSubview:self.roomNumberTF];
    [self.view addSubview:self.nickNameTF];
    [self.view addSubview:self.watchPwdTF];
    
    
    self.watchBLBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.roomNumberTF.frame.origin.x, self.watchPwdTF.frame.origin.y+self.watchPwdTF.frame.size.height+35, kScreenWidth-50*2, 40)];
    self.watchBLBtn.backgroundColor = RGB(235, 145, 141);
    [self.watchBLBtn setTitle:@"观看直播" forState:UIControlStateNormal];
    [self.watchBLBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.watchBLBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.watchBLBtn.layer.cornerRadius = 20;
    self.watchBLBtn.layer.masksToBounds = YES;
    [self.watchBLBtn addTarget:self action:@selector(clickWatchBLBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.watchBLBtn.userInteractionEnabled = NO;
    
    
    self.createBLBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.roomNumberTF.frame.origin.x, self.watchBLBtn.frame.origin.y+self.watchBLBtn.frame.size.height+15, kScreenWidth-50*2, 40)];
    self.createBLBtn.backgroundColor = RGB(235, 145, 141);
    [self.createBLBtn setTitle:@"发直播" forState:UIControlStateNormal];
    [self.createBLBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.createBLBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    self.createBLBtn.layer.cornerRadius = 20;
    self.createBLBtn.layer.masksToBounds = YES;
    [self.createBLBtn addTarget:self action:@selector(clickCreateBLBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.createBLBtn.userInteractionEnabled = NO;
    
    [self.view addSubview:self.watchBLBtn];
    [self.view addSubview:self.createBLBtn];
    
    
    [self setBtnBackgroundColor];
}

#pragma mark ----------------------------------
#pragma mark -- click event --

- (void)clickWatchBLBtn:(UIButton *)btn{
    BLHomeBLViewController *homeBLVC = [[BLHomeBLViewController alloc]init];
    homeBLVC.connectInfo = [GSConnectInfo new];
    homeBLVC.connectInfo.domain = @"cytx.gensee.com";
    homeBLVC.connectInfo.serviceType = GSBroadcastServiceTypeTraining;
    homeBLVC.connectInfo.roomNumber = self.roomNumberTF.text;
    homeBLVC.connectInfo.nickName = self.nickNameTF.text;
    homeBLVC.connectInfo.watchPassword = self.watchPwdTF.text;
    homeBLVC.connectInfo.oldVersion = YES;
    
    NSLog(@"xinxi == %@",homeBLVC.connectInfo.domain);
    NSLog(@"xinxi == %ld",(long)homeBLVC.connectInfo.serviceType);
    NSLog(@"xinxi == %@",homeBLVC.connectInfo.roomNumber);
    NSLog(@"xinxi == %@",homeBLVC.connectInfo.nickName);
    NSLog(@"xinxi == %@",homeBLVC.connectInfo.watchPassword);
    NSLog(@"xinxi == %@",homeBLVC.connectInfo.webcastID);
    NSLog(@"xinxi == %@",homeBLVC.connectInfo.loginName);
    NSLog(@"xinxi == %@",homeBLVC.connectInfo.loginPassword);
    
    homeBLVC.isWatchBL = YES;
    [self.navigationController pushViewController:homeBLVC animated:YES];
}

- (void)clickCreateBLBtn:(UIButton *)btn{
    BLHomeBLViewController *homeBLVC = [[BLHomeBLViewController alloc]init];
    homeBLVC.connectInfo = [GSConnectInfo new];
    homeBLVC.connectInfo.domain = @"cytx.gensee.com";
    homeBLVC.connectInfo.serviceType = GSBroadcastServiceTypeTraining;
    homeBLVC.connectInfo.roomNumber = self.roomNumberTF.text;
    homeBLVC.connectInfo.nickName = self.nickNameTF.text;
    homeBLVC.connectInfo.watchPassword = self.watchPwdTF.text;
    homeBLVC.connectInfo.oldVersion = YES;
    
    homeBLVC.isWatchBL = NO;
    [self.navigationController pushViewController:homeBLVC animated:YES];
}

#pragma mark ----------------------------------
#pragma mark -- UITextField Method -- 

- (void)changeInputChar:(NSNotification *)noti{
    [self setBtnBackgroundColor];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)setBtnBackgroundColor{
    if (self.roomNumberTF.text.length>0 && self.nickNameTF.text.length>0 && self.watchPwdTF.text.length>0) {
        self.watchBLBtn.backgroundColor = RGB(200, 52, 41);
        self.createBLBtn.backgroundColor = RGB(200, 52, 41);
        
        self.watchBLBtn.userInteractionEnabled = YES;
        self.createBLBtn.userInteractionEnabled = YES;
        
    }else{
        self.watchBLBtn.backgroundColor = RGB(235, 145, 141);
        self.createBLBtn.backgroundColor = RGB(235, 145, 141);
        
        self.watchBLBtn.userInteractionEnabled = NO;
        self.createBLBtn.userInteractionEnabled = NO;
    }
}

#pragma mark -----------------------------------
#pragma mark -- UITextFieldDelegate --

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    if (textField == self.roomNumberTF) {
        if (string.length == 0) return YES;
        
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength >8) {
            return NO;
        }
    }
    
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    [self setBtnBackgroundColor];
    
    if (textField == self.roomNumberTF) {
        [BLUserDefaults setRoomNumber:textField.text];
    }
    
    if (textField == self.nickNameTF) {
        [BLUserDefaults setNickname:textField.text];
    }
    
    if (textField == self.watchPwdTF) {
        [BLUserDefaults setWatchPassword:textField.text];
    }
    return YES;
}

@end
