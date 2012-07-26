//
//  CLTimeScrollView.m
//  CLTimeScroll
//
//  Created by Mariusz Śpiewak on 23.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CT TimeScrollView.h"
#import "UILabel+FixedSize.h"
#import "UIView+FrameProperties.h"
#import "Logging.h"

@interface CTTimeScrollViewEvent ()
@property (nonatomic) NSInteger itemIndex;
@property (nonatomic) NSInteger laneIndex;

@end

@implementation CTTimeScrollViewEvent

@synthesize itemIndex;
@synthesize laneIndex;

@synthesize startDate=_startDate;
@synthesize endDate=_endDate;
@synthesize cellBg = _cellBg;
@synthesize titleLabel=_titleLabel;
@synthesize button=_button;
@synthesize delegate=_delegate;

- (id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
	self = [super init];
	if (self)
    {
		self.startDate = startDate;
        self.endDate = endDate;
        
        _button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _button.backgroundColor = [UIColor clearColor];
        [_button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 3;
        _titleLabel.opaque = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        [self setAutoresizesSubviews:YES];
        
        [self addSubview:_titleLabel];
        [self addSubview:_button];
	}
	return self;
}

- (void)setCellBg:(UIView *)cellBg
{
    [self insertSubview:cellBg atIndex:0];
    _cellBg = cellBg;
}

- (void)buttonTouched:(id)sender
{
    if([_delegate respondsToSelector:@selector(eventTouched:)]) {
        [_delegate eventTouched:self];
    }
}

- (CGFloat)pixelsForTimeInterval:(NSTimeInterval)interval usingPointsPerHour:(NSInteger)pph
{
    CGFloat pixels = (interval / (3600.0)) * (double)pph;
    return pixels;
}

- (void)adjustHeightUsingPointsPerHour:(NSInteger)pph
{
    NSTimeInterval interval = [_endDate timeIntervalSinceDate:_startDate];
    [self setHeight:[self pixelsForTimeInterval:interval usingPointsPerHour:pph]];
    
    [_titleLabel setSize:self.frame.size];
    [_cellBg setSize:self.frame.size];
    [_button setSize:self.frame.size];
}

- (void)adjustWidthUsingPointsPerHour:(NSInteger)pph {
    NSTimeInterval interval = [_endDate timeIntervalSinceDate:_startDate];
    CGFloat width = [self pixelsForTimeInterval:interval usingPointsPerHour:pph];
    [self setWidth: width];

    [_titleLabel setSize:self.frame.size];
    [_titleLabel sizeToFitFixedWidth:width - 5];
    [_titleLabel centerHorizontalyInSuperview];
    [_titleLabel centerVerticalyInSuperview];
    [_cellBg setSize:self.frame.size];
    [_button setSize:self.frame.size];
}

- (void)dealloc {
    self.startDate = nil;
    self.endDate = nil;
    self.titleLabel = nil;
    [_button release];
    [super dealloc];
}

@end

@interface CLTimeScrollView ()
{
    NSTimer *_hourStripTimer;
    UIView *_hourStripView;
}

- (NSUInteger)getEventCountForLane:(NSInteger)laneIndex;
- (NSUInteger)getLaneCount;
- (CGFloat)getPixelsPerHour;
- (CTTimeScrollViewEvent *)getEventViewForIndex:(NSInteger)index forLane:(NSInteger)laneIndex;
- (UIView *)getSeparatorForLaneIndex:(NSInteger)lane;
- (CGFloat) offsetForLaneIndex:(NSInteger)lane;
- (CGFloat)scrollContentLength;
- (CGFloat)scrollContentThickness;
- (CGFloat)getHourLaneThickness;
- (CGFloat)getThicknessForLane:(NSInteger)lane;
- (CGFloat)separatorThicknessForLaneIndex:(NSInteger)lane;
- (CGFloat)offsetFromStartForDate:(NSDate*)date;
- (void)grabContent;
- (void)assignBoundaryDatesUsingStart:(NSDate *)startDate endDate:(NSDate *)endDate;

- (void)commonInit;

- (void)placeObjects;
- (void)placeSeparatorOnLaneWithIndex:(NSNumber *)laneIndex;
- (void)placeEventsOnLaneWithIndex:(NSNumber*)laneIndex;
- (void)placeHourStrip;

- (void)moveStartDateToFullHour;
@end

@implementation CLTimeScrollView

@synthesize contentScroll=_contentScroll;
@synthesize dataSource=_dataSource;
@synthesize delegate=_delegate;
@synthesize orientation=_orientation;
@synthesize omitsDayForHourStrip=_omitsDayForHourStrip;
@synthesize hourStripUpdateInterval=_hourStripUpdateInterval;

- (id)init {
	self = [super initWithFrame:CGRectMake(0, 0, 320, 480)];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame andOrientation:(UIInterfaceOrientation)orientation
{
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
        _orientation = orientation;
	}
	return self;    
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	_scrollStartDate = nil;
	_scrollEndDate = nil;
    _orientation = UIInterfaceOrientationPortrait;
	_contents = [[NSMutableDictionary alloc] init];
	
	_contentScroll = [[UIScrollView alloc] initWithFrame:self.frame];
    _contentScroll.scrollEnabled = YES;
    _contentScroll.bounces = YES;
    _contentScroll.userInteractionEnabled = YES;
    _contentScroll.showsHorizontalScrollIndicator = NO;
    _contentScroll.showsVerticalScrollIndicator = NO;
	_contentScroll.backgroundColor = [UIColor clearColor];
    _omitsDayForHourStrip = YES;
    _hourStripView = nil;
    _hourStripTimer = nil;
    _hourStripUpdateInterval = 60;
    
    _laneSeparators = [[NSMutableArray alloc] init];
	
	[self addSubview:_contentScroll];
	[_contentScroll release];
}

- (void)dealloc {
	[_contents release];
    if (_hourStripTimer) {
         [_hourStripTimer invalidate];
        _hourStripTimer = nil;
    }
    _hourStripView = nil;
    [_laneSeparators release];
	[_scrollStartDate release];
	[_scrollEndDate release];
	[super dealloc];
}

#pragma mark - Public Methods

- (void)reloadContent {
    [self removeSubviews];
    _hourStripView = nil;
    _scrollStartDate = nil;
    [_scrollStartDate release];
	_scrollEndDate = nil;
    [_scrollEndDate release];
    
    [self grabContent];
    CGSize size;
    
    if (UIInterfaceOrientationIsPortrait(_orientation)) {
        size.width = [self scrollContentThickness];
        size.height = [self scrollContentLength];   
    } else {
        size.width = [self scrollContentLength];
        size.height = [self scrollContentThickness];
    }
    [_contentScroll setContentSize:size];
    
    [self placeObjects];
}

- (void)refreshEventViewForIndex:(NSInteger)eventIndex forLane:(NSInteger)laneIndex
{
    CTTimeScrollViewEvent *event = [self getEventViewForIndex:eventIndex forLane:laneIndex];
    
    NSMutableArray *eventsForLaneIndex = [_contents objectForKey:[NSNumber numberWithInt:laneIndex]];
    CTTimeScrollViewEvent *oldEvent = [eventsForLaneIndex objectAtIndex:eventIndex];
    [oldEvent removeFromSuperview];
    
    [[_contents objectForKey:[NSNumber numberWithInt:laneIndex]] replaceObjectAtIndex:eventIndex withObject:event];
    
    CGFloat laneOffset = [self offsetForLaneIndex:laneIndex];
    CGFloat hourOffset = 0;
    
    hourOffset = [self offsetFromStartForDate:event.startDate];   
    
    if (UIInterfaceOrientationIsPortrait(_orientation))
    {
        [event setWidth:[self getThicknessForLane:laneIndex]];
        [event setOrigin:CGPointMake(laneOffset, hourOffset)];
        [event adjustHeightUsingPointsPerHour:[self getPixelsPerHour]];
    } else {
        [event setHeight:[self getThicknessForLane:laneIndex]];
        [event setOrigin:CGPointMake(hourOffset, laneOffset)];
        [event adjustWidthUsingPointsPerHour:[self getPixelsPerHour]];
    }
    [self.contentScroll addSubview:event];
    event.laneIndex = laneIndex;
    event.itemIndex = eventIndex;
    event.delegate = self;
    
    [_hourStripView retain];
    [_hourStripView removeFromSuperview];
    [_contentScroll addSubview:_hourStripView];
    [_hourStripView release];
}

#pragma mark - Init Helpers

- (CGFloat)scrollContentLength {
    NSTimeInterval timeInterval = [_scrollEndDate timeIntervalSinceDate:_scrollStartDate];
//    NSLog(@"Time interval: %lf", timeInterval);
    double hours = (double)timeInterval / (60.0*60.0);
    CGFloat height = hours * [self getPixelsPerHour];
//    NSLog(@"Content scroll height: %f", height);
    return height;
}

- (CGFloat)scrollContentThickness {
    int laneCount = [self getLaneCount];
    CGFloat thickness = [self getHourLaneThickness];
    for (int i = 0; i < laneCount; i++) {
        thickness += [self separatorThicknessForLaneIndex:i];
        thickness += [self getThicknessForLane:i];
    }
//    NSLog(@"Content scroll thickness: %f", thickness);
    return thickness;   
}

- (void)assignBoundaryDatesUsingStart:(NSDate *)startDate endDate:(NSDate *)endDate {
	if (!_scrollStartDate) {
		_scrollStartDate = [[startDate dateByAddingTimeInterval:-1800] retain];
	} else {
		if ([_scrollStartDate timeIntervalSinceDate:startDate] > -1800) {
			[_scrollStartDate release];
			_scrollStartDate = [[startDate dateByAddingTimeInterval:-1800] retain];
		}
	}
	
	if (!_scrollEndDate) {
		_scrollEndDate = [endDate retain];
	} else {
		if ([_scrollEndDate timeIntervalSinceDate:endDate] < 0) {
			[_scrollEndDate release];
			_scrollEndDate = [endDate retain];
		}
	}
//    NSLog(@"Start: %@, end: %@", _scrollStartDate, _scrollEndDate);
}

- (void)grabContent
{
	[_contents removeAllObjects];
    [_contents release];
    _contents = [[NSMutableDictionary alloc] init];
    
	[_laneSeparators removeAllObjects];
    [_laneSeparators release];
    _laneSeparators = [[NSMutableArray alloc] init];
    
	NSInteger lanesCount = [self getLaneCount];

	for (int lane = 0; lane < lanesCount; lane++) {
		int eventsCount = [self getEventCountForLane:lane];
		
		NSMutableArray *events = [NSMutableArray arrayWithCapacity:eventsCount];
		for (int i = 0; i < eventsCount; i++) {
			CTTimeScrollViewEvent *event = [self getEventViewForIndex:i forLane:lane];
			[events addObject:event];	
			[self assignBoundaryDatesUsingStart:event.startDate endDate:event.endDate];
		}
		
		[_contents setObject:events forKey:[NSNumber numberWithInt:lane]];
        UIView *separator = [self getSeparatorForLaneIndex:lane];
        if (!separator) {
            [_laneSeparators addObject:[NSNull null]];
        } else {
            [_laneSeparators addObject:separator];
            if (UIInterfaceOrientationIsLandscape(_orientation)) {
                [separator setHeight:separator.frame.size.width];
            }
        }
	}
    
    [self moveStartDateToFullHour];
}

#pragma mark - Helper methods

- (void)removeSubviews
{
    for (UIView *view in _contentScroll.subviews) {
        [view removeFromSuperview];
    }
}

- (void)moveStartDateToFullHour
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:_scrollStartDate];
    
    [components setMinute:0];
    
    [_scrollStartDate release];
    
    _scrollStartDate = [[calendar dateFromComponents:components] retain];
