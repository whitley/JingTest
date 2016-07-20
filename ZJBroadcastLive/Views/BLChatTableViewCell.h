//
//  BLChatTableViewCell.h
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/20.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLChatMessageInfo.h"
@interface BLChatTableViewCell : UITableViewCell


- (void)setContent:(BLChatMessageInfo*)messageInfo;

@property (strong, nonatomic) NSDictionary *key2fileDic;

@end
