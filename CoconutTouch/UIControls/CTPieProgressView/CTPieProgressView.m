//
//  PieProgress.m
//  progressPie
//
//  Created by Mariusz Śpiewak on 11-10-05.
//  Copyright 2011 Mariusz Śpiewak. All rights reserved.
//

#import "CTPieProgressView.h"

@interface CTPieProgressView ()
- (void)frameTimerFire;
@property (nonatomic, assign) float internalProgress;
@end

@implementation CTPieProgressView

@synthesize variableAngle=_variableAngle;
@synthesize frameInterval=_frameInterval;
@synthesize progress=_progress;
@synthesize frameTimer=_frameTimer;
@synthesize isInfinite=_isInfinite;
@synthesize isAnimating=_isAnimating;
@synthesize invertGraphics=_invertGraphics;
@synthesize pieColor;
@synthesize internalProgress=_internalProgress;
@synthesize negativePieColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _variableAngle = YES;
        _frameInterval = 0.005;
        self.backgroundColor = [UIColor clearColor];
        self.frameTimer = [NSTimer scheduledTimerWithTimeInterval:_frameInterval target:self selector:@selector(frameTimerFire) userInfo:nil repeats:YES];
        angle = 0;
        self.progress = 0;
        self.pieColor = [UIColor blackColor];
        self.negativePieColor = [UIColor clearColor];
    }
    return self;
}

- (void)startAnimated:(BOOL)animated infinite:(BOOL)infinite {
    _internalProgress = 0.0;
    _isAnimating = animated;
    _isInfinite = infinite;
    
    if (!animated)
    {
        _internalProgress = _progress;
        [self setNeedsDisplay];
    }
}

- (void)stop {
    _isAnimating = NO;
}

- (void)frameTimerFire {
    if(!_isAnimating) return;
    if (_variableAngle) {
        angle += (M_PI*5)/360;
    }
    self.transform = CGAffineTransformMakeRotation(angle);
    double step = (_progress / 1000);
    if (_isInfinite) {
        if (inverted) 
            [self setInternalProgress:_internalProgress - step];    
        else
            [self setInternalProgress:_internalProgress + step];
    } else {
        if (_internalProgress + 0.003 >= _progress) {
            _internalProgress = _progress;
            _isAnimating = NO;
        } else {
            _internalProgress += 0.003;
        }
        [self setNeedsDisplay];
    }
}

- (void)setInternalProgress:(float)progress {
    _internalProgress = progress;
    if(_isInfinite){
        if (_internalProgress >= 1) {
            inverted = YES;
            _internalProgress = 1;
        } else if (_internalProgress <= 0) {
            _internalProgress = 0;
            inverted = NO;
        }
    }
    [self setNeedsDisplay];
}

- (void)setProgress:(float)progress {
    _progress = progress;
    if(_isInfinite){
        if (_progress >= 1) {
            inverted = YES;
            _progress = 1;
        } else if (_progress <= 0) {
            _progress = 0;
            inverted = NO;
        }
    }
    [self setNeedsDisplay];
}


void drawPieChartForContext (CGContextRef context, int width, int height, float percentage, CGColorRef fillColor, CGColorRef bgColor)
{
    CGContextBeginPath(context);
    
	//There are 2 pi radians in a full circle
	//Note that I will make the arc go backwards.
	float twopi = (2.0 * (float)M_PI) * -1.0;
    
	//Calculate the angle for the first slice
	float angleTop = twopi * percentage;
    
	//Calculate the arc start points, center of the circle
	float x = width / 2.0;
	float y = height / 2.0;
    
	//Set the radius
	float radius = x;
    
	//Add the first arc path from 0 to first angle
    CGContextAddArc(context, x, y, radius, 0, angleTop, YES);
    
    CGContextAddLineToPoint(context, x, y);

    CGContextAddArc(context, x, y, radius, 0, angleTop, YES);
    CGContextAddLineToPoint(context, x, y);
    
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillPath(context);
         
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);    

    CGContextClearRect(context, rect);

//    CGContextSetAlpha(context,0.0);
//    CGContextSetStrokeColorWithColor(context, [negativePieColor CGColor]);
//    CGContextFillRect(context, rect);
//    
////    CGContextSetAlpha(context, 1.0);
    
    if(_invertGraphics)
        drawPieChartForContext(context, rect.size.width, rect.size.height, _internalProgress ,[negativePieColor CGColor], [pieColor CGColor]);
    else
        drawPieChartForContext(context, rect.size.width, rect.size.height, _internalProgress ,[pieColor CGColor], [negativePieColor CGColor]);
}

- (void)dealloc
{
    [self.frameTimer invalidate];
    self.frameTimer = nil;
    [super dealloc];
}

@end