//    NSLog(@"Components: %@, date: %@", components, _scrollStartDate);
    
    [calendar release];
}

- (CGFloat)separatorThicknessForLaneIndex:(NSInteger)laneIndex
{
    UIView *separator = [self separatorViewForLaneIndex:laneIndex];
//    UIView *separator = (UIView*)[_laneSeparators objectAtIndex:laneIndex];
    if (!separator) {
        return 0.0;
    }
    if (UIInterfaceOrientationIsPortrait(_orientation)) {
         return separator.frame.size.width;   
    } else {
        return separator.frame.size.height;   
    }
}

- (UIView*)separatorViewForLaneIndex:(NSInteger)laneIndex {
    UIView *separator = (UIView*)[_laneSeparators objectAtIndex:laneIndex];
    if ([separator isEqual:[NSNull null]]) {
        return nil;
    }
    return separator;
}


- (CGFloat)offsetForLaneIndex:(NSInteger)laneIndex {
    CGFloat offset = [self getHourLaneThickness];
    
    for (int i = 0; i <= laneIndex; i++) 
        offset += [self separatorThicknessForLaneIndex:i];
    
    for (int i = 0; i < laneIndex; i++)
        offset += [self getThicknessForLane:i];
    
    return offset;
}

- (CGFloat)offsetFromStartForDate:(NSDate *)date {
    NSTimeInterval interval = [date timeIntervalSinceDate:_scrollStartDate];
    return (interval / (60.0*60.0)) * (double)[self getPixelsPerHour];
}

