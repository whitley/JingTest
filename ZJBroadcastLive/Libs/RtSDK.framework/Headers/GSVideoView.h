//
//  GSVideoView.h
//  RtSDK
//
//  Created by Gaojin Hsu on 4/7/15.
//  Copyright (c) 2015 Geensee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSVideoFrame.h"
#import "GSMovieGLView.h"


#import <AVFoundation/AVFoundation.h>



/**
 *  视频显示模式
 */
typedef NS_ENUM(NSUInteger, GSVideoViewContentMode){
    /**
     *  拉伸填充
     */
    GSVideoViewContentModeFill,
    /**
     *  保持比例， 现实全尺寸
     */
    GSVideoViewContentModeRatioFit,
    
    /**
     *  保持比例填充，会被截取
     */
    GSVideoViewContentModeRatioFill
};

/**
 用于显示视频的View
 */
@interface GSVideoView : UIView

/**
 *  初始化VideoView实例
 *
 *  @param frame GSVideoView 的矩形区域
 *
 *  @return GSVideoView 实例对象
 */
- (id)initWithFrame:(CGRect)frame;


/**
 *  接受视频每一帧数据，并渲染
 *
 *  @param frame 视频帧数据
 *  @see GSVideoFrame
 */
- (void)renderVideoFrame:(GSVideoFrame*)frame;


/**
 *  接受并渲染桌面共享数据
 *
 *  @param imageFrame 桌面共享每一帧的数据
 */
- (void)renderAsVideoByImage:(UIImage*)imageFrame;


/**
 *  视频显示模式
 */
@property (nonatomic, assign) GSVideoViewContentMode videoViewContentMode;


@property (nonatomic, strong)GSMovieGLView *movieGLView;

@property (nonatomic, strong)UIImageView *movieASImageView;

@property(nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;


////关闭摄像头
//-(void)stopVideoSmallScreenCapture;



//直接显示直播
-(void)setUpPreviewLayer;


//移除图层
-(void)reMovePreviewLayer;






@end
