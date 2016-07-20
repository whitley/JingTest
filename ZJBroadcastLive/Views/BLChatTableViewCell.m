//
//  BLChatTableViewCell.m
//  ZJBroadcastLive
//
//  Created by ZhangJing on 16/7/20.
//  Copyright © 2016年 zhangjing. All rights reserved.
//

#import "BLChatTableViewCell.h"
//#import "SCGIFImageView.h"
//#import "OHAttributedLabel.h"
//#import "MarkupParser.h"
//#import "NSAttributedString+Attributes.h"

#define ContentLabelViewTag 999
@interface BLChatTableViewCell()
@property (strong, nonatomic) UILabel *senderNameLabel;
@property (strong, nonatomic) UILabel *receiveTimeLabel;
@end

@implementation BLChatTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    _senderNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _receiveTimeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    
    [self.contentView addSubview:_senderNameLabel];
    [self.contentView addSubview:_receiveTimeLabel];
    
    _senderNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _receiveTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *consH1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_senderNameLabel]-[_receiveTimeLabel(80)]-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_senderNameLabel, _receiveTimeLabel)];
    [self.contentView addConstraints:consH1];
    
    NSArray *consV1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_senderNameLabel(40)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_senderNameLabel)];
    [self.contentView addConstraints:consV1];
    
    NSArray *consV2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_receiveTimeLabel(40)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_receiveTimeLabel)];
    [self.contentView addConstraints:consV2];
    
    
}

//- (void)setContent:(BLChatMessageInfo*)messageInfo
//{
//    _senderNameLabel.text = messageInfo.senderName;
//    _receiveTimeLabel.text = messageInfo.receiveTime;
//    
//    
//    OHAttributedLabel *chatContenLabel = (OHAttributedLabel*)[self.contentView viewWithTag:ContentLabelViewTag];
//    if (chatContenLabel) {
//        [chatContenLabel removeFromSuperview];
//        chatContenLabel = nil;
//    }
//    chatContenLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
//    chatContenLabel.tag = ContentLabelViewTag;
//    
//    [self creatAttributedLabel:messageInfo.message.richText Label:chatContenLabel];
//    
//    int height = [self heightOfText:[self transfromString2: messageInfo.message.richText] width:self.frame.size.width - 40 fontSize:12.f];
//    [chatContenLabel setFont:[UIFont systemFontOfSize:12.f]];
//    chatContenLabel.frame = CGRectMake(20, _senderNameLabel.frame.origin.y + 40 + 8, self.frame.size.width - 40, height + 16);
//    [chatContenLabel.layer display];
//    
//    [self drawImageView:chatContenLabel];
//    
//    [self.contentView addSubview:chatContenLabel];
//    
//    CGRect cellFrame = self.frame;
//    cellFrame.size.height = chatContenLabel.frame.size.height + 25 + 40;
//    self.frame = cellFrame;
//}


//- (void)creatAttributedLabel:(NSString *)o_text Label:(OHAttributedLabel *)label
//{
//    [label setNeedsDisplay];
//    //    NSMutableArray *httpArr = [self addHttpArr:o_text];
//    //    NSMutableArray *phoneNumArr = [self addPhoneNumArr:o_text];
//    
//    NSString *text = [self transformString:o_text];
//    text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",text];
//    
//    MarkupParser* p = [[MarkupParser alloc] init];
//    NSMutableAttributedString* attString = [p attrStringFromMarkup: text];
//    //    attString = [NSMutableAttributedString attributedStringWithAttributedString:attString];
//    [attString setFont:[UIFont systemFontOfSize:16]];
//    label.backgroundColor = [UIColor clearColor];
//    [label setAttString:attString withImages:p.images];
//    
//    //    NSString *string = attString.string;
//    //
//    //    if ([phoneNumArr count]) {
//    //        for (NSString *phoneNum in phoneNumArr) {
//    //            [label addCustomLink:[NSURL URLWithString:phoneNum] inRange:[string rangeOfString:phoneNum]];
//    //        }
//    //    }
//    //
//    //    if ([httpArr count]) {
//    //        for (NSString *httpStr in httpArr) {
//    //            [label addCustomLink:[NSURL URLWithString:httpStr] inRange:[string rangeOfString:httpStr]];
//    //        }
//    //    }
//    
//    //label.delegate = self;
//    CGRect labelRect = label.frame;
//    labelRect.size.width = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].width;
//    labelRect.size.height = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].height;
//    label.frame = labelRect;
//    
//    
//}