#pragma mark - Display methods

- (void)placeObjects
{
    NSArray *lanes = [_contents allKeys];
    
    [self placeTimeline];
    
    for (NSNumber *laneIndex in lanes) {
        // Event placement
        [self placeEventsOnLaneWithIndex:laneIndex];
        
        // Separators placement
        [self placeSeparatorOnLaneWithIndex:laneIndex];
        
        // Initialize and place hour strip
    }
    [self placeHourStrip];
}

- (UIView *)defaultHourViewForComponents:(NSDateComponents *)components thickness:(CGFloat)thickness length:(CGFloat)length
{
    UILabel *hourView;
    if (UIInterfaceOrientationIsPortrait(_orientation)){
        hourView = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, thickness, length)] autorelease];
    } else {
        hourView = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, length, thickness)] autorelease];
    }
    
//    NSLog(@"Thickness: %lf, length: %lf", thickness, length);
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"HH:mm"];
    
    hourView.text = [df stringFromDate:[[NSCalendar currentCalendar] dateFromComponents:components]];
    hourView.textAlignment = UITextAlignmentCenter;
    
    if (components.hour % 2) {
        hourView.backgroundColor = [_contentScroll backgroundColor];
    } else {
        hourView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    }
    
    return hourView;
}

- (void)placeHourStrip
{
    UIView *hourStripView = nil;
    if (!_hourStripView) {
        hourStripView = [self getHourStripView];       
    } else {
        hourStripView = _hourStripView;
    }
    if (hourStripView) {
        
        NSDate *currentDate = [[NSDate date] dateByAddingTimeInterval:3600];
        CGFloat offsetForCurrentTime;
        NSTimeInterval interval;
        
        LogTrace(@"TimeScroll don't omits day");
        if (!_omitsDayForHourStrip && ![[_scrollStartDate laterDate:currentDate] isEqualToDate:[_scrollEndDate earlierDate:currentDate]]) {
            LogTrace(@"TimeScroll no time strip now - returning");
            return;
        }
        //            NSLog(@"Omitting date in hour calculation");
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit units = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *currentHour = [calendar components:units fromDate:currentDate];
        NSDateComponents *startHour = [calendar components:units fromDate:_scrollStartDate];
        
        NSTimeInterval currentInterval = [currentHour hour]*60.0*60.0 + [currentHour minute]*60.0 + [currentHour second];
        NSTimeInterval startInterval = [startHour hour]*60.0*60.0 + [startHour minute]*60.0 + [startHour second];
        
        interval = currentInterval - startInterval;
        
        offsetForCurrentTime = (interval / (60.0*60.0)) * (double)[self getPixelsPerHour];
//        NSLog(@"Offset: %lf", offsetForCurrentTime);
        if (UIInterfaceOrientationIsPortrait(_orientation)) {
            [hourStripView setOriginX:0];
            [hourStripView setOriginY:offsetForCurrentTime - hourStripView.frame.size.width/2.0];
            [hourStripView setWidth:[self scrollContentThickness]];            
        } else {
            [hourStripView setOriginX:offsetForCurrentTime - hourStripView.frame.size.width/2.0];
            [hourStripView setOriginY:0];            
            [hourStripView setHeight:[self scrollContentThickness]];
        }
//        NSLog(@"Strip View: %@", hourStripView);
        
        if (!_hourStripView)
            [self.contentScroll addSubview:hourStripView];
        _hourStripView = hourStripView;
        if (!_hourStripTimer) {
            _hourStripTimer = [NSTimer scheduledTimerWithTimeInterval:_hourStripUpdateInterval target:self selector:@selector(hourStripTimer:) userInfo:nil repeats:YES];
        }
    }
}

