
//
//  CustomPagingView.m
//  Weathertica
//
//  Created by Mariusz Śpiewak on 12-01-27.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import "CTPageControl.h"


@interface CTPageControl (Private)
- (void)initialize;
- (void)cleanContainers;
- (BOOL)isDefaultDot:(NSUInteger)index;
- (void)animateTransitionForOldDot:(UIImageView *)oldDot newDot:(UIImageView *)newDot;
- (void)commonInit;
- (void)switchHighlightToType:(PagingDotType)type;
@end

@implementation CTPageControl

@synthesize pageCount=_pageCount;
@synthesize currentPage=_currentPage;
@synthesize specialDotNormal=_specialDotNormal;
@synthesize specialDotHighlighted=_specialDotHighlighted;
@synthesize defaultDotNormal=_defaultDotNormal;
@synthesize defaultDotHighlighted=_defaultDotHighlighted;
@synthesize dotSpacing=_dotSpacing;
@synthesize transitionDuration=_transitionDuration;
@synthesize pagingCenter = _pagingCenter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self commonInit];
    }
    return self;
}

- (id)init {
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	_pageCount = 3;
	_dotSpacing = 2;
	_currentPage = 1;
	_transitionDuration = 0.5;
	_highlightedDot = nil;
	_tmpDot = nil;
	_dotTypes = nil;
	_dots = nil;
	_highlightedType = PagingDotTypeDefault;
	_pagingCenter = self.center;
    self.opaque = NO;
	[self initialize];
}

- (void)cleanContainers {
	if (_dots) {
		[_dots makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[_dots removeAllObjects];
	} else {
		_dots = [[NSMutableArray alloc] initWithCapacity:_pageCount];
	}
	if (!_dotTypes) {
		_dotTypes = [[NSMutableArray alloc] initWithCapacity:_pageCount];
		for (int i = 0; i < _pageCount; i++) [_dotTypes addObject:PagingDotTypeDefault];
	} else {
//		NSLog(@"Growing types array");
		if ([_dotTypes count] < _pageCount) {
			for (int i = (_pageCount - [_dotTypes count]); i > 0; i--) {
				[_dotTypes addObject:PagingDotTypeDefault];
			}
		}
	}
}

- (void)dealloc {
	[_dotTypes release];
	[_dots release];
	[_highlightedDot release];
	[super dealloc];
}

- (BOOL)isDefaultDot:(NSUInteger)index {
	if ([_dotTypes count] < index+1 || [_dotTypes objectAtIndex:index] == nil) {
		return YES;
	}
	return [[_dotTypes objectAtIndex:index] isEqualToString:PagingDotTypeDefault];
}

- (void)initialize {
	CGSize defaultDotSize = CGSizeMake(0, 0);
	CGSize specialDotSize = CGSizeMake(0, 0);
	CGSize frameSize = CGSizeMake(1, 30);
	[self cleanContainers];
	
	if (_defaultDotNormal) {
		defaultDotSize = _defaultDotNormal.size;
	} else return;
	
	if (_specialDotNormal) {
		specialDotSize = _specialDotNormal.size;
	}
	
	frameSize.height = MAX(defaultDotSize.height, specialDotSize.height); 
	
	for (int i = 0; i < _pageCount; i++) {
		if ([self isDefaultDot:i]) {
			frameSize.width += defaultDotSize.width;
		} else {
			frameSize.width += specialDotSize.width;
		}
		frameSize.width += _dotSpacing;
	}

//	if (self.frame.size.width < frameSize.width) {
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, frameSize.width, frameSize.height);
		self.center = _pagingCenter;
//	}
	
	int xPosition = 0;
	for (int i = 0; i < _pageCount; i++) {
		UIImageView *dot;
		if ([self isDefaultDot:i]) {
			dot = [[UIImageView alloc] initWithImage:_defaultDotNormal];
		} else {
			dot = [[UIImageView alloc] initWithImage:_specialDotNormal];
		}
        dot.opaque = NO;
		[_dots insertObject:dot atIndex:i];
		[dot setOrigin:CGPointMake(xPosition, 0)];
		xPosition += dot.frame.size.width + _dotSpacing;
//		NSLog(@"xpos: %d", xPosition);
		[dot release];
		[self addSubview:dot];
	}
	
	if (!_highlightedDot) {
		_highlightedDot = [[UIImageView alloc] initWithImage:_defaultDotHighlighted];
        _highlightedDot.opaque = NO;
		[self addSubview:_highlightedDot];	
	}
	
	[self setCurrentPage:_currentPage];
	self.center = _pagingCenter;
}

- (void)animateTransitionForOldDot:(UIImageView *)oldDot newDot:(UIImageView *)newDot {
    oldDot.opaque = NO;
    newDot.opaque = NO;
	[UIView animateWithDuration:_transitionDuration delay:0.0 options: UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
		oldDot.alpha = 0.0;
		newDot.alpha = 1.0;
	} completion:^(BOOL finished) {
		[oldDot removeFromSuperview];
	}];
}

- (void)switchHighlightToType:(PagingDotType)type {
	if (![type isEqualToString:_highlightedType]) {
		if ([type isEqualToString:PagingDotTypeDefault]) {
			_highlightedDot.image = _defaultDotHighlighted;
		} else {
			_highlightedDot.image = _specialDotHighlighted;
		}
		_highlightedType = type;
	}
}

#pragma mark - Public methods

- (void)setType:(PagingDotType)kPagingDotType forPage:(NSUInteger)pageNumber {
//	NSLog(@"set type");
//	if (pageNumber-1 >= [_dots count]) return;
	
//	NSLog(@"replacing %@", _dotTypes);
	
	if ([_dotTypes objectAtIndex:pageNumber-1] == nil) {
		[_dotTypes insertObject:kPagingDotType atIndex:pageNumber-1];
	} else {
		[_dotTypes replaceObjectAtIndex:pageNumber-1 withObject:kPagingDotType];
	}
	[self initialize];
}

#pragma mark - Overloaded setters

- (void)setCurrentPage:(NSUInteger)currentPage {
    if (_currentPage == currentPage) {
        return;
    }
	_currentPage = currentPage;
	
//	NSLog(@"Current page: %d", currentPage);
	
	UIView *dot = [_dots objectAtIndex:currentPage-1];
	
	// Create temporary dot in place of the old one and show it
	if ([self isDefaultDot:_currentPage]) {
		_tmpDot = [[UIImageView alloc] initWithImage:_defaultDotHighlighted];	
	} else {
		_tmpDot = [[UIImageView alloc] initWithImage:_specialDotHighlighted];
	}
	
    _tmpDot.opaque = NO;
    _highlightedDot.opaque = NO;
	[_tmpDot setOrigin:_highlightedDot.frame.origin];
	_tmpDot.alpha = 1.0;
	[self insertSubview:_tmpDot aboveSubview:dot];
	[_tmpDot release];
	
	// Hide the soon-be-moved dot and change it's type if needed
	_highlightedDot.alpha = 0.0;
	[self switchHighlightToType:[_dotTypes objectAtIndex:currentPage-1]];
	[self bringSubviewToFront:_tmpDot];
	[self bringSubviewToFront:_highlightedDot];
	[_highlightedDot setOrigin:dot.frame.origin];
	
	[self animateTransitionForOldDot:_tmpDot newDot:_highlightedDot];
}

- (void)setPageCount:(NSUInteger)pageCount {
	_pageCount = pageCount;
	
	[self initialize];
}

- (void)setDotSpacing:(NSUInteger)dotSpacing {
	_dotSpacing = dotSpacing;
	
	[self initialize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
