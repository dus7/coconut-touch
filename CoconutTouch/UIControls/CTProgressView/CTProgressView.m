//
//  ProgressView.m
//  
//
//  Created by Mariusz Śpiewak on 7/2/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import "CTProgressView.h"

@interface CTProgressView ()

@property (nonatomic, retain) UIImageView *progressImageView;

- (void)progressUpdated;
- (void)updateOrigin;
@end

@implementation CTProgressView

@synthesize progressImage=_progressImage;
@synthesize progress=_progress;
@synthesize direction=_direction;
@synthesize progressImageView=_progressImageView;

@synthesize animated=_animated;
@synthesize stepDuration=_stepDuration;

- (id)initWithProgressImage:(UIImage *)progressImage
{
    self = [self initWithFrame:CGRectMake(0, 0, progressImage.size.width, progressImage.size.height)];
    if (self) {
        self.progressImage = progressImage;
        self.progressImageView = [[[UIImageView alloc] initWithImage:_progressImage] autorelease];
        _progressImageView.clipsToBounds = YES;
        [self addSubview:_progressImageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _stepDuration = 0.2;
        _animated = YES;
        _direction = CTProgressDirectionBottom;
        [self updateOrigin];
        self.progress = 0.0;
    }
    return self;
}

#pragma mark - Extensions

- (void)updateOrigin
{
//    CGPoint anchorPoint;
    UIViewContentMode contentMode;
    
    switch (_direction) {
        case CTProgressDirectionTop:
//            anchorPoint = CGPointMake(0.5, 0.0);
            contentMode = UIViewContentModeBottom;
            break;
        case CTProgressDirectionBottom:
//            anchorPoint = CGPointMake(0.5, 1.0);
            contentMode = UIViewContentModeTop;
            break;
        case CTProgressDirectionLeft:
//            anchorPoint = CGPointMake(1.0, 0.5);
            contentMode = UIViewContentModeRight;
            break;
        case CTProgressDirectionRight:
//            anchorPoint = CGPointMake(0.0, 0.5);
            contentMode = UIViewContentModeLeft;
            break;
        default:
            break;
    }
    _progressImageView.contentMode = contentMode;
//    _progressImageView.layer.anchorPoint = anchorPoint;
}

- (void)progressUpdated
{
    void ((^animation)(void)) = ^{
        if (_direction == CTProgressDirectionBottom || _direction == CTProgressDirectionTop) {
            CGFloat newHeight = _progressImage.size.height*_progress; 
            if (_direction == CTProgressDirectionTop) {
                [_progressImageView setFrame:CGRectMake(_progressImageView.frame.origin.x, _progressImage.size.height - newHeight, _progressImageView.frame.size.width, newHeight)];
            } else {
                [self.progressImageView setHeight:newHeight];
            }
        } else {
            CGFloat newWidth = _progressImage.size.width*_progress;
            if (_direction == CTProgressDirectionLeft) {
                [_progressImageView setFrame:CGRectMake(_progressImage.size.width - newWidth, _progressImageView.frame.origin.y, newWidth, _progressImageView.frame.size.height)];                
            } else {
                [self.progressImageView setWidth:_progressImage.size.width*_progress];   
            }
        }
    };
    
    if (_animated) {
        [UIView animateWithDuration:_stepDuration animations:animation];
    } else {
        animation();
    }
}

#pragma mark - Custom setters

- (void)setDirection:(CTProgressDirection)direction
{
    _direction = direction;
    [self updateOrigin];
}

- (void)setProgress:(double)progress
{
    if (progress > 1.0) {
        _progress = 1.0;
    } else if (progress < 0.0) {
        _progress = 0.0;
    } else {
        _progress = progress;   
    }
    [self progressUpdated];
}

@end