- (void)placeTimeline
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSHourCalendarUnit | NSDayCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *components;
    
    NSDate *workingDate = _scrollStartDate;
    
    CGFloat hourOffset = 0;
    
    while ([workingDate laterDate:_scrollEndDate] == _scrollEndDate) {
        components = [calendar components:units fromDate:workingDate];   
        UIView *hourView = [self getViewForComponents:components];
        
        if (UIInterfaceOrientationIsPortrait(_orientation)) {
            [hourView setHeight:[self getPixelsPerHour]];
            [hourView setOrigin:CGPointMake(0, hourOffset)];   
        } else {
            [hourView setWidth:[self getPixelsPerHour]];
            [hourView setOrigin:CGPointMake(hourOffset, 0)];
        }
        
        [_contentScroll addSubview:hourView];
        
        workingDate = [workingDate dateByAddingTimeInterval:60*60];
        hourOffset += [self getPixelsPerHour];
    }
    
    
    [calendar release];    
}

- (void)placeSeparatorOnLaneWithIndex:(NSNumber *)laneIndex
{    
    CGFloat laneOffset = [self offsetForLaneIndex:[laneIndex intValue]];
    UIView *separator = [self separatorViewForLaneIndex:[laneIndex intValue]];
    CGFloat separatorThickness = [self separatorThicknessForLaneIndex:[laneIndex intValue]];
    CGFloat separatorOffset = laneOffset - separatorThickness;
    
//    NSLog(@"Separator %d thickness: %lf offset: %lf laneOffset: %lf", [laneIndex intValue], separatorThickness, separatorOffset, laneOffset);
    
    if (UIInterfaceOrientationIsPortrait(_orientation)) {
        [separator setOrigin:CGPointMake(separatorOffset, 0)];
        [separator setHeight:_contentScroll.contentSize.height];
    } else {
        [separator setOrigin:CGPointMake(0, separatorOffset)];
        [separator setHeight:separatorThickness];
        [separator setWidth:_contentScroll.contentSize.width];
    }
    
    [self.contentScroll addSubview:separator];
}

