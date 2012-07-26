//
//  CustomAlertView.m
//  CustomAlertView
//
//  Created by Mariusz Śpiewak on 11-12-02.
//  Copyright (c) 2011 Mariusz Śpiewak. All rights reserved.
//

#import "CTAlertView.h"
#import "Logging.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Gradient Declarations
    NSArray* gradient2Colors = [NSArray arrayWithObjects: 
                                (id)[UIColor clearColor].CGColor, 
                                (id)[UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.5].CGColor, 
                                (id)[UIColor blackColor].CGColor, nil];
    CGFloat gradient2Locations[] = {0, 0.75, 1};
    CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradient2Colors, gradient2Locations);


    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rect];
    CGContextSaveGState(context);
    [rectanglePath addClip];
    CGContextDrawRadialGradient(context, gradient2,
                                CGPointMake(rect.size.width/2.0, rect.size.height/2.0), rect.size.width/20.0,
                                CGPointMake(rect.size.width/2.0, rect.size.height/2.0), rect.size.width,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);


    //// Cleanup
    CGGradientRelease(gradient2);
    CGColorSpaceRelease(colorSpace);
}

@end

@interface CTAlertView ()
{
    CGFloat _messageWidth;
}

@property (nonatomic, retain) UIView *container;

- (void)buttonPressed:(id)sender;

- (void)slideIn;
- (void)slideOut;
- (void)drop;
- (void)remove;

- (void)styleMessageLabel;
- (void)styleTitleLabel;
@end

@implementation CTAlertView
@synthesize userViewBelowMessage=_userViewBelowMessage;

@synthesize container=_container;
@synthesize topImage=_topImage;
@synthesize bottomImage=_bottomImage;
@synthesize centerImage=_centerImage;
@synthesize singleButtonImageNormal=_singleButtonImageNormal;
@synthesize singleButtonImageDown=_singleButtonImageDown;

