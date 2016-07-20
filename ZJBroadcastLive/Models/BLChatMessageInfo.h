//
//  BLChatMessageInfo.h
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/20.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RtSDK/RtSDK.h>
typedef NS_ENUM(NSInteger, ChatMessageType)
{
    ChatMessageTypePrivate,
    ChatMessageTypePublic,
    ChatMessageTypePanelist,
    ChatMessageTypeFromMe,
    ChatMessageTypeSystem,
};


@interface BLChatMessageInfo : NSObject
@property (nonatomic, strong)NSString *senderName;

@property (nonatomic, strong)NSString *receiveTime;

@property (nonatomic, assign)ChatMessageType messageType;

@property (nonatomic, strong)GSChatMessage *message;

@property (nonatomic, assign)long long senderID;

@end
