//
//  UIView+Adjustment.h
//
//  Created by Mariusz Śpiewak
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (FrameProperties)

#pragma mark - Selective frame properties

/**
 * @brief Moves the view by x and y
 * @param x Value that will be added to the x coordinate
 * @param y Value that will be added to the y coordinate
 */
- (void)setOriginByTranslationX:(CGFloat)x Y:(CGFloat)y;

/**
 * @brief Scales size of the view by given values
 * @param xScale Width scale factor
 * @param yScale Height scale factor
 */
- (void)setSizeByScalingWidth:(CGFloat)xScale height:(CGFloat)yScale;

/**
 * @brief Sets the x coordinate of the view
 * @param x Modified x coordinate
 */
- (void)setOriginX:(CGFloat)x;

/**
 * @brief Sets the y coordinate of the view
 * @param y Modified y coordinate
 */
- (void)setOriginY:(CGFloat)y;

/**
 * @brief Sets the origin component of the views' frame
 * @param orign New origin point
 */
- (void)setOrigin:(CGPoint)origin;

/**
 * @brief Sets width of the view
 * @param width New width
 */
- (void)setWidth:(CGFloat)width;

/**
 * @brief Sets height of the view
 * @param height New height
 */
- (void)setHeight:(CGFloat)height;

/**
 * @brief Modifies size component of the views' frame
 * @param size New size
 */
- (void)setSize:(CGSize)size;

#pragma mark - Aligning

/**
 * @brief Centers view verticaly in specified rect
 * @param rect Rect in which bounds the reciever should be centered
 * @discussion Reciever do not have to be a subview of the passed rect.
 */
- (void)centerVerticalyInRect:(CGRect)rect;

/**
 * @brief Centers view in horizontaly specified rect
 * @param rect Rect in which bounds the reciever should be centered
 * @discussion Reciever do not have to be a subview of the passed rect.
 */
- (void)centerHorizontalyInRect:(CGRect)rect;

/**
 * @brief Centers view verticaly in it's superview
 * @param rect Rect in which bounds the reciever should be centered
 * @discussion If reciever does not have a superview the rect is (0,0;0,0)
 */
- (void)centerVerticalyInSuperview;

/**
 * @brief Centers view horizontaly in it's superview
 * @param rect Rect in which bounds the reciever should be centered
 * @discussion If reciever does not have a superview the rect is (0,0;0,0)
 */
- (void)centerHorizontalyInSuperview;

#pragma mark - Other placement
#warning comment
- (void)placeBelowView:(UIView *)baseView withMargin:(CGFloat)margin;
- (void)placeAboveView:(UIView *)baseView withMargin:(CGFloat)margin;

- (void)placeLeftOfView:(UIView *)baseView withMargin:(CGFloat)margin;
- (void)placeRightOfView:(UIView *)baseView withMargin:(CGFloat)margin;

@end
