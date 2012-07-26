//
//  AlertSequenceController.h
//  CustomAlertView
//
//  Created by Mariusz Śpiewak on 6/25/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTAlertView.h"

@interface CTAlertSequenceController : UIViewController

@property(nonatomic, copy) void (^dismissActionOnAlertWithIndex)(NSInteger index);
@property(nonatomic, copy) void (^confirmActionOnAlertWithIndex)(NSInteger index);
@property(nonatomic, copy) void (^willShowFirstAlertAction)(void);
@property(nonatomic, copy) void (^willDismissLastAlertAction)(void);

@property (nonatomic, retain) NSArray *alertViews;


/**
 @brief Starts the alert sequence.
 */
- (void)showFirst;

/**
 @brief Forces the transition to next alert
 */
- (void)showNext;

/**
 @brief Initializes view controller with alert views array.
 @discussion    willDismissAlertAction, dismissAction and confirmAction are defined interally.
                You should use this class' blocks instead.
                Additionaly willDismissAlertAction is defined on last alert in array.
 @param alertViews Array of alert views.
 */
- (id)initWithAlertViews:(NSArray *)alertViews;

@end