- (void)placeEventsOnLaneWithIndex:(NSNumber*)laneIndex
{
    NSArray *events = [_contents objectForKey:laneIndex];
    
    CGFloat laneOffset = [self offsetForLaneIndex:[laneIndex intValue]];
    CGFloat hourOffset = 0;
    
    for (CTTimeScrollViewEvent *event in events) {
        hourOffset = [self offsetFromStartForDate:event.startDate];   
        
        if (UIInterfaceOrientationIsPortrait(_orientation))
        {
            [event setWidth:[self getThicknessForLane:[laneIndex intValue]]];
            [event setOrigin:CGPointMake(laneOffset, hourOffset)];
            [event adjustHeightUsingPointsPerHour:[self getPixelsPerHour]];
        } else {
            [event setHeight:[self getThicknessForLane:[laneIndex intValue]]];
            [event setOrigin:CGPointMake(hourOffset, laneOffset)];
            [event adjustWidthUsingPointsPerHour:[self getPixelsPerHour]];
        }
        [self.contentScroll addSubview:event];
        event.laneIndex = [laneIndex intValue];
        event.itemIndex = [events indexOfObject:event];
        event.delegate = self;
    }

}
#pragma mark - HourStripTimer

- (void)hourStripTimer:(NSTimer *)timer
{
    [self placeHourStrip];
}