@synthesize cancelButtonImageNormal=_cancelButtonImageNormal;
@synthesize cancelButtonImageDown=_cancelButtonImageDown;
@synthesize otherButtonImageNormal=_otherButtonImageNormal;
@synthesize otherButtonImageDown=_otherButtonImageDown;
@synthesize backgroundImage=_backgroundImage;
@synthesize message=_message;
@synthesize title=_title;
@synthesize cancelButtonTitle=_cancelButtonTitle;
@synthesize otherButtonTitle=_otherButtonTitle;
@synthesize textColor=_textColor;
@synthesize textShadowColor=_textShadowColor;
@synthesize messageLabel=_messageLabel;
@synthesize centerView=_centerView;
@synthesize titleLabel=_titleLabel;
@synthesize otherButtonLabel=_otherButtonLabel;
@synthesize cancelButtonLabel=_cancelButtonLabel;
@synthesize cancelButton=_cancelButton;
@synthesize otherButton=_otherButton;
@synthesize dismissAction=_dismissAction;
@synthesize confirmAction=_confirmAction;
@synthesize willShowAlertAction=_willShowAlert;
@synthesize willDismissAlertAction=_willDismissAlert;
@synthesize didShowAlertAction=_didShowAlert;
@synthesize didDismissAlertAction=_didDismissAlert;
@synthesize dismissTransitionStyle=_dismissTransitionStyle;
@synthesize showTransitionStyle=_showTransitionStyle;
@synthesize removeTransitionStyle=_removeTransitionStyle;
@synthesize useDefaultDimmBackground=_useDefaultDimmBackground;
@synthesize userView=_userView;
@synthesize buttonsOnBottomView=_buttonsOnBottomView;
@synthesize buttonsVerticalSpacing=_buttonsVerticalSpacing;
@synthesize messageVerticalSpacing=_messageVerticalSpacing;
@synthesize buttonsCenterSpacing=_buttonsCenterSpacing;
@synthesize textShadowOffset=_textShadowOffset;

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
    return [self initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle userView:nil];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle userView:(UIView *)userView
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 480)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.title = title;
        self.message = message;
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitle = otherButtonTitle;
        
        self.topImage = ALERT_IMG_TOP;
        self.bottomImage = ALERT_IMG_BOTTOM;
        self.centerImage = ALERT_IMG_CENTER;
        self.cancelButtonImageNormal = ALERT_IMG_BUTTON_CANCEL_NORMAL;
        self.cancelButtonImageDown = ALERT_IMG_BUTTON_CANCEL_DOWN;
        self.otherButtonImageNormal = ALERT_IMG_BUTTON_OTHER_NORMAL;
        self.otherButtonImageDown = ALERT_IMG_BUTTON_OTHER_DOWN;
        self.singleButtonImageNormal = ALERT_IMG_BUTTON_SINGLE_NORMAL;
        self.singleButtonImageDown = ALERT_IMG_BUTTON_SINGLE_DOWN; 
        
        self.textColor = [UIColor whiteColor];
        self.textShadowColor = [UIColor blackColor];
        self.textShadowOffset = SHADOW_OFFSET;
        
        self.otherButtonLabel = [[[UILabel alloc] init] autorelease];
        _otherButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        _otherButtonLabel.backgroundColor = [UIColor clearColor];
        _otherButtonLabel.textAlignment = UITextAlignmentCenter;
        _otherButtonLabel.textColor = _textColor;
        _otherButtonLabel.shadowColor = _textShadowColor;
        _otherButtonLabel.shadowOffset = _textShadowOffset;
        
        self.cancelButtonLabel = [[[UILabel alloc] init] autorelease];
        _cancelButtonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        _cancelButtonLabel.backgroundColor = [UIColor clearColor];
        _cancelButtonLabel.textAlignment = UITextAlignmentCenter;
        _cancelButtonLabel.textColor = _textColor;
        _cancelButtonLabel.shadowColor = _textShadowColor;
        _cancelButtonLabel.shadowOffset = _textShadowOffset;
        
        self.userView = userView;
        
        self.showTransitionStyle = CTAlertShowTransitionStyleSlideIn;
        if (otherButtonTitle == nil) {
            self.dismissTransitionStyle = CTAlertDismissTransitionStyleNormal;
        } else {
            self.dismissTransitionStyle = CTAlertDismissTransitionStyleDrop;
        }
        self.removeTransitionStyle = CTAlertDismissTransitionStyleNormal;
        
        self.useDefaultDimmBackground = YES;
        self.buttonsOnBottomView = NO;
        self.userViewBelowMessage = NO;
        
        self.messageVerticalSpacing = ALERT_MESSAGE_VMARGIN;
        self.buttonsVerticalSpacing = ALERT_MESSAGE_VMARGIN;
        self.buttonsCenterSpacing = ALERT_BUTTON_CENTER_SPACING;
        
        self.didDismissAlertAction= nil;
        self.didShowAlertAction = nil;
        self.willShowAlertAction = nil;
        self.willDismissAlertAction = nil;
        self.confirmAction = nil;
        self.dismissAction = nil;
    }
    return self;    
}