- (NSString *)transformString:(NSString *)originalStr
{
    //匹配表情，将表情转化为html格式
    NSString *text = originalStr;
    
    NSRegularExpression* preRegex = [[NSRegularExpression alloc]
                                     initWithPattern:@"<IMG.+?src=\"(.*?)\".*?>"
                                     options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                     error:nil]; //2
    NSArray* matches = [preRegex matchesInString:text options:0
                                           range:NSMakeRange(0, [text length])];
    
    
    int offset = 0;
    
    for (NSTextCheckingResult *match in matches) {
        
        NSRange imgMatchRange = [match rangeAtIndex:0];
        imgMatchRange.location += offset;
        
        NSString *imgMatchString = [text substringWithRange:imgMatchRange];
        
        
        NSRange srcMatchRange = [match rangeAtIndex:1];
        srcMatchRange.location += offset;
        
        NSString *srcMatchString = [text substringWithRange:srcMatchRange];
        
        NSString *i_transCharacter = [self.key2fileDic objectForKey:srcMatchString];
        if (i_transCharacter) {
            NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='24' height='24'>", i_transCharacter];
            text = [text stringByReplacingCharactersInRange:NSMakeRange(imgMatchRange.location, [imgMatchString length]) withString:imageHtml];
            offset += (imageHtml.length - imgMatchString.length);
        }
        
    }
    
    return text;
}

- (NSString*)transfromString2:(NSString*)originalString
{
    //匹配表情，将表情转化为html格式
    NSString *text = originalString;
    //【伤心】
    //NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    
    NSRegularExpression* preRegex = [[NSRegularExpression alloc]
                                     initWithPattern:@"<IMG.+?src=\"(.*?)\".*?>"
                                     options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                     error:nil]; //2
    NSArray* matches = [preRegex matchesInString:text options:0
                                           range:NSMakeRange(0, [text length])];
    int offset = 0;
    
    for (NSTextCheckingResult *match in matches) {
        //NSRange srcMatchRange = [match range];
        NSRange imgMatchRange = [match rangeAtIndex:0];
        imgMatchRange.location += offset;
        
        NSString *imgMatchString = [text substringWithRange:imgMatchRange];
        
        
        NSRange srcMatchRange = [match rangeAtIndex:1];
        srcMatchRange.location += offset;
        
        NSString *srcMatchString = [text substringWithRange:srcMatchRange];
        
        NSString *i_transCharacter = [self.key2fileDic objectForKey:srcMatchString];
        if (i_transCharacter) {
            NSString *imageHtml =@"表情表情表情";//表情占位，用于计算文本长度
            text = [text stringByReplacingCharactersInRange:NSMakeRange(imgMatchRange.location, [imgMatchString length]) withString:imageHtml];
            offset += (imageHtml.length - imgMatchString.length);
        }
        
    }
    
    
    //返回转义后的字符串
    return text;
    
}



- (CGFloat)heightOfText:(NSString*)content width:(CGFloat)width fontSize:(CGFloat)fontSize
{
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize  size = [content sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    return MAX(size.height, 20);
}

//-(void)drawImageView:(OHAttributedLabel*)label
//{
//    for (NSArray *info in label.imageInfoArr) {
//        
//        NSBundle *resourceBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RtSDK" ofType:@"bundle"]];
//        NSString *filePath = [resourceBundle pathForResource:[info objectAtIndex:0] ofType:nil];
//        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
//        SCGIFImageView *imageView = [[SCGIFImageView alloc] initWithGIFData:data];
//        imageView.frame = CGRectFromString([info objectAtIndex:2]);
//        [label addSubview:imageView];//label内添加图片层
//        [label bringSubviewToFront:imageView];
//        imageView = nil;
//    }
//}


@end
