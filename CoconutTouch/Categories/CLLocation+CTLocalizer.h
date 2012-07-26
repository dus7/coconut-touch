//
//  CLLocationManager+Localizer.h
//  
//
//  Created by Mariusz Śpiewak on 6/28/12.
//  Copyright (c) 2012 Mariusz Śpiewak. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CLLocation (CTLocalizer)
- (BOOL)isInPolygon:(MKPolygon *)polygon;
@end