+ (CTAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle userView:(UIView *)userView
{
    return [[[CTAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle userView:userView] autorelease];
}

+ (CTAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
    return [[[CTAlertView alloc] initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle] autorelease];
}

- (void)alignSubviews
{
    self.container = [[[UIView alloc] init] autorelease];
    UIView *header = [[[UIImageView alloc] initWithImage:_topImage] autorelease];
    UIView *footer = [[[UIImageView alloc] initWithImage:_bottomImage] autorelease];
    self.centerView = [[[UIView alloc] init] autorelease];
    UIView *buttonContainer = [[[UIView alloc] init] autorelease];
    self.messageLabel = [[[UILabel alloc] init] autorelease];
    self.titleLabel = [[[UILabel alloc] init] autorelease];
    if (_useDefaultDimmBackground){
        _backgroundView = [[GradientView alloc] initWithFrame:self.frame];
    } else {
        _backgroundView = [[UIImageView alloc] initWithImage:_backgroundImage];
    }
    [self addSubview:_backgroundView];
    [_backgroundView release];
    
    _messageLabel.text = _message;
    _titleLabel.text = _title;
    
    _centerView.backgroundColor = [UIColor colorWithPatternImage:_centerImage];
    
    _container.opaque = NO;
    buttonContainer.opaque = NO;
    _messageLabel.opaque = NO;
    _titleLabel.opaque = NO;
    header.opaque = NO;
    footer.opaque = NO;
    _centerView.opaque = NO;
    
    CGFloat containerWidth = MAX(_userView.frame.size.width, _centerImage.size.width);
    CGFloat containerHeight = ALERT_MIN_HEIGHT;
    CGFloat centerViewWidth = containerWidth;
    _messageWidth = centerViewWidth - ALERT_MESSAGE_HMARGIN;

    // Create hierarchy
    [self addSubview:_container];
    
    [_container addSubview:_centerView];
    [_container addSubview:header];
    [_container addSubview:footer];
    
    if (_buttonsOnBottomView) {
        [footer addSubview:buttonContainer];
        footer.userInteractionEnabled = YES;
    } else {
        [_centerView addSubview:buttonContainer];
    }
    [_centerView addSubview:_userView];
    [_centerView addSubview:_messageLabel];

    [header addSubview:_titleLabel];
    
    [_container setWidth:containerWidth];
    [_centerView setWidth:centerViewWidth];
    
    // Apply font styles and message size
    [self styleTitleLabel];
    [self styleMessageLabel];
    [self adjustMessageLabelHeightUsingWidth:_messageWidth];
    
    // Sizes
    [self createButtonsInContainer:buttonContainer];
    CGFloat margins = _messageVerticalSpacing + (_userView != nil ? _messageVerticalSpacing : 0.0);
    CGFloat centerViewHeight = _messageLabel.frame.size.height + margins + _userView.frame.size.height;
    
    if (!_buttonsOnBottomView)
        centerViewHeight += buttonContainer.frame.size.height + _buttonsVerticalSpacing;
    
    containerHeight = header.frame.size.height + centerViewHeight + footer.frame.size.height;
    
    [_container setHeight:containerHeight];
    [_centerView setHeight:centerViewHeight];
    
    // Place user view
    if (_userViewBelowMessage) {
        [_messageLabel setOrigin:CGPointMake(0, _messageVerticalSpacing)];
    } else {
        [_userView setOrigin:CGPointMake(0, _messageVerticalSpacing)];
    }
    
    // Horizontal align
    [_centerView centerHorizontalyInSuperview];
    [_userView centerHorizontalyInSuperview];
    [_messageLabel centerHorizontalyInSuperview];
    [header centerHorizontalyInSuperview];
    [footer centerHorizontalyInSuperview];
    [buttonContainer centerHorizontalyInSuperview];
    
    // Place title label
    [_titleLabel setHeight:ALERT_TITLE_HEIGHT];
    [_titleLabel setWidth:_messageWidth];
    [_titleLabel setOrigin:CGPointMake(0, ALERT_TITLE_TOP_OFFSET)];
    [_titleLabel centerHorizontalyInSuperview];
    
    //Vertical align
    [_centerView placeBelowView:header withMargin:0.0];
    [footer placeBelowView:_centerView withMargin:0.0];
    
    // Align rest in center View
    if (_userViewBelowMessage) {
        [_userView placeBelowView:_messageLabel withMargin:_messageVerticalSpacing];
    } else {
        [_messageLabel placeBelowView:_userView withMargin:_messageVerticalSpacing];
    }
    if (_buttonsOnBottomView) {
        [buttonContainer setOriginY:_buttonsVerticalSpacing];
    } else {
        [buttonContainer placeBelowView:_messageLabel withMargin:_buttonsVerticalSpacing];
    }
    
    // Center container horizontaly in Window
    [_container centerHorizontalyInSuperview];
    [_container centerVerticalyInSuperview];
}

- (void)createButtonsInContainer:(UIView *)buttonContainer
{
    CGRect cancelButtonRect = CGRectMake(0, 0, 
                                   _cancelButtonImageNormal.size.width, 
                                   _cancelButtonImageNormal.size.height);
    
    CGRect otherButtonRect = CGRectMake(0, 0, 
                                  _otherButtonImageNormal.size.width, 
                                  _otherButtonImageNormal.size.height);

    if (_otherButtonTitle != nil)
    {
        self.cancelButton = [[[UIButton alloc] initWithFrame:cancelButtonRect] autorelease];
        [_cancelButton setTag:1];
        [_cancelButton setImage:_cancelButtonImageNormal forState:UIControlStateNormal];
        [_cancelButton setImage:_cancelButtonImageDown forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:_cancelButton];
        
        _cancelButtonLabel.frame = cancelButtonRect;
        _cancelButtonLabel.userInteractionEnabled = NO;
        _cancelButtonLabel.text = _cancelButtonTitle;
        [buttonContainer addSubview:_cancelButtonLabel];
        
        //    if (_otherButtonTitle != nil) {
        self.otherButton = [[[UIButton alloc] initWithFrame:otherButtonRect] autorelease];
        [_otherButton setTag:0];
        [_otherButton setImage:_otherButtonImageNormal forState:UIControlStateNormal];
        [_otherButton setImage:_otherButtonImageDown forState:UIControlStateHighlighted];
        [_otherButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:_otherButton];
        [_otherButton placeRightOfView:_cancelButton withMargin:_buttonsCenterSpacing];
        otherButtonRect = _otherButton.frame;
        
        _otherButtonLabel.frame = otherButtonRect;
        _otherButtonLabel.userInteractionEnabled = NO;
        _otherButtonLabel.text = _otherButtonTitle;
        [buttonContainer addSubview:_otherButtonLabel];
        //    }    
        [buttonContainer setSize:CGSizeMake(_buttonsCenterSpacing + cancelButtonRect.size.width+otherButtonRect.size.width, otherButtonRect.size.height)];
        
    } else {
        self.cancelButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, _singleButtonImageNormal.size.width, _singleButtonImageDown.size.height)] autorelease];
        [_cancelButton setTag:1];
        [_cancelButton setImage:_singleButtonImageNormal forState:UIControlStateNormal];
        [_cancelButton setImage:_singleButtonImageDown forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonContainer addSubview:_cancelButton];
        
        _cancelButtonLabel.frame = _cancelButton.frame;
        _cancelButtonLabel.userInteractionEnabled = NO;
        _cancelButtonLabel.text = _cancelButtonTitle;
        [buttonContainer addSubview:_cancelButtonLabel];
        [buttonContainer setSize:_cancelButton.frame.size];
    }
   
}

