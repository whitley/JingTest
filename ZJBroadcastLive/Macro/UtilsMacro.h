//
//  UtilsMacro.h
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/15.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#ifndef UtilsMacro_h
#define UtilsMacro_h

/*---------------------DLog---------------------*/
#ifdef DEBUG
#ifndef DLog
#   define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#endif
#ifndef ELog
#   define ELog(err) {if(err) DLog(@"%@", err)}
#endif
#else
#ifndef DLog
#   define DLog(...)
#endif
#ifndef ELog
#   define ELog(err)
#endif
#endif

/*------------------- ********* -----------------*/
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


/*------------------ 16进制随机颜色 -----------------*/
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// RGB Color
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
/*------------------ 字体设置 --------------*/
#define kFontWithSize(s) [UIFont fontWithName:@"HelveticaNeue-Light" size:s]
#define kSystemFontWithSize(s)  [UIFont systemFontOfSize:s];

/*-----------  __weakself block使用  --------*/
#define WeakSelf(weakSelf) __weak __typeof(&*self)weakSelf = self

/*-----------  数据  --------*/
//设备的物理屏幕宽度
#define  kScreenWidth  [[UIScreen mainScreen] bounds].size.width
//设备的物理屏幕高度
#define  kScreenHeight [[UIScreen mainScreen] bounds].size.height
//设备当前系统版本
#define  kSystemVersion [[UIDevice currentDevice].systemVersion floatValue]
//tabbar 高度
#define  kTabbarHeight 49
//导航栏高度
#define  kNavbarHeight 64

//根据尺寸获得手机类型
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define kNavbarHeight 64

/*------创建UIImage------*/
#define UIImageName(name)  [UIImage imageNamed:name]

/*---------- 根据不同的手机对应比例给高度 -------------*/
#define floatValueOfHeight(giveHeightValue)  ((kScreenHeight*giveHeightValue)/1334.00)

#define floatValueOfWidth(giveWidthValue)  ((kScreenWidth*giveWidthValue)/750.00)

/*-----------  一些色值  -------------*/
//背景颜色
#define kBackgroundColor UIColorFromRGB(0xf5f5f5)
//分割线的颜色
#define kLineColor UIColorFromRGB(0xebebeb)
//整体的橘黄色
#define kOrangeColor UIColorFromRGB(0xf57d35)

//中间导航区域底色
#define kNaviBackColor RGB(80,80,80)
//文档 聊天 问答 视图底色
#define kShowViewBackColor RGB(120 ,120 ,120)
//灰色字体
#define kGrayTitleColor RGB(170 ,170 ,170)


//存储本地地图的版本号key
#define kCityVersionKey  @"cityVersion"

/* "1"表示 有 未读消息  "0"表示 无 未读消息  */
//本地存储是否有未读的 通知 标志位
#define kNoticeFlag    [NSString stringWithFormat:@"abc%@_NoticeFlag",[SingleObject shareSingleObject].user.uid]

//本地存储是否有未读的 赞 标志位
#define kLikeFlag       [NSString stringWithFormat:@"abc%@_likeFlag",[SingleObject shareSingleObject].user.uid]

//本地存储是否有未读的 私信 标志位
#define kPrivateMessageFlag  [NSString stringWithFormat:@"abc%@_PrivateMessageFlag",[SingleObject shareSingleObject].user.uid]

//用户基本信息的本地存储的key
#define kUserDic  @"userDic"

//用户计数的本地存储的key
#define kUserCounter  @"UserCounter"


#endif /* UtilsMacro_h */
