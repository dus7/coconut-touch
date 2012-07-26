//
//  UILabel+FixedSize.h
//  CoconutTouch
//
//  Created by Mariusz Śpiewak on 7/9/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (FixedSize)
- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth;
- (NSInteger)numberOfTextLines;
@end