#pragma mark - Styling

- (void)adjustMessageLabelHeightUsingWidth:(CGFloat)width
{
    [_messageLabel setSize:CGSizeMake(width, 40)];
    
    [_messageLabel sizeToFit];
    [_messageLabel setWidth:width];
}

- (void)styleMessageLabel
{
    if (_messageLabel) {
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textAlignment = UITextAlignmentCenter;
        _messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        _messageLabel.textColor = _textColor;
        _messageLabel.shadowColor = _textShadowColor;
        _messageLabel.shadowOffset = _textShadowOffset;
        _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
        _messageLabel.numberOfLines = 0;
    }
}

- (void)styleTitleLabel
{
    if (_titleLabel) {
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
        _titleLabel.textColor = _textColor;
        _titleLabel.shadowColor = _textShadowColor;
        _titleLabel.shadowOffset = _textShadowOffset;
        _titleLabel.text = _title;
        _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
}

#pragma mark - Actions

- (void)buttonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (self.willDismissAlertAction) {
        _willDismissAlert();
    }
    
    if ([self.cancelButton isEqual:button]) {
        LogTrace(@"CustomAlert: Cancel");
        if (self.dismissAction) {
            LogTrace(@"CustomAlert: Dismiss action");
            _dismissAction();
        }
        [self dismiss];
    } else if ([self.otherButton isEqual:button]) {
        LogTrace(@"CustomAlert: OK");
        if (self.confirmAction) {
            _confirmAction();   
        }
        [self remove];
    } else {    
        [self dismiss];
    }
}


