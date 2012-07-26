//
//  ProgressView.h
//  
//
//  Created by Mariusz Śpiewak on 7/2/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+FrameProperties.h"

enum {
    CTProgressDirectionTop,
    CTProgressDirectionBottom,
    CTProgressDirectionLeft,
    CTProgressDirectionRight
};
typedef NSInteger CTProgressDirection;

@interface CTProgressView : UIView

- (id)initWithProgressImage:(UIImage *)progressImage;

@property (nonatomic, retain) UIImage *progressImage;
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) CTProgressDirection direction;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) NSTimeInterval stepDuration;

@end
