//
//  PieProgress.h
//  progressPie
//
//  Created by Mariusz Śpiewak on 11-10-05.
//  Copyright 2011 Mariusz Śpiewak. All rights reserved.
//

#import <UIKit/UIKit.h>

void drawPieChartForContext (CGContextRef context, int width, int height, float percentage, CGColorRef baseColor, CGColorRef strokeColor);

@interface CTPieProgressView : UIView {
    float angle;
    BOOL inverted;
}

@property (nonatomic) float progress;
@property (nonatomic, retain) NSTimer *frameTimer;
@property (nonatomic, readonly) BOOL isAnimating;
@property (nonatomic, readonly) BOOL isInfinite;
@property (nonatomic) BOOL invertGraphics __attribute__((unavailable));
@property (nonatomic, assign) BOOL variableAngle;
@property (nonatomic, assign) NSTimeInterval frameInterval;

@property (nonatomic, retain) UIColor *pieColor;
@property (nonatomic, retain) UIColor *negativePieColor;

- (void)startAnimated:(BOOL)animated infinite:(BOOL)infinite;
- (void)stop;

@end
