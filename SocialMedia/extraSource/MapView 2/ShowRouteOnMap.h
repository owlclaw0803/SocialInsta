//
//  ShowRouteOnMap.h
//  JourneyTracking
//
//  Created by ind558 on 06/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ShowRouteOnMap : NSObject {
    MKMapRect _routeRect;
}

+ (void)loadRouteOn:(NSArray*)routePoints onMap:(MKMapView*)map forDelegate:(id)delegate;
@end
