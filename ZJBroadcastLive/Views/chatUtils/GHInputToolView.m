//
//  GHInputToolView.m
//  GHEmojiKeyboard
//
//  Created by Gaojin Hsu on 4/25/15.
//  Copyright (c) 2015 gensee. All rights reserved.
//

#import "GHInputToolView.h"

#define defaultHeight 52

@interface GHInputToolView()<UITextViewDelegate>

@property (nonatomic, strong) GHEmojiCollectionView *emojiCollectionView;

@property (nonatomic, strong) NSDictionary *keyboadUserInfo;

@end

@implementation GHInputToolView

#pragma mark -
#pragma mark Init Methods

- (id)initWithParentFrame:(CGRect)parentFrame
{
    float y = parentFrame.origin.y + parentFrame.size.height - defaultHeight;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
    if (version < 7.0) {
        y -= 64;
    }
    CGRect frame = CGRectMake(0,  y, parentFrame.size.width, defaultHeight);
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpWithParentView:frame emojiPlistFileName:nil inBundle:nil];
        
        self.inputTextView.delegate = self;
        
        [self addNotificationObserver];
    }
    return self;
 
}


- (id)initWithParentFrame:(CGRect)parentFrame emojiPlistFileName:(NSString *)fileName inBundle:(NSBundle *)bundle;
{
    
    float y = parentFrame.origin.y + parentFrame.size.height - defaultHeight;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
    if (version < 7.0) {
        y -= 64;
    }
    CGRect frame = CGRectMake(0, y, parentFrame.size.width, defaultHeight);
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpWithParentView:frame emojiPlistFileName:fileName inBundle:bundle];
        
        self.inputTextView.delegate = self;
        
        [self addNotificationObserver];
    }
    return self;
}

- (void)setUpWithParentView:(CGRect)frame emojiPlistFileName:(NSString*)fileName inBundle:bundle
{


    
    self.backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    UIImage *bkImage = [[UIImage imageNamed:@"input-bar-background"]stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    [self.backgroundImageView setImage:bkImage];
    [self addSubview:self.backgroundImageView];
    
    self.textViewBackgroundImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    UIImage *inputViewBgImage = [[UIImage imageNamed:@"input-bar-flat"]stretchableImageWithLeftCapWidth:1 topCapHeight:3];
    [self.textViewBackgroundImageView setImage:inputViewBgImage];
    [self addSubview:self.textViewBackgroundImageView];

    self.inputTextView = [[UITextView alloc]initWithFrame:CGRectZero];
    [self addSubview:self.inputTextView];
    self.inputTextView.font = [UIFont systemFontOfSize:16.f];
    self.inputTextView.backgroundColor = [UIColor clearColor];
    [self.inputTextView setReturnKeyType:UIReturnKeySend];
    
    // add Constraints to subviews
    self.inputTextView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textViewBackgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSArray *textViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_inputTextView]-8-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_inputTextView)];
    [self addConstraints:textViewV];
    
    
    NSArray *bkImageViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImageView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_backgroundImageView)];
    [self addConstraints:bkImageViewH];
    
    NSArray *bkImageViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImageView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_backgroundImageView)];
    [self addConstraints:bkImageViewV];
    
    NSArray *textViewBgImageViewV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_textViewBackgroundImageView]-8-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_textViewBackgroundImageView)];
    [self addConstraints:textViewBgImageViewV];
    
    if (fileName) {
        
        self.emojiCollectionView = [[GHEmojiCollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 216) emijiPlistFileName:fileName inBundle:bundle];
        
        __weak __block GHInputToolView *copy_self = self;
        
        //获取图片并显示
        [self.emojiCollectionView setEmojiCollectionViewBlock:^(UIImage *emojiImage, NSString *emojiText)
         {
             [copy_self.inputTextView insertText:emojiText];
             
         }];
        
        self.emojiButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [self addSubview:self.emojiButton];
        [self.emojiButton addTarget:self action:@selector(switchInputView:) forControlEvents:UIControlEventTouchUpInside];
        [self.emojiButton setImage:[UIImage imageNamed:@"ToolViewEmotion_ios7"] forState:UIControlStateNormal];
        
        
        self.emojiButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat distance = (defaultHeight - 35)/2;
        NSString *visualFomatString = [NSString stringWithFormat:@"V:[_emojiButton(35)]-%f-|", distance];
        NSArray *emojiButtonV = [NSLayoutConstraint constraintsWithVisualFormat:visualFomatString options:0 metrics:0 views:NSDictionaryOfVariableBindings(_emojiButton)];
        [self addConstraints:emojiButtonV];

        
        NSArray *consH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_inputTextView]-8-[_emojiButton(35)]-8-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_inputTextView, _emojiButton)];
        [self addConstraints:consH];
        
        NSArray *textViewBgImageViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_textViewBackgroundImageView]-8-[_emojiButton]-8-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_textViewBackgroundImageView, _emojiButton)];
        [self addConstraints:textViewBgImageViewH];
        
    }
    else
    {
        NSArray *consH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_inputTextView]-8-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_inputTextView)];
        [self addConstraints:consH];
        
        NSArray *textViewBgImageViewH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_textViewBackgroundImageView]-8-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_textViewBackgroundImageView)];
        [self addConstraints:textViewBgImageViewH];
    }
    

}