- (void)remove
{
    LogTrace(@"CustomAlert: Main remove switch");
    switch (self.removeTransitionStyle) {
        case CTAlertDismissTransitionStyleDrop:
            [self drop];
            break;
        case CTAlertDismissTransitionStyleNormal:
            [self dismissNormal];
            break;
        case CTAlertDismissTransitionStyleSlideOut:
            [self slideOut];
            break;
        case CTAlertDismissTransitionStyleGrow:
            [self grow];
            break;
        default:
            break;
    }
}

- (void)show 
{
    [self alignSubviews];
    LogTrace(@"CustomAlert: Main show switch");
    switch (self.showTransitionStyle) {
        case CTAlertShowTransitionStyleNormal:
            [self normalShow];
            break;
        case CTAlertShowTransitionStyleSlideIn:
            [self slideIn];
            break;
        default:
            break;
    }
}

- (void)dismiss
{
    LogTrace(@"CustomAlert: Main dismiss switch");
    switch (self.dismissTransitionStyle) {
        case CTAlertDismissTransitionStyleDrop:
            [self drop];
            break;
        case CTAlertDismissTransitionStyleNormal:
            [self dismissNormal];
            break;
        case CTAlertDismissTransitionStyleSlideOut:
            [self slideOut];
            break;
        case CTAlertDismissTransitionStyleGrow:
            [self grow];
            break;
        default:
            break;
    }
}

#pragma mark - Animations

#pragma mark showing

- (void)normalShow
{
    LogTrace(@"CustomAlert: Default show");
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _container.alpha = 0.0;
    _backgroundView.alpha = 0.0;
    _container.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    [window addSubview:self];
    
    void (^phase1)(void) = ^{
        _backgroundView.alpha = 0.7;
    };
    
    void (^phase2)(void) = ^{
        _container.alpha = 0.7;
        _container.transform = CGAffineTransformMakeScale(1.05, 1.05);
        _backgroundView.alpha = 0.8;
    };
    
    void (^phase3)(void) = ^{
        _container.alpha = 0.85;
        _container.transform = CGAffineTransformMakeScale(0.95, 0.95);
        _backgroundView.alpha = 0.9;
    };
    
    void (^phase4)(void) = ^{
        _container.alpha = 1.0;
        _container.transform = CGAffineTransformMakeScale(1.0, 1.0);
        _backgroundView.alpha = 1.0;
    };
    
    if (self.willShowAlertAction) {
        _willShowAlert();
    }
    
    [UIView
     animateWithDuration:0.05
     delay:0.0
     options:UIViewAnimationCurveEaseIn
     animations:phase1
     completion:^(BOOL finished){
         [UIView
          animateWithDuration:0.2 
          delay:0.0 
          options:UIViewAnimationCurveEaseIn 
          animations:phase2
          completion:^(BOOL finished){
              [UIView 
               animateWithDuration:0.1 
               delay:0.0 
               options:UIViewAnimationCurveLinear animations:phase3 
               completion:^(BOOL finished){
                   [UIView 
                    animateWithDuration:0.1 
                    delay:0.0
                    options:UIViewAnimationCurveEaseOut 
                    animations:phase4 
                    completion:^(BOOL finished){
                        if (self.didShowAlertAction) {
                            _didShowAlert();
                        }
                    }];
               }];
          }];
         
     }];
    
}

- (void)slideIn
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _container.alpha = 0.0;
    _backgroundView.alpha = 0.0;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _container.transform = CGAffineTransformMakeTranslation(screenWidth, 0);
    [window addSubview:self];
    
    
    if (self.willShowAlertAction) {
        _willShowAlert();
    }
    
    [UIView animateWithDuration:0.4 
                          delay:0.0 
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         _container.alpha = 1.0;
                         _container.transform = CGAffineTransformMakeTranslation(0, 0);
                         
                         //                         if (_useDefaultDimmBackground)
                         _backgroundView.alpha = 1.0;   
                     } 
                     completion:^(BOOL finished){
                         if (self.didShowAlertAction) {
                             _didShowAlert();
                         }                   
                         //                         NSLog(@"CustomAlert: Slide in: did show alert");
                         //                         NSLog(@"Container properties: \n\tsuperview: %@\n\talpha: %lf\n\ttxTransform: %lf", _container.superview, _container.alpha, _container.transform.tx);
                     }];
}

