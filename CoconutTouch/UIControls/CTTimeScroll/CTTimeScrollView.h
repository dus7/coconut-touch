//
//  CLTimeScrollView.h
//  CLTimeScroll
//
//  Created by Mariusz Śpiewak on 23.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCLTimeScrollViewPixelPerHour 50
#define kCLTimeScrollViewLaneCount 3
#define kCLTimeScrollViewHourLaneWidth 20
#define kCLTimeScrollViewLaneWidth 80

#pragma mark - CLTimeScrollViewEvent

@class CTTimeScrollViewEvent;

@protocol CTTimeScrollViewEventDelegate <NSObject>

- (void)eventTouched:(CTTimeScrollViewEvent *)event;

@end

@interface CTTimeScrollViewEvent : UIView {
}

@property (nonatomic, assign) id<CTTimeScrollViewEventDelegate> delegate;

@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

@property (nonatomic, retain) UIView *cellBg;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, readonly) UIButton *button;


- (id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (void)adjustHeightUsingPointsPerHour:(NSInteger)pph;
- (void)adjustWidthUsingPointsPerHour:(NSInteger)pph;
- (void)buttonTouched:(id)sender;

@end

#pragma mark - CLTimeScrollView

@class CLTimeScrollView;

@protocol CLTimeScrollViewDataSource <NSObject>

@required
- (NSUInteger)numberOfLanesInTimeScrollView:(CLTimeScrollView *)timeScrollView;
- (NSUInteger)timeScrollView:(CLTimeScrollView *)timeScrollView numberOfEventsForLane:(NSInteger)laneIndex;
- (CTTimeScrollViewEvent *)timeScrollView:(CLTimeScrollView *)timeScrollView eventViewForIndex:(NSInteger)eventIndex forLane:(NSInteger)laneIndex;

@optional
//Common
- (CGFloat)timeScrollViewPixelsPerHour:(CLTimeScrollView *)timeScrollView;
- (UIView *)timeScrollView:(CLTimeScrollView *)timeScrollView timeStripViewWithLength:(CGFloat)length;
//Hour Lane
- (CGFloat)timeScrollViewHourLaneThickness:(CLTimeScrollView *)timeScrollView;
- (UIView *)timeScrollView:(CLTimeScrollView *)timeScrollView timeViewForComponents:(NSDateComponents *)components thickness:(CGFloat)thickness length:(CGFloat)length;
//Event Lane
- (CGFloat)timeScrollView:(CLTimeScrollView *)timeScrollView thicknessForLane:(NSInteger)laneIndex;
- (UIView *)timeScrollView:(CLTimeScrollView *)timeScrollView laneSeparatorForIndex:(NSInteger)laneIndex;

@end

#pragma mark - CLTimeScrollViewDelegate

@protocol CLTimeScrollViewDelegate <NSObject>

- (void)timeScrollView:(CLTimeScrollView *)timeScrollView didSelectEvent:(NSInteger)eventIndex onLane:(NSInteger)laneIndex;

@end

@interface CLTimeScrollView : UIView <CTTimeScrollViewEventDelegate> {
    NSMutableArray *_laneSeparators;
	NSMutableDictionary *_contents;
	NSDate *_scrollStartDate;
	NSDate *_scrollEndDate;
}

@property (nonatomic, readonly) UIInterfaceOrientation orientation;
@property (nonatomic, readonly) UIScrollView *contentScroll;
@property (nonatomic, assign) NSTimeInterval hourStripUpdateInterval;
@property (nonatomic, assign) BOOL omitsDayForHourStrip;
@property (nonatomic, assign) id<CLTimeScrollViewDataSource> dataSource;
@property (nonatomic, assign) id<CLTimeScrollViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andOrientation:(UIInterfaceOrientation)orientation;

- (void)refreshEventViewForIndex:(NSInteger)eventIndex forLane:(NSInteger)laneIndex;
- (void)reloadContent;


@end
