//
//  BLUserDefaults.h
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/18.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLUserDefaults : NSObject

+(BOOL)save;

+ (void)setDomain:(NSString*)domain;
+ (NSString*)domain;

+ (void)setServiceType:(NSString*)serviceType;
+ (NSString*)serviceType;

+ (void)setWebcastID:(NSString*)webcastID;
+ (NSString*)webcastID;

+ (void)setRoomNumber:(NSString*)roomNumber;
+ (NSString*)roomNumber;

+ (void)setLoginName:(NSString*)loginName;
+ (NSString*)loginName;

+ (void)setLoginPassword:(NSString*)loginPassword;
+ (NSString*)loginPassword;

+ (void)setNickname:(NSString*)nickname;
+ (NSString*)nickname;

+ (void)setWatchPassword:(NSString*)watchPassword;
+ (NSString*)watchPassword;
@end
