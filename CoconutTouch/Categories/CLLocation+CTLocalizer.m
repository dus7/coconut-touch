//
//  CLLocationManager+Localizer.m
//  
//
//  Created by Mariusz Śpiewak on 6/28/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import "CLLocation+CTLocalizer.h"

@implementation CLLocation (CTLocalizer)

- (BOOL)isInPolygon:(MKPolygon *)polygon
{
    MKMapPoint point = MKMapPointForCoordinate(self.coordinate);
     
    MKPolygonView *polygonView = [[[MKPolygonView alloc] initWithOverlay:polygon] autorelease];
    
    CGPoint viewPoint = [polygonView pointForMapPoint:point];
    return CGPathContainsPoint(polygonView.path, NULL, viewPoint, NO);
}

@end