- (void)endEditting
{
    [self.inputTextView resignFirstResponder];
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyNotification:(NSNotification*)notification
{
    self.keyboadUserInfo = notification.userInfo;
    
    CGRect rect = [notification.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
       
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]floatValue] animations: ^{
        
        [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] doubleValue]];
        
        CGRect frame = self.frame;
        
        float y = rect.origin.y - frame.size.height;
        double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
        if (version < 7.0) {
            y -= 64;
        }
        frame.origin.y = y;
        
        self.frame = frame;
    }];
}

#pragma mark - 
#pragma mark Actions

- (void)switchInputView:(id)sender
{
    if ([self.inputTextView.inputView isEqual:self.emojiCollectionView]) {
        self.inputTextView.inputView = nil;
        [self.emojiButton setImage:[UIImage imageNamed:@"ToolViewEmotion_ios7"] forState:UIControlStateNormal];
        
        [self.inputTextView reloadInputViews];
        

    }
    else
    {
        self.inputTextView.inputView = self.emojiCollectionView;
        [self.emojiButton setImage:[UIImage imageNamed:@"ToolViewKeyboard_ios7"] forState:UIControlStateNormal];
        
        [self.inputTextView reloadInputViews];

    }
    
    if ([self.inputTextView isFirstResponder]) {
        
        [self.inputTextView resignFirstResponder];
        
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.05f];
        
    }
    else
    {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)delayMethod
{
    [self.inputTextView becomeFirstResponder];

}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    // Resize ToolView according to content size of textview
    CGSize contentSize = self.inputTextView.contentSize;

    float height = contentSize.height + 16;
    if (height <= 150) {
        CGRect frame = self.frame;
        frame.origin.y = frame.origin.y - (height - frame.size.height);
        frame.size.height = height;
        self.frame = frame;
    }

}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        if ([self.delegate respondsToSelector:@selector(sendMessage:)]) {
            
            [self.delegate sendMessage:self.inputTextView.text];
        }
        
        self.inputTextView.text = @"";
        
        CGRect frame = self.frame;
        CGRect rect = [self.keyboadUserInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];

        float y = rect.origin.y - frame.size.height;
        double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
        if (version < 7.0) {
            y -= 64;
        }
        
        frame.origin.y = y;
        
        frame.size.height = defaultHeight;

        self.frame = frame;
        
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark System Default Code

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)dealloc
{
    [self removeNotificationObserver];
}
@end