#pragma mark - Event Buttons delegate

- (void)eventTouched:(CTTimeScrollViewEvent *)event {
    if ([_delegate respondsToSelector:@selector(timeScrollView:didSelectEvent:onLane:)]) {
        [_delegate timeScrollView:self didSelectEvent:event.itemIndex onLane:event.laneIndex];
    }
}

#pragma mark - DataSource getters

- (UIView *)getSeparatorForLaneIndex:(NSInteger)lane {
    if ([_dataSource respondsToSelector:@selector(timeScrollView:laneSeparatorForIndex:)]) {
		return [_dataSource timeScrollView:self laneSeparatorForIndex:lane];
	} else {
		return nil;
	}
}

- (CGFloat)getThicknessForLane:(NSInteger)laneIndex {
    if ([_dataSource respondsToSelector:@selector(timeScrollView:thicknessForLane:)]) {
		return [_dataSource timeScrollView:self thicknessForLane:laneIndex];
	} else {
		return kCLTimeScrollViewLaneWidth;
	}
}

- (CTTimeScrollViewEvent *)getEventViewForIndex:(NSInteger)index forLane:(NSInteger)laneIndex {
	if ([_dataSource respondsToSelector:@selector(timeScrollView:eventViewForIndex:forLane:)]) {
		return [_dataSource timeScrollView:self eventViewForIndex:index forLane:laneIndex];
	} else {
		return nil;
	}
}

- (NSUInteger)getEventCountForLane:(NSInteger)laneIndex {
	if ([_dataSource respondsToSelector:@selector(timeScrollView:numberOfEventsForLane:)]) {
		return [_dataSource timeScrollView:self numberOfEventsForLane:laneIndex];
	} else {
		return 0;
	}
}

- (UIView *)getViewForComponents:(NSDateComponents *)components {
    if ([_dataSource respondsToSelector:@selector(timeScrollView:timeViewForComponents:thickness:length:)]) {
        return [_dataSource timeScrollView:self timeViewForComponents:components thickness:[self getHourLaneThickness] length:[self getPixelsPerHour]];
    } else {
        return [self defaultHourViewForComponents:components thickness:[self getHourLaneThickness] length:[self getPixelsPerHour]];
    }
}

- (UIView *)getHourStripView {
    if ([_dataSource respondsToSelector:@selector(timeScrollView:timeStripViewWithLength:)]) {
        return [_dataSource timeScrollView:self timeStripViewWithLength:[self scrollContentThickness]];
    } else {
        return nil;
    }
}

- (NSUInteger)getLaneCount {
	if ([_dataSource respondsToSelector:@selector(numberOfLanesInTimeScrollView:)]) {
		return [_dataSource numberOfLanesInTimeScrollView:self];
	} else {
		return kCLTimeScrollViewLaneCount;
	}	
}

- (CGFloat)getPixelsPerHour {
	if ([_dataSource respondsToSelector:@selector(timeScrollViewPixelsPerHour:)]) {
		return [_dataSource timeScrollViewPixelsPerHour:self];
	} else {
		return kCLTimeScrollViewPixelPerHour;
	}
}

- (CGFloat)getHourLaneThickness {
	if ([_dataSource respondsToSelector:@selector(timeScrollViewHourLaneThickness:)]) {
		return [_dataSource timeScrollViewHourLaneThickness:self];
	} else {
		return kCLTimeScrollViewHourLaneWidth;
	}
}

@end
