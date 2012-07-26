//
//  UILabel+FixedSize.m
//  CoconutTouch
//
//  Created by Mariusz Śpiewak on 7/9/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import "UILabel+FixedSize.h"
@implementation UILabel (FixedSize)


- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = UILineBreakModeWordWrap;
    self.numberOfLines = 0;
    [self sizeToFit];
}

- (NSInteger)numberOfTextLines
{
    if (self.numberOfLines != 0) {
        return self.numberOfLines;
    }
    
    CGSize oneLineSize = [@" " sizeWithFont:self.font 
                          constrainedToSize:self.frame.size 
                              lineBreakMode:self.lineBreakMode];
    CGSize textSize = [self.text sizeWithFont:self.font 
                            constrainedToSize:self.frame.size 
                                lineBreakMode:self.lineBreakMode];
    
    return (int)roundf(textSize.height/oneLineSize.height);
}

@end

