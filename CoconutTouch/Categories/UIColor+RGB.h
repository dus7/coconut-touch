//
//  UIColor+RGB.h
//  
//
//  Created by Mariusz Śpiewak on 7/3/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGB)

+ (UIColor *)colorWithR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b;
+ (UIColor *)colorWithR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString withAlpha:(double)alpha;
+ (CGFloat)colorComponentFrom:(NSString *)colorString start:(NSInteger)start length:(NSInteger)length;
@end