#pragma mark removing

- (void)slideOut
{
    LogTrace(@"CustomAlert: Slide out");
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    if (self.willDismissAlertAction) {
        _willDismissAlert();
    }
    
    [UIView animateWithDuration:0.4 
                          delay:0.0 
                        options:UIViewAnimationCurveEaseIn 
                     animations:^{
//                         if (_useDefaultDimmBackground)
                             _backgroundView.alpha = 0.0;
                         
                         _container.transform = CGAffineTransformMakeTranslation(-screenWidth, 0);
                         _container.alpha = 0.0;
                     } 
                     completion:^(BOOL finished){
                         if (self.didDismissAlertAction) {
                             _didDismissAlert();
                         }
                         _container.transform = CGAffineTransformMakeTranslation(0, 0);
                         [self removeFromSuperview];
                     }];
}

- (void)drop
{  
    LogTrace(@"CustomAlert: Drop");
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    void (^dropping)(void) = 
    ^{
        _container.alpha = 0.7;
        _container.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(RAD(60)),
                                                       CGAffineTransformMakeTranslation(0, screenHeight));
        _backgroundView.alpha = 0.0;
    };

    
    [UIView animateWithDuration:0.375
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:dropping
                     completion:^(BOOL finished) {
                         if (self.didDismissAlertAction) {
                             _didDismissAlert();
                         }
                         [self removeFromSuperview]; 
                     }];
}

- (void)dismissNormal
{
    LogTrace(@"CustomAlert: Dismiss normal");
    [UIView animateWithDuration:0.1 animations:^{
        _backgroundView.alpha = 0.0;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseIn 
                         animations:^{
                             _container.alpha = 0.0;
                         } 
                         completion:^(BOOL finished){
                             if (self.didDismissAlertAction) {
                                 _didDismissAlert();
                             }
                             [self removeFromSuperview];
                         }];
    }];
    
}

- (void)grow
{
    LogTrace(@"CustomAlert: Shrink disappear");
    
    void (^phase1)(void) = ^{
        _container.transform = CGAffineTransformMakeScale(0.9, 0.9);
        _container.alpha = 1.0;
        _backgroundView.alpha = 1.0;
    };
    
    void (^phase2)(void) = ^{
        _container.transform = CGAffineTransformMakeScale(2.0, 2.0);
        _container.alpha = 0.0;
        _backgroundView.alpha = 0.0;
    };
    
    [UIView 
     animateWithDuration:0.2
     delay:0.0
     options:UIViewAnimationOptionCurveEaseIn
     animations:phase1
     completion:^(BOOL finished) {
         [UIView animateWithDuration:0.275
                               delay:0.0
                             options:UIViewAnimationOptionCurveLinear
                          animations:phase2
                          completion:^(BOOL finished) {
                              [self removeFromSuperview];
                          }];
     }];
}

#pragma mark - Misc

- (void)dealloc {
    self.topImage = nil;
    self.bottomImage = nil;
    self.centerImage = nil;
    self.cancelButtonImageNormal = nil;
    self.cancelButtonImageDown = nil;
    self.otherButtonImageNormal = nil;
    self.otherButtonImageDown = nil;
    self.message = nil;
    self.title = nil;
    self.cancelButtonTitle = nil;
    self.otherButtonTitle = nil;
    self.titleLabel = nil;
    self.messageLabel = nil;
    self.otherButtonLabel = nil;
    self.cancelButtonLabel = nil;
    self.cancelButton = nil;
    self.otherButton = nil;
    self.textColor = nil;
    self.textShadowColor = nil;
    self.willDismissAlertAction = nil;
    self.willShowAlertAction = nil;
    self.didDismissAlertAction = nil;
    self.didShowAlertAction = nil;
    self.confirmAction = nil;
    self.dismissAction = nil;
    [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
