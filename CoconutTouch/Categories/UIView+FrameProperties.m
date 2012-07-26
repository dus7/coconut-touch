//
//  UIView+FrameProperties.m
//
//  Created by Mariusz Śpiewak
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import "UIView+FrameProperties.h"

@implementation UIView (Adjustment)

#pragma mark - Origin

- (void)setOriginByTransformX:(CGFloat)x Y:(CGFloat)y
{
    [self setFrame:CGRectMake(self.frame.origin.x + x, self.frame.origin.y + y, self.frame.size.width, self.frame.size.height)];
} 

- (void)setOriginX:(CGFloat)x
{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(x, frame.origin.y, frame.size.width , frame.size.height)];
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(origin.x, origin.y, frame.size.width, frame.size.height)];
}


#pragma mark - Resizing

- (void)setWidth:(CGFloat)w
{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, w, frame.size.height)];
}

- (void)setHeight:(CGFloat)h
{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, h)];    
}


- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height)];
}


#pragma mark - Aligning

- (void)placeBelowView:(UIView *)baseView withMargin:(CGFloat)margin
{
    [self setOriginY:baseView.frame.origin.y + baseView.frame.size.height + margin];
}

- (void)placeAboveView:(UIView *)baseView withMargin:(CGFloat)margin
{
    [self setOriginY:baseView.frame.origin.y - (self.frame.size.height + margin)];
}

- (void)placeLeftOfView:(UIView *)baseView withMargin:(CGFloat)margin
{
    [self setOriginX:baseView.frame.origin.x - (self.frame.size.width + margin)];
}

- (void)placeRightOfView:(UIView *)baseView withMargin:(CGFloat)margin
{
    [self setOriginX:baseView.frame.origin.x + baseView.frame.size.width + margin];
}

- (void)centerHorizontalyInRect:(CGRect)rect
{
    CGFloat marginLeft = rect.size.width - self.frame.size.width;
    CGFloat sideMargin = marginLeft/2.0;
    [self setOriginX:rect.origin.x + sideMargin];
}

- (void)centerVerticalyInRect:(CGRect)rect
{
    CGFloat marginLeft = rect.size.height - self.frame.size.height;
    CGFloat topMargin = marginLeft/2.0;
    [self setOriginY:rect.origin.y + topMargin];
}

- (void)centerVerticalyInSuperview
{
    [self centerVerticalyInRect:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height)];
}

- (void)centerHorizontalyInSuperview
{
    [self centerHorizontalyInRect:CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height)];    
}



@end
