//
//  CustomAlertView.h
//  CustomAlertView
//
//  Created by Mariusz Śpiewak on 11-12-02.
//  Copyright (c) 2011 Mariusz Śpiewak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+FrameProperties.h"

#define ALERT_WIDTH 290.0
#define ALERT_MIN_CENTER_HEIGHT (double)(165-37-26)
#define ALERT_MIN_HEIGHT 165.0
#define ALERT_BUTTON_HEIGHT 44.0

#define ALERT_BUTTON_CENTER_SPACING 4.0
#define ALERT_TITLE_TOP_OFFSET 5.0
#define ALERT_MESSAGE_OFFSET 15.0 //Vertical
#define ALERT_MESSAGE_SPACING 10.0 //Horizontal

#define ALERT_MESSAGE_VMARGIN 15.0 //Vertical
#define ALERT_MESSAGE_HMARGIN 20.0 //Horizontal

#define ALERT_TITLE_HEIGHT 37.0

#define ALERT_IMG_TOP [UIImage imageNamed:@"Alert_top.png"]
#define ALERT_IMG_CENTER [UIImage imageNamed:@"Alert_center.png"]
#define ALERT_IMG_BOTTOM [UIImage imageNamed:@"Alert_bottom.png"]
#define ALERT_IMG_BUTTON_OTHER_NORMAL [UIImage imageNamed:@"Other_OFF.png"]
#define ALERT_IMG_BUTTON_OTHER_DOWN [UIImage imageNamed:@"Other_ON.png"]
#define ALERT_IMG_BUTTON_CANCEL_NORMAL [UIImage imageNamed:@"Cancel_OFF.png"]
#define ALERT_IMG_BUTTON_CANCEL_DOWN [UIImage imageNamed:@"Cancel_ON.png"]
#define ALERT_IMG_BUTTON_SINGLE_NORMAL [UIImage imageNamed:@"Alert_Long_OFF.png"]
#define ALERT_IMG_BUTTON_SINGLE_DOWN [UIImage imageNamed:@"Alert_Long_ON.png"]

#define RAD(deg) (deg*(M_PI/180.0))
#define DEG(rad) (rad*(180.0/M_PI))

#define SHADOW_OFFSET CGSizeMake(0, -1)

enum {
    CTAlertDismissTransitionStyleSlideOut,
    CTAlertDismissTransitionStyleNormal,
    CTAlertDismissTransitionStyleDrop,
    CTAlertDismissTransitionStyleGrow
};
typedef NSUInteger CTAlertDismissTransitionStyle;

enum {
    CTAlertShowTransitionStyleNormal,
    CTAlertShowTransitionStyleSlideIn
};
typedef NSUInteger CTAlertShowTransitionStyle;

@interface CTAlertView : UIView {
    UIImageView *_topImageView, *_bottomImageView;
    UIView *_backgroundView;
    
    CGRect _messageLabelRect, _centerFieldRect, _cancelButtonRect, _otherButtonRect, _titleLabelRect;
}

@property(nonatomic, retain) UIImage *topImage;
@property(nonatomic, retain) UIImage *bottomImage;
@property(nonatomic, retain) UIImage *centerImage;
@property(nonatomic, retain) UIImage *cancelButtonImageNormal;
@property(nonatomic, retain) UIImage *cancelButtonImageDown;
@property(nonatomic, retain) UIImage *otherButtonImageNormal;
@property(nonatomic, retain) UIImage *otherButtonImageDown;
@property(nonatomic, retain) UIImage *singleButtonImageNormal;
@property(nonatomic, retain) UIImage *singleButtonImageDown;
@property(nonatomic, retain) UIImage *backgroundImage;

@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *cancelButtonTitle;
@property(nonatomic, retain) NSString *otherButtonTitle;

@property(nonatomic, retain) UIView *centerView;
@property(nonatomic, retain) UIView *userView;

@property(nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, retain) UILabel *messageLabel;
@property(nonatomic, retain) UILabel *otherButtonLabel;
@property(nonatomic, retain) UILabel *cancelButtonLabel;
@property(nonatomic, retain) UIButton *cancelButton;
@property(nonatomic, retain) UIButton *otherButton;

@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic, retain) UIColor *textShadowColor;
@property(nonatomic, assign) CGSize textShadowOffset;

@property(atomic, assign) CTAlertShowTransitionStyle showTransitionStyle;
@property(atomic, assign) CTAlertDismissTransitionStyle dismissTransitionStyle;
@property(atomic, assign) CTAlertDismissTransitionStyle removeTransitionStyle;

@property(atomic, assign) BOOL useDefaultDimmBackground;
@property(atomic, assign) BOOL buttonsOnBottomView;
@property(atomic, assign) BOOL userViewBelowMessage;

@property(nonatomic, assign) CGFloat buttonsVerticalSpacing;
@property(nonatomic, assign) CGFloat messageVerticalSpacing;
@property(nonatomic, assign) CGFloat buttonsCenterSpacing;

@property(nonatomic, copy) void (^dismissAction)(void);
@property(nonatomic, copy) void (^confirmAction)(void);
@property(nonatomic, copy) void (^willShowAlertAction)(void);
@property(nonatomic, copy) void (^didShowAlertAction)(void);
@property(nonatomic, copy) void (^willDismissAlertAction)(void);
@property(nonatomic, copy) void (^didDismissAlertAction)(void);

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle userView:(UIView *)userView;
+ (CTAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
+ (CTAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle userView:(UIView *)userView;

- (void)show;
- (void)dismiss;
- (void)remove;

@end

@interface GradientView : UIView

@end
