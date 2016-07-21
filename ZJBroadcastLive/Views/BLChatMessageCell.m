//
//  BLChatMessageCell.m
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/21.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import "BLChatMessageCell.h"
#import "UtilsMacro.h"

@interface BLChatMessageCell()
@property (nonatomic, strong)UILabel *userNameLabel;
@property (nonatomic, strong)UILabel *messageTimeLabel;
@property (nonatomic, strong)UILabel *messageContentLabel;

@property (nonatomic, strong)UILabel *firstLine;
@property (nonatomic, strong)UILabel *secondLine;
@property (nonatomic, strong)UIImageView *tagImageView;
@end
@implementation BLChatMessageCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGRect rect = self.frame;
        rect.size.width = [[UIScreen mainScreen] applicationFrame].size.width;
        self.frame = rect;
        
        [self setupMessageCellUI];
        
    }
    return self;
}

- (void)setupMessageCellUI{
    self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 10, 200, 20)];
    self.userNameLabel.textColor = RGB(180, 180, 180);
    self.userNameLabel.font = [UIFont systemFontOfSize:14];
    self.userNameLabel.textAlignment = NSTextAlignmentLeft;
    
    
    self.messageTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-80, self.userNameLabel.frame.origin.y, 70, 20)];
    self.messageTimeLabel.textColor = RGB(150, 150, 150);
    self.messageTimeLabel.font = [UIFont systemFontOfSize:13];
    self.messageTimeLabel.textAlignment = NSTextAlignmentLeft;
    
    
    self.messageContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.userNameLabel.frame.origin.x, self.userNameLabel.frame.size.height+self.userNameLabel.frame.origin.y+5, kScreenWidth-20-10, 20)];
    self.messageContentLabel.textColor = [UIColor whiteColor];
    self.messageContentLabel.font = [UIFont systemFontOfSize:14];
    self.messageContentLabel.numberOfLines = 0;
    
    self.firstLine = [[UILabel alloc]initWithFrame:CGRectMake(14, 0, 1.5, 12)];
    self.firstLine.backgroundColor = kGrayTitleColor;
    
    self.tagImageView = [[UIImageView alloc]initWithFrame:CGRectMake(7, self.firstLine.frame.origin.y+self.firstLine.frame.size.height, 16, 16)];
    self.tagImageView.image = [UIImage imageNamed:@"btn_unselected"];
    
    self.secondLine = [[UILabel alloc]initWithFrame:CGRectMake(14, self.tagImageView.frame.size.height+self.tagImageView.frame.origin.y, 1.5, 40)];
    self.secondLine.backgroundColor = kGrayTitleColor;
    
    [self addSubview:self.userNameLabel];
    [self addSubview:self.messageTimeLabel];
    [self addSubview:self.messageContentLabel];
    
    [self addSubview:self.firstLine];
    [self addSubview:self.tagImageView];
    [self addSubview:self.secondLine];
}

- (void)layoutSubviews{
    self.userNameLabel.text = self.messageInfo.senderName;
    self.messageContentLabel.text = self.messageInfo.message.text;
    self.messageTimeLabel.text = self.messageInfo.receiveTime;

}

@end
