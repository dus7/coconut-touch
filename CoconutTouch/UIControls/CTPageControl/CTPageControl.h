//
//  CustomPagingView.h
//  Weathertica
//
//  Created by Mariusz Śpiewak on 12-01-27.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+FrameProperties.h"

#define PagingDotTypeDefault @"Default"
#define PagingDotTypeSpecial @"Special"

typedef NSString* PagingDotType;


@interface CTPageControl : UIView {
	NSMutableArray *_dots;
	NSMutableArray *_dotTypes;
	UIImageView *_highlightedDot;
	UIImageView *_tmpDot;
	PagingDotType _highlightedType;
}

@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger dotSpacing;
@property (nonatomic, assign) CGPoint pagingCenter;
@property (nonatomic, retain) UIImage *specialDotHighlighted;
@property (nonatomic, retain) UIImage *defaultDotHighlighted;
@property (nonatomic, retain) UIImage *specialDotNormal;
@property (nonatomic, retain) UIImage *defaultDotNormal;
@property (nonatomic, assign) double transitionDuration;

- (void)setType:(PagingDotType)kPagingDotType forPage:(NSUInteger)pageNumber;

@end
