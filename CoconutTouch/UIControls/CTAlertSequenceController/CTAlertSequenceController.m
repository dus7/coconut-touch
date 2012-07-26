//
//  AlertSequenceController.m
//  CustomAlertView
//
//  Created by Mariusz Śpiewak on 6/25/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import "CTAlertSequenceController.h"

@interface CTAlertSequenceController ()
@property (nonatomic, assign) NSInteger currentAlertIndex;
@property (nonatomic, retain) GradientView *backgroundGradient;
@property (nonatomic, assign) UIWindow *applicationWindow;

- (void)nextInSequence;
- (void)dismissGradient;
@end

@implementation CTAlertSequenceController

@synthesize alertViews=_alertViews;
@synthesize currentAlertIndex=_currentAlertIndex;

@synthesize backgroundGradient=_backgroundGradient;
@synthesize applicationWindow=_applicationWindow;

@synthesize willShowFirstAlertAction=_willShowFirstAlertAction;
@synthesize willDismissLastAlertAction=_willDismissLastAlertAction;
@synthesize dismissActionOnAlertWithIndex=_dismissActionOnAlertWithIndex;
@synthesize confirmActionOnAlertWithIndex=_confirmActionOnAlertWithIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithAlertViews:(NSArray *)alertViews
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.alertViews = alertViews;
        _currentAlertIndex = 0;
        
        _willShowFirstAlertAction=nil;
        _willDismissLastAlertAction=nil;
        _dismissActionOnAlertWithIndex=nil;
        _confirmActionOnAlertWithIndex=nil;
        
        _applicationWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        
        self.backgroundGradient = [[[GradientView alloc] initWithFrame:[_applicationWindow frame]] autorelease];
        self.backgroundGradient.alpha = 0.0;
        self.backgroundGradient.userInteractionEnabled = NO;
            
        for (int i = 0; i < [_alertViews count]-1; i++) {
            CTAlertView *alert = [_alertViews objectAtIndex:i];
            CTAlertView *nextAlert = [_alertViews objectAtIndex:i+1];
            
            alert.useDefaultDimmBackground = NO;
            
            nextAlert.showTransitionStyle = CTAlertShowTransitionStyleSlideIn;
            alert.removeTransitionStyle = CTAlertDismissTransitionStyleSlideOut;
            
            [alert setDismissAction:^{
                if (self.dismissActionOnAlertWithIndex) {
                    _dismissActionOnAlertWithIndex(i);   
                }
                [self dismissGradient];
                _currentAlertIndex = 0;
            }];
            [alert setConfirmAction:^{
                if (self.confirmActionOnAlertWithIndex) {
                    _confirmActionOnAlertWithIndex(i);   
                }
                [self nextInSequence];
            }];
        }
        
        [[_alertViews lastObject] setUseDefaultDimmBackground:NO];
        [[_alertViews lastObject] setConfirmAction: ^{
            if (self.confirmActionOnAlertWithIndex) {
                _confirmActionOnAlertWithIndex([_alertViews count] - 1);
            }
        }];
        [[_alertViews lastObject] setWillDismissAlertAction:^{
            if (self.willDismissLastAlertAction) {
                _willDismissLastAlertAction();
            }
            [self dismissGradient];
        }];
        
}
    return self;
}

- (void)showFirst
{
    _currentAlertIndex = 0;
    if (self.willShowFirstAlertAction) {
        _willShowFirstAlertAction();
    }
    [_applicationWindow addSubview:_backgroundGradient];
    [UIView animateWithDuration:0.4 animations:^{
        _backgroundGradient.alpha = 1.0;
    }];
    [[_alertViews objectAtIndex:_currentAlertIndex] show];
    
}

- (void)showNext
{
    [[_alertViews objectAtIndex:_currentAlertIndex] remove];
    [self nextInSequence];
}

- (void)dismissGradient
{
    [UIView animateWithDuration:0.4 animations:^{
        _backgroundGradient.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_backgroundGradient removeFromSuperview];
    }];
}

- (void)nextInSequence
{
    _currentAlertIndex++;
    [[_alertViews objectAtIndex:_currentAlertIndex] show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIView *rect = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 50, 80)];
    rect.backgroundColor = [UIColor redColor];
    [self.view addSubview:rect];
    [rect release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    [super dealloc];
    self.alertViews = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
